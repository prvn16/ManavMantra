function [accumMatrix, gradientImg] = chaccum(varargin) %#codegen
%CHACCUM Compute 2D accumulator array using Circular Hough Transform

%   Copyright 2015 The MathWorks, Inc.

[A, radiusRangeIn, method, objPolarity, edgeThresh] = parseInputs(varargin{:});

% Maximum number of elements in neighborhood matrix xc allowed, before memory chunking kicks in
maxNumElemNHoodMat = 1e6;

%% Check if the image is flat
flat = all(A(:) == A(1));
if (flat)
    accumMatrix = complex(zeros(size(A,1),size(A,2)));
    if ~isa(A,'double')
        gradientImg = zeros(size(A,1),size(A,2),'single');
    else
        gradientImg = zeros(size(A,1),size(A,2));
    end
    return;
end

%% Get the input image in the correct format
A = getGrayImage(A);
classToCast = class(A);

%% Calculate gradient
[Gx,Gy,gradientImg] = imgradientlocal(A);

%% Get edge pixels
[Ex, Ey] = getEdgePixels(gradientImg, edgeThresh);
idxE = sub2ind(size(gradientImg), Ey, Ex);

%% Identify different radii for votes
if (length(radiusRangeIn) > 1)
    radiusRange = radiusRangeIn(1):0.5:radiusRangeIn(2);
else
    radiusRange = radiusRangeIn(1);
end
switch (objPolarity)
    case 'bright'
        RR = radiusRange;
    case 'dark'
        RR = -radiusRange;
    otherwise
        % Should never happen
        assert(false,'images:imfindcircles:unrecognizedObjectPolarity');
end

%% Compute the weights for votes for different radii
switch (method)
    case 'twostage'
        w0 = 1 ./ (2*pi*radiusRange); % Circumference normalization (Inverse circumference weighting)
    case 'phasecode'
        if (length(radiusRange) > 1)
            lnR = log(radiusRange);
            phi = ((lnR - lnR(1))/(lnR(end) - lnR(1))*2*pi) - pi; % Modified form of Log-coding from Eqn. 8 in [3]
        else
            phi = 0;
        end
        Opca = coder.nullcopy(complex(zeros(size(phi))));
        Opca(1,:) = exp(sqrt(complex(-1))*phi);
        w0 = Opca./(2*pi*radiusRange);
    otherwise
        % Should never happen
        assert(false,'images:imfindcircles:unrecognizedMethod');
end

%% Computing the accumulator array
xcStep = floor(maxNumElemNHoodMat/length(RR));
lenE = length(Ex);
[M, N] = size(A);
accumMatrix = complex(zeros(M,N));

for i = 1:xcStep:lenE
    sizeChunk = numel(i:min(i+xcStep-1,lenE));
    Ex_chunk = coder.nullcopy(zeros(sizeChunk,1,'like',Ex));
    Ey_chunk = coder.nullcopy(zeros(sizeChunk,1,'like',Ex));
    idxE_chunk = coder.nullcopy(zeros(sizeChunk,1,'like',Ex));
    
    idxEdge = coder.internal.indexInt(i);
    for idx = 1:sizeChunk
        Ex_chunk(idx) = Ex(idxEdge);
        Ey_chunk(idx) = Ey(idxEdge);
        idxE_chunk(idx) = idxE(idxEdge);
        idxEdge = idxEdge + 1;
    end
    
    dim1 = numel(idxE_chunk);
    dim2 = numel(RR);
    xc = coder.nullcopy(zeros(dim1,dim2,classToCast));
    yc = coder.nullcopy(zeros(dim1,dim2,classToCast));
    
    w = coder.nullcopy(zeros(dim1,dim2,'like',w0));
    inside = coder.nullcopy(false(dim1,dim2));
    
    % Initialize the rows that are to be selected
    rows_to_keep  = false(dim1,1);
    
    for idx2 = 1:dim2
        for idx1 = 1:dim1
            xc(idx1,idx2) = roundAndCast((Ex_chunk(idx1) + (-RR(idx2) * (Gx(idxE_chunk(idx1))/gradientImg(idxE_chunk(idx1))))),classToCast);
            yc(idx1,idx2) = roundAndCast((Ey_chunk(idx1) + (-RR(idx2) * (Gy(idxE_chunk(idx1))/gradientImg(idxE_chunk(idx1))))),classToCast);
            w(idx1,idx2)  = w0(1,idx2);
            inside(idx1, idx2) = (xc(idx1,idx2) >= 1) & (xc(idx1,idx2) <= N) & (yc(idx1,idx2) >= 1) & (yc(idx1,idx2) < M);
            
            % Overwrites the same index location.
            if inside(idx1, idx2)
                rows_to_keep(idx1) = true(1,1);
            end
        end
    end
    
    %% Determine which edge pixel votes are within the image domain
    % Record which candidate center positions are inside the image rectangle.
    % Keep rows that have at least one candidate position inside the domain.
    dim1 = numel(idxE_chunk);
    dim2 = numel(RR);
    
    xckeep = coder.nullcopy(zeros(numel(xc),1,coder.internal.indexIntClass()));
    yckeep = coder.nullcopy(zeros(numel(yc),1,coder.internal.indexIntClass()));
    wkeep = coder.nullcopy(zeros(numel(w),1,'like',w0));
    
    idxkeep = coder.internal.indexInt(0);
    for idx2 = 1:dim2
        for idx1 = 1:dim1
            if rows_to_keep(idx1) && inside(idx1,idx2)
                idxkeep = idxkeep + 1;
                xckeep(idxkeep,1) = coder.internal.indexInt(xc(idx1,idx2));
                yckeep(idxkeep,1) = coder.internal.indexInt(yc(idx1,idx2));
                wkeep(idxkeep,1) = w(idx1,idx2);
            end
        end
    end
    
    accumMatrix = accumMatrix + accumarraylocal(yckeep, xckeep, idxkeep, wkeep, [M, N]);
end

end

function y = roundAndCast(x,outputClass)

coder.inline('always');
coder.internal.prefer_const(outputClass);

if (x > 0)
    y = eml_cast(x + 0.5, outputClass, 'to zero', 'spill');
elseif (x < 0)
    y = eml_cast(x - 0.5, outputClass, 'to zero', 'spill');
else
    y = cast(0,outputClass);
end
end

function out = accumarraylocal(yc,xc, szxc, w, sz)

coder.inline('always');

out = complex(zeros(sz));

for idx = 1:szxc
    out(yc(idx),xc(idx)) = out(yc(idx),xc(idx)) + w(idx);
end

end

function [Gx, Gy, gradientImg] = imgradientlocal(I)

coder.inline('always');

hy = -fspecial('sobel');
hx = hy';

Gx = imfilter(I, hx, 'replicate','conv');
Gy = imfilter(I, hy, 'replicate','conv');

if nargout > 2
    gradientImg = hypot(Gx, Gy);
end
end

function [Ex, Ey] = getEdgePixels(gradientImg, edgeThreshIn)

coder.inline('always');
coder.internal.prefer_const(edgeThreshIn);

Gmax = max(gradientImg(:));
if (isempty(edgeThreshIn))
    % Default EdgeThreshold
    edgeThresh = cast(multithresh(gradientImg/Gmax),'like',gradientImg);
else
    edgeThresh = cast(edgeThreshIn,'like',gradientImg);
end
t = Gmax * edgeThresh(1);
[Ey, Ex] = find(gradientImg > t);
end

function Aout = getGrayImage(A)

coder.inline('always');

N = ndims(A);
if (N == 3) % RGB Image
    A = rgb2gray(A);
    if (isinteger(A))
        Aout = im2single(A); % If A is an integer, cast it to floating-point
    else
        Aout = A;
    end
    
elseif (N == 2)
    if (islogical(A)) % Binary image
        filtStd = 1.5;
        filtSize = ceil(filtStd*3);
        filtSize = filtSize + ceil(rem(filtSize,2)); % filtSize = Smallest odd integer greater than filtStd*3
        gaussFilt = fspecial('gaussian',[filtSize filtSize],filtStd);
        Aout = imfilter(im2single(A),gaussFilt,'replicate');
    elseif (isinteger(A))
        Aout = im2single(A); % If A is an integer, cast it to floating-point
    else
        Aout = A;
    end
    
else
    % This should never happen here.
    if (isinteger(A))
        Aout = im2single(A); % If A is an integer, cast it to floating-point
    else
        Aout = A;
    end   
    assert(false,'images:imfindcircles:invalidInputImage');
end

end

function [A, radiusRange, method, objPolarity, edgeThresh] = parseInputs(varargin)

narginchk(2,Inf);

A = varargin{1};
allowedImageTypes = {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'};
validateattributes(A,allowedImageTypes,{'nonempty',...
    'nonsparse','real'},mfilename,'A',1);
N = ndims(A);
coder.internal.errorIf(isvector(A) || N > 3,...
    'images:imfindcircles:invalidInputImage');
coder.internal.errorIf(N == 3 && (size(A,3) ~= 3),...
    'images:imfindcircles:invalidImageFormat');

radiusRangeIn = varargin{2};
if (isscalar(radiusRangeIn))
    validateattributes(radiusRangeIn,{'numeric'},{'nonnan', ...
        'nonsparse','nonempty','positive','finite','vector'},mfilename,'RADIUS_RANGE',2);
else
    validateattributes(radiusRangeIn,{'numeric'},{'integer','nonnan', ...
        'nonsparse','nonempty','positive','finite','vector'},mfilename,'RADIUS_RANGE',2);
end

coder.internal.errorIf(length(radiusRangeIn) > 2,...
    'images:imfindcircles:unrecognizedRadiusRange');
coder.internal.errorIf((length(radiusRangeIn) == 2) && (radiusRangeIn(1) > radiusRangeIn(2)),...
    'images:imfindcircles:invalidRadiusRange');

% If Rmin and Rmax are the same then set R = Rmin.
if (length(radiusRangeIn) == 2)
    if (radiusRangeIn(1) == radiusRangeIn(2))
        radiusRange = double(radiusRangeIn(1));
    else
        radiusRange = double(radiusRangeIn);
    end
else
    radiusRange = double(radiusRangeIn(1));
end

[method, objPolarity, edgeThresh] = parseOptionalInputs(varargin{3:end});

end

function [method, objPolarity, edgeThresh] = parseOptionalInputs(varargin)
% Parse optional PV pairs

coder.inline('always');
coder.internal.prefer_const(varargin);

params = struct( ...
    'Method',   uint32(0), ...
    'ObjectPolarity',  uint32(0),...
    'EdgeThreshold', uint32(0)...
    );

popt = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', true);

optarg       = eml_parse_parameter_inputs(params, popt, ...
    varargin{:});
methodIn       = eml_get_parameter_value(...
    optarg.Method, 'phasecode', varargin{:});
objPolarityIn  = eml_get_parameter_value(...
    optarg.ObjectPolarity, 'bright', varargin{:});
edgeThresh   = eml_get_parameter_value(...
    optarg.EdgeThreshold, [], varargin{:});

% Validate PV pairs
method = checkMethod(methodIn);
objPolarity = checkObjectPolarity(objPolarityIn);
checkEdgeThreshold(edgeThresh);

end

function method = checkMethod(methodIn)
method = validatestring((methodIn), {'twostage','phasecode'}, ...
    mfilename, 'Method');
end

function objectPolarity = checkObjectPolarity(objectPolarityIn)
objectPolarity = validatestring((objectPolarityIn), {'bright','dark'}, ...
    mfilename, 'ObjectPolarity');
end

function checkEdgeThreshold(ET)
validateattributes(ET,{'numeric'},{'nonnan',...
    'finite'},mfilename,'EdgeThreshold',5);
if (~isempty(ET))
    coder.internal.errorIf( (numel(ET)  == 1) && (ET > 1 || ET < 0),...
        'images:imfindcircles:outOfRangeEdgeThreshold');
    coder.internal.errorIf(numel(ET) ~= 1, ...
        'images:imfindcircles:invalidEdgeThreshold');
end

end
