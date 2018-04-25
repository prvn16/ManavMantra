function [accumMatrix, gradientImg] = chaccum(varargin)
%CHACCUM Compute 2D accumulator array using Circular Hough Transform
%   H = CHACCUM(A, RADIUS) computes the 2D accumulator array H using
%   Circular Hough Transform for 2D grayscale input image A with the
%   specified radius. The size of H is the same as the input image A.
%
%   H = CHACCUM(A, RADIUS_RANGE) computes the composite accumulator array
%   with radii in the range specified by RADIUS_RANGE. RADIUS_RANGE is a
%   two-element vector [MIN_RADIUS MAX_RADIUS].
%
%   [H, G] = CHACCUM(A, RADIUS_RANGE, ...) also returns the gradient image
%   G that is used for generating the accumulator array. The Sobel edge
%   operator is used for computing the gradient.
%
%   [H, G] = CHACCUM(A, RADIUS_RANGE,PARAM1,VAL1,PARAM2,VAL2,...) computes
%   accumulator array using name-value pairs to control aspects of the Circular
%   Hough Transform. 
%
%   Parameters include:
%
%   'ObjectPolarity' - Specifies the polarity of the circular object with
%                      respect to the background. Available options are:
%
%           'bright'     : The object is brighter than the background. (Default)
%           'dark'       : The object is darker than the background.
% 
%   'Method' - Specifies the technique used for computing the accumulator
%              array. Available options are:
%
%           'PhaseCode'  : Atherton and Kerbyson's Phase Coding method.
%                         (Default)
%           'TwoStage'   : The method used in Two-stage Circular Hough
%                          Transform.
%
%   'EdgeThreshold' - A scalar K in the range [0 1], specifying the gradient 
%                     threshold for determining edge pixels. K = 0 sets the
%                     threshold at zero-gradient magnitude, and K = 1 sets
%                     the threshold at the maximum gradient magnitude in
%                     the image. A high EdgeThreshold value leads to
%                     detecting only those circles that have relatively
%                     strong edges. A low EdgeThreshold value will, in
%                     addition, lead to detecting circles with relatively
%                     faint edges. By default, CHACCUM chooses the
%                     value automatically using the function GRAYTHRESH.
% 
% See also CHCENTERS, CHRADII, CHRADIIPHCODE, IMFINDCIRCLES, VISCIRCLES.

%   Copyright 2011-2016 The MathWorks, Inc.

%   References:
%   -----------
%   [1] H. K. Yuen, J. Princen, J. Illingworth, and J. Kittler,
%       "Comparative study of Hough Transform methods for circle finding,"
%       Image and Vision Computing, Volume 8, Number 1, 1990, pp. 71-77.
%
%   [2] E. R. Davies, Machine Vision: Theory, Algorithms, Practicalities -
%       Chapter 10, 3rd Edition, Morgan Kauffman Publishers, 2005.
%
%   [3] T. J. Atherton, D. J. Kerbyson, "Size invariant circle detection,"
%       Image and Vision Computing, Volume 17, Number 11, 1999, pp. 795-803.

parsedInputs = parse_inputs(varargin{:});

A             = parsedInputs.Image;
radiusRange   = parsedInputs.RadiusRange;
method        = lower(parsedInputs.Method);
objPolarity   = lower(parsedInputs.ObjectPolarity);
edgeThresh    = parsedInputs.EdgeThreshold;

maxNumElemNHoodMat = 1e6; % Maximum number of elements in neighborhood matrix xc allowed, before memory chunking kicks in.

%% Check if the image is flat
flat = all(A(:) == A(1));
if (flat)
    accumMatrix = zeros(size(A,1),size(A,2));
    gradientImg = zeros(size(A,1),size(A,2));
    return;
end

%% Get the input image in the correct format
A = getGrayImage(A);

%% Calculate gradient
[Gx,Gy,gradientImg] = imgradient(A);

%% Get edge pixels
[Ex, Ey] = getEdgePixels(gradientImg, edgeThresh);
idxE = sub2ind(size(gradientImg), Ey, Ex);

%% Identify different radii for votes
if (length(radiusRange) > 1)
    radiusRange = radiusRange(1):0.5:radiusRange(2);
end
switch (objPolarity)
    case 'bright'
        RR = radiusRange;
    case 'dark'
        RR = -radiusRange;
    otherwise
        error(message('images:imfindcircles:unrecognizedObjectPolarity')); % Should never happen
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
        Opca = exp(sqrt(-1)*phi);
        w0 = Opca./(2*pi*radiusRange);
    otherwise
        iptassert(false,'images:imfindcircles:unrecognizedMethod'); % Should never happen
end

%% Computing the accumulator array

xcStep = floor(maxNumElemNHoodMat/length(RR));
lenE = length(Ex);
[M, N] = size(A);
accumMatrix = zeros(M,N);

for i = 1:xcStep:lenE
    Ex_chunk = Ex(i:min(i+xcStep-1,lenE));
    Ey_chunk = Ey(i:min(i+xcStep-1,lenE));
    idxE_chunk = idxE(i:min(i+xcStep-1,lenE));
    
    xc = bsxfun(@plus, Ex_chunk, bsxfun(@times, -RR, Gx(idxE_chunk)./gradientImg(idxE_chunk))); % Eqns. 10.3 & 10.4 from Machine Vision by E. R. Davies
    yc = bsxfun(@plus, Ey_chunk, bsxfun(@times, -RR, Gy(idxE_chunk)./gradientImg(idxE_chunk)));
    
    xc = round(xc);
    yc = round(yc);
    
    w = repmat(w0, size(xc, 1), 1);
    
    %% Determine which edge pixel votes are within the image domain
    % Record which candidate center positions are inside the image rectangle.
    [M, N] = size(A);
    inside = (xc >= 1) & (xc <= N) & (yc >= 1) & (yc < M);
    
    % Keep rows that have at least one candidate position inside the domain.
    rows_to_keep = any(inside, 2);
    xc = xc(rows_to_keep,:);
    yc = yc(rows_to_keep,:);
    w = w(rows_to_keep,:);
    inside = inside(rows_to_keep,:);
    
    %% Accumulate the votes in the parameter plane
    xc = xc(inside); yc = yc(inside);
    accumMatrix = accumMatrix + accumarray([yc(:), xc(:)], w(inside), [M, N]);
    clear xc yc w; % These are cleared to create memory space for the next loop. Otherwise out-of-memory at xc = bsxfun... in the next loop.
end

end

function [Gx, Gy, gradientImg] = imgradient(I)

hy = -fspecial('sobel');
hx = hy';

Gx = imfilter(I, hx, 'replicate','conv');
Gy = imfilter(I, hy, 'replicate','conv');

if nargout > 2
    gradientImg = hypot(Gx, Gy);
end
end


function [Ex, Ey] = getEdgePixels(gradientImg, edgeThresh)
Gmax = max(gradientImg(:));
if (isempty(edgeThresh))
    edgeThresh = graythresh(gradientImg/Gmax); % Default EdgeThreshold
end
t = Gmax * cast(edgeThresh,'like',gradientImg);
[Ey, Ex] = find(gradientImg > t);
end

function A = getGrayImage(A)
N = ndims(A);
if (N == 3) % RGB Image
    A = rgb2gray(A);
    if (isinteger(A))
        A = im2single(A); % If A is an integer, cast it to floating-point
    end
    
elseif (N == 2)
    if (islogical(A)) % Binary image
        filtStd = 1.5;
        filtSize = ceil(filtStd*3);
        filtSize = filtSize + ceil(rem(filtSize,2)); % filtSize = Smallest odd integer greater than filtStd*3
        gaussFilt = fspecial('gaussian',[filtSize filtSize],filtStd);
        A = imfilter(im2single(A),gaussFilt,'replicate');
    elseif (isinteger(A))
        A = im2single(A); % If A is an integer, cast it to floating-point
    end
    
else
    iptassert(false,'images:imfindcircles:invalidInputImage'); % This should never happen here.
end

end

function parsedInputs = parse_inputs(varargin)

narginchk(2,Inf);

persistent parser;

if isempty(parser)
    checkStringInput = @(x,name) validateattributes(x, ...
        {'char','string'},{'scalartext'},mfilename,name);
    parser = inputParser();
    parser.addRequired('Image',@checkImage);
    parser.addRequired('RadiusRange',@checkRadiusRange);
    parser.addParameter('Method','phasecode',@(x) checkStringInput(x,'Method'));
    parser.addParameter('ObjectPolarity','bright',@(x) checkStringInput(x,'ObjectPolarity'));
    parser.addParameter('EdgeThreshold',[],@checkEdgeThreshold);
end

% Parse input
parser.parse(varargin{:});
parsedInputs = parser.Results;

% Validate string parameter values
parsedInputs.Method = checkMethod(parsedInputs.Method);
parsedInputs.ObjectPolarity = checkObjectPolarity(parsedInputs.ObjectPolarity);

validateRadiusRange(); % If Rmin and Rmax are the same then set R = Rmin.

    function tf = checkImage(A)
        allowedImageTypes = {'uint8', 'uint16', 'double', 'logical', 'single', 'int16'};
        validateattributes(A,allowedImageTypes,{'nonempty',...
            'nonsparse','real'},mfilename,'A',1);
        N = ndims(A);
        if (isvector(A) || N > 3)
            error(message('images:imfindcircles:invalidInputImage'));
        elseif (N == 3)
            if (size(A,3) ~= 3)
                error(message('images:imfindcircles:invalidImageFormat'));
            end
        end
        tf = true;
    end

    function tf = checkRadiusRange(radiusRange)
        if (isscalar(radiusRange))
            validateattributes(radiusRange,{'numeric'},{'nonnan', ...
                'nonsparse','nonempty','positive','finite','vector'},mfilename,'RADIUS_RANGE',2);
        else
            validateattributes(radiusRange,{'numeric'},{'integer','nonnan', ...
                'nonsparse','nonempty','positive','finite','vector'},mfilename,'RADIUS_RANGE',2);
        end        
        if (length(radiusRange) > 2)
            error(message('images:imfindcircles:unrecognizedRadiusRange'));
        elseif (length(radiusRange) == 2)
            if (radiusRange(1) > radiusRange(2))
                error(message('images:imfindcircles:invalidRadiusRange'));
            end
        end
        tf = true;
    end

    function str = checkMethod(method)
        str = validatestring(method, {'twostage','phasecode'}, ...
            mfilename, 'Method');
    end

    function str = checkObjectPolarity(objectPolarity)
        str = validatestring(objectPolarity, {'bright','dark'}, ...
            mfilename, 'ObjectPolarity');
    end

    function tf = checkEdgeThreshold(ET)
        validateattributes(ET,{'numeric'},{'nonnan',...
            'finite'},mfilename,'EdgeThreshold',5);
        if (~isempty(ET))
            if (numel(ET)  == 1)
                if (ET > 1 || ET < 0)
                    error(message('images:imfindcircles:outOfRangeEdgeThreshold'));
                end
            else
                error(message('images:imfindcircles:invalidEdgeThreshold'));
            end
        end
        tf = true;
    end

    function validateRadiusRange
        if (length(parsedInputs.RadiusRange) == 2)
            if (parsedInputs.RadiusRange(1) == parsedInputs.RadiusRange(2))
                parsedInputs.RadiusRange = parsedInputs.RadiusRange(1);
            end
        end
        parsedInputs.RadiusRange = double(parsedInputs.RadiusRange);
    end

end
