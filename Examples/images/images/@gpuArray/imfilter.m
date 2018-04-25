function b = imfilter(varargin)
%IMFILTER N-D filtering of multidimensional images.
%   B = IMFILTER(A,H) filters the multidimensional gpuArray A with the
%   multidimensional filter H.  A can be logical or it can be a nonsparse 
%   numeric array of any class and dimension.  The result, B, has the same
%   size and class as A.  
%
%   Each element of the output, B, is computed using either single-
%   or double-precision floating point, depending on the data type
%   of A.  When A contains double-precision or UINT32 values, the
%   computations are performed using double-precision values.  All
%   other data types use single-precision.  If A is an integer or
%   logical array, then output elements that exceed the range of
%   the given type are truncated, and fractional values are rounded.
%
%   B = IMFILTER(A,H,OPTION1,OPTION2,...) performs multidimensional
%   filtering according to the specified options.  Option arguments can
%   have the following values:
%
%   - Boundary options
%
%       X            Input array values outside the bounds of the array
%                    are implicitly assumed to have the value X.  When no
%                    boundary option is specified, IMFILTER uses X = 0.
%
%       'symmetric'  Input array values outside the bounds of the array
%                    are computed by mirror-reflecting the array across
%                    the array border.
%
%       'replicate'  Input array values outside the bounds of the array
%                    are assumed to equal the nearest array border
%                    value.
%
%       'circular'   Input array values outside the bounds of the array
%                    are computed by implicitly assuming the input array
%                    is periodic.
%
%   - Output size options
%     (Output size options for IMFILTER are analogous to the SHAPE option
%     in the functions CONV2 and FILTER2.)
%
%       'same'       The output array is the same size as the input
%                    array.  This is the default behavior when no output
%                    size options are specified.
%
%       'full'       The output array is the full filtered result, and so
%                    is larger than the input array.
%
%   - Correlation and convolution
%
%       'corr'       IMFILTER performs multidimensional filtering using
%                    correlation, which is the same way that FILTER2
%                    performs filtering.  When no correlation or
%                    convolution option is specified, IMFILTER uses
%                    correlation.
%
%       'conv'       IMFILTER performs multidimensional filtering using
%                    convolution.
%
%   Example
%   -------------
%       originalRGB = gpuArray(imread('peppers.png'));
%       h = fspecial('motion',50,45);
%       filteredRGB = imfilter(originalRGB,h);
%       figure, imshow(originalRGB)
%       figure, imshow(filteredRGB)
%       boundaryReplicateRGB = imfilter(originalRGB,h,'replicate');
%       figure, imshow(boundaryReplicateRGB)
%
%   See also FSPECIAL, GPUARRAY/CONV2, GPUARRAY/CONVN, GPUARRAY/FILTER2,
%            GPUARRAY.

%   Copyright 1993-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
[a, h, boundary, sameSize] = parse_inputs(args{:});

[finalSize, pad] = computeSizes(a, h, sameSize);

%Empty Inputs
% 'Same' output then size(b) = size(a)
% 'Full' output then size(b) = size(h)+size(a)-1
if isempty(a)
    
    b = handleEmptyImage(a, sameSize, finalSize);
    return
    
elseif isempty(h)
    
    b = handleEmptyFilter(a, sameSize, finalSize);
    return
    
end

boundaryStr = boundary;
padVal      = 0;
if(~ischar(boundary))
    boundaryStr = 'constant';
    padVal      = boundary;
end

%Special case
% If the filter kernel is 3x3 and same size output is requested.
if(ismatrix(a) && isequal(size(h),[3 3]) && sameSize...
        && isreal(a) && isreal(h) && ~strcmp(boundaryStr,'circular'))
    
    h      = gpuArray(double(h));
    padVal = cast(gather(padVal), classUnderlying(a));
    b      = images.internal.gpu.imfilter(a, h, boundaryStr, padVal);
    return;
    
end

[separableFlag, u, s, v] = isSeparable(a, h);

%Special case
% If the filter kernel is separable, input is to be zero-padded and output
% is requested at the same size, use conv2 instead of convn.
useConv2 = separableFlag && padVal==0 && strcmp(boundaryStr,'constant') && sameSize && ismatrix(h);
if useConv2
    
    % extract the components of the separable filter
    hcol = u(:,1) * sqrt(s(1));
    hrow = v(:,1)' * sqrt(s(1));
    
    origClass = classUnderlying(a);
    [a,sameClass] = convertToFloat(a,origClass);
    
    % perform convolution plane-by-plane
    sub.type = '()';
    sub.subs = {':',':',1};
    for zInd = 1:size(a,3)
        
        % handle planes one at a time
        sub.subs{3} = zInd;
        
        a = subsasgn(a, sub, ...
            conv2(hcol, hrow, subsref(a,sub), 'same'));
    end
    
    if ~sameClass
        b = cast(a, origClass);
    else
        b = a;
    end
    
    return;
end

% zero-pad input based on dimensions of filter kernel.
a = padarray_algo(a,pad,boundaryStr,padVal,'both');


if (separableFlag)
    
    % extract the components of the separable filter
    hcol = u(:,1) * sqrt(s(1));
    hrow = v(:,1)' * sqrt(s(1));
    
    % cast data to appropriate floating point type
    origClass = classUnderlying(a);
    [a,sameClass] = convertToFloat(a,origClass);
    
    % apply the first component of the separable filter (hrow)
    out_size_row = [size(a,1) finalSize(2:end)];
    start = [0 pad(2:end)];
    b_tmp = filterPartOrWhole(a, out_size_row, hrow, start+1, sameSize);
    
    % apply the other component of the separable filter (hcol)
    start = [pad(1) 0 pad(3:end)];
    b = filterPartOrWhole(b_tmp, finalSize, hcol, start+1, sameSize);
    
    % cast back to input datatype
    if ~sameClass
        b = cast(b, origClass);
    end
    
else % non-separable filter case
    
    % cast data to appropriate floating point type
    origClass = classUnderlying(a);
    [a,sameClass] = convertToFloat(a,origClass);

    b = filterPartOrWhole(a, finalSize, h, pad+1, sameSize);
    
    % cast back to input datatype
    if (~sameClass)
        b = castData(b, origClass);
    end
end


%--------------------------------------------------------------
function [a, h, boundary, sameSize] = parse_inputs(a, h, varargin)

narginchk(2,5);

if ~isa(a, 'gpuArray')
    error(message('images:imfilter:gpuImageType'))
end

if isa(h, 'gpuArray')
    hValidateAttributes(h,{'double'},{'nonsparse'},mfilename,'filter kernel H',2);
else
    validateattributes(h,{'double'},{'nonsparse'},mfilename,'filter kernel H',2);
end

%Assign defaults
boundary = 0;  %Scalar value of zero
output = 'same';
do_fcn = 'corr';

allStrings = {'replicate', 'symmetric', 'circular', 'conv', 'corr', ...
    'full','same'};

for k = 1:length(varargin)
    if ischar(varargin{k})
        string = validatestring(varargin{k}, allStrings,...
            mfilename, 'OPTION',k+2);
        switch string
            case {'replicate', 'symmetric', 'circular'}
                boundary = string;
            case {'full','same'}
                output = string;
            case {'conv','corr'}
                do_fcn = string;
        end
    else
        validateattributes(varargin{k},{'numeric'},{'nonsparse'},mfilename,'OPTION',k+2);
        boundary = varargin{k};
    end %else
end

sameSize = strcmp(output,'same');

convMode = strcmp(do_fcn,'conv');

% Rotate kernel for correlation
if isa(h, 'gpuArray')
    if ~convMode
        if ismatrix(h)
            h = rot90(h,2);
        else
            h = reshape(flipud(h(:)),size(h));
        end
    end
else
    if convMode
        h = gpuArray(h);
    else
        % For convMode, filter must be rotated. Do this on the CPU for
        % small sizes, as it is likely to be slow.
        if numel(h) < 100000
            if ismatrix(h)
                h = gpuArray(rot90(h,2));
            else
                h = gpuArray(reshape(flipud(h(:)),size(h)));
            end
        else
            if ismatrix(h)
                h = rot90(gpuArray(h),2);
            else
                h = reshape(flipud(gpuArray(h(:))),size(h));
            end
        end
    end
end


%--------------------------------------------------------------
function [separable, u, s, v] = isSeparable(a, h)

% check for filter separability
sep_threshold = getSeparableFilterThreshold(classUnderlying(a));

subs.type = '()';
subs.subs = {':'};

if ((numel(h) >= sep_threshold) && ...
        ndims(a)<=3 &&...
        ismatrix(h) && ...
        all(size(h) ~= 1) && ...
        all(isfinite(subsref(h,subs))))
    
    [u, s, v] = svd(gather(h));
    s = diag(s);
    tol = length(h) * s(1) * eps;
    rank = sum(s > tol);
    
    if (rank == 1)
        separable = true;
    else
        separable = false;
    end
    
else
    
    separable = false;
    u = [];
    s = [];
    v = [];
    
end


%--------------------------------------------------------------
function b = handleEmptyImage(a, sameSize, im_size)

if (sameSize)
    
    b = a;
    
else
    
    if all(im_size >= 0)
        
        b = zeros(im_size, 'like', a);
        
    else
        
        error(message('images:imfilter:negativeDimensionBadSizeB'))
        
    end
    
end


%--------------------------------------------------------------
function b = handleEmptyFilter(a, sameSize, im_size)

if (sameSize)
    
    b = zeros(size(a), 'like', a);
    
else
    
    if all(im_size>=0)
        
        b = zeros(im_size, 'like', a);
        
    else
        
        error(message('images:imfilter:negativeDimensionBadSizeB'))
        
    end
    
end


%--------------------------------------------------------------
function [finalSize, pad] = computeSizes(a, h, sameSize)

rank_a = ndims(a);
rank_h = ndims(h);

% Pad dimensions with ones if filter and image rank are different
size_h = [size(h) ones(1,rank_a-rank_h)];
size_a = [size(a) ones(1,rank_h-rank_a)];

if (sameSize)
    %Same output
    finalSize = size_a;
    
    %Calculate the number of pad pixels
    filter_center = floor((size_h + 1)/2);
    pad = size_h - filter_center;
else
    %Full output
    finalSize = size_a+size_h-1;
    pad = size_h - 1;
end


%--------------------------------------------------------------
function a = filterPartOrWhole(a, outSize, h1, outputStartIdx, sameSize)

if (sameSize)
    sizeFlag = 'same';
else
    sizeFlag = 'full';
end

a = convn(a, h1, sizeFlag);

% Retrieve the part of the image that's required.
sRHS.type = '()';

for ind = 1:ndims(h1)   
    sRHS.subs{ind} = outputStartIdx(ind):(outputStartIdx(ind) + outSize(ind) - 1);
end

for ind = ndims(h1)+1:ndims(a)
    sRHS.subs{ind} = ':';
end

a = subsref(a, sRHS);


%--------------------------------------------------------------
function [a,sameClass] = convertToFloat(a,origClass)
% Convert input matrix to double if datatype is uint32, else convert to
% single.

switch (origClass)
    case {'double','uint32'}
        sameClass = strcmp(origClass,'double');
        
        if ~sameClass
            a = double(a);
        end
        
    otherwise
        sameClass = strcmp(origClass,'single');
        
        if ~sameClass
            a = single(a);
        end
end


%--------------------------------------------------------------
function result = castData(result, origClass)

if (strcmp(origClass, 'logical'))
    result = result >= 0.5;
else
    result = cast(result, origClass);
end
