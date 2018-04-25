function B = imboxfilt(A, varargin)
%IMBOXFILT 2-D box filtering of images
%
%   B = imboxfilt(A) filters image A with a 3x3 box filter.
%
%   B = imboxfilt(A,filterSize) filters image A with a 2-D box filter with
%   size specified by filterSize. filterSize can be a scalar or 2-element
%   vector of positive, odd integers. If filterSize is scalar, a square box
%   filter is used.
%
%   B = imboxfilt(___,Name,Value,...) filters image A with a 2-D box filter
%   with Name-Value pairs used to control aspects of the filtering.
%
%   Parameters include:
%
%   'Padding'             - String or numeric scalar that specifies padding
%                           to be used on image before filtering.
%  
%                           If a scalar (X) is specified, input image 
%                           values outside the bounds of the image are 
%                           implicitly assumed to have the value X.
%  
%                           If a string or character array is specified, it
%                           can be 'replicate', 'circular' or 'symmetric'.
%                           These options are analogous to the padding
%                           options provided by imfilter.
%  
%                           'replicate' Input image values outside the 
%                           bounds of the image are assumed equal to the 
%                           nearest image border value.
%  
%                           'circular' Input image values outside the 
%                           bounds of the image are computed by implicitly 
%                           assuming the input image is periodic.
%  
%                           'symmetric' Input image values outside the 
%                           bounds of the image are computed by 
%                           mirror-reflecting the array across the array 
%                           border.
%  
%                           Default value is 'replicate'.
%
%   'NormalizationFactor' - Numeric scalar specifying normalization factor
%                           applied to the box filter. 
%                           Default value is 1/filterSize.^2 if filterSize
%                           is scalar and 1/prod(filterSize) if filterSize 
%                           is a vector.
%
%   Class Support
%   -------------
%   The input image A must be a real, non-sparse matrix of any dimension of
%   the following classes: uint8, int8, uint16, int16, uint32, int32,
%   single or double.
%
%   Notes
%   -----
%   1. imboxfilt performs filtering using either convolution-based
%      filtering or integral image filtering. An internal heuristic is used
%      to determine which filtering approach is used.
%
%   2. If the image A contains Infs or NaNs, the behavior of imboxfilt is
%      undefined. This can happen when integral image based filtering is
%      used. To restrict the propagation of Infs and NaNs in the output,
%      consider using imfilter instead.
%
%   3. The default 'NormalizationFactor' is selected to have the effect of
%      a mean filter, i.e. the pixels in output image B are the local means
%      of the image over the neighborhood determined by filterSize. In
%      order to get local area sums, set the 'NormalizationFactor' to be 1.
%      In such circumstances it is advisable to use double-precision images
%      by converting the input image to the double type in order to prevent
%      potential overflow.
%
%   4. If the image A has more than two dimensions, such as for an RGB
%      image or image volume, the same 2-D box filter is applied to all 2-D
%      planes along the higher dimensions.
%
%
%   Example 1
%   ---------
%   This example computes a mean filter over a [11 11] neighborhood.
%   
%   A = imread('cameraman.tif');
%
%   localMean = imboxfilt(A, 11);
%
%   Example 2
%   ---------
%   This example computes local area sums over a [15 15] neighborhood.
%
%   A = imread('cameraman.tif');
%   
%   % Change data type of image to double to avoid integer overflow.
%   A = double(A);
%
%   % Set the 'NormalizationFactor' to 1 to compute local area sums instead
%   % of local means.
%   localSums = imboxfilt(A, 15, 'NormalizationFactor', 1);
%
%
%   See also imboxfilt3, imfilter, integralBoxFilter.

%   Copyright 2014-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
options = parseInputs(A,args{:});

filterSize  = options.FilterSize;
padding     = options.Padding;
normFactor  = options.NormalizationFactor;

outType = class(A);
outSize = size(A);

if isempty(A)
    B = zeros(size(A),'like',A);
    return;
end

if isImfilterFaster(A,filterSize)
    B = boxFilterFromImfilter(A, filterSize, padding, normFactor);
    return;
end

A = padImage(A, padding, filterSize);

A = integralimagemex(A);

B = images.internal.boxfiltermex(A, filterSize, normFactor, outType, outSize);

end

function A = padImage(A, padding, hsize)

hsize = [hsize ones(1,ndims(A)-numel(hsize))];
padSize = (hsize-1)/2;
if ischar(padding)
    method = padding;
    padVal = [];
else
    method = 'constant';
    padVal = padding;
end

A = padarray_algo(A, padSize, method, padVal, 'both');

end

function options = parseInputs(A, varargin)

validateImage(A);

options = struct(...
    'FilterSize', [3 3],...
    'Padding', 'replicate',...
    'NormalizationFactor',1/9);

beginningOfNameVal = find(cellfun(@isstr,varargin),1);
if isempty(beginningOfNameVal)
    beginningOfNameVal = numel(varargin)+1;
end
numOptionalArgs = beginningOfNameVal-1;

if numOptionalArgs==0
    %imboxfilt(A)
elseif numOptionalArgs==1
    options.FilterSize = images.internal.validateTwoDFilterSize(varargin{1});
    options.NormalizationFactor = 1/prod(options.FilterSize);
else
    error(message('images:validate:tooManyOptionalArgs'));
end

numPVPairs = numel(varargin) - numOptionalArgs;
if ~isequal(mod(numPVPairs,2),0)
    error(message('images:validate:invalidNameValue'));
end

ParamName = {'Padding','NormalizationFactor'};
ValidateFcn = {@validatePadding,@validateNormalizationFactor};
for p = beginningOfNameVal:2:numel(varargin)
    
    name  = varargin{p};
    value = varargin{p+1};
    
    logical_idx = strncmpi(name, ParamName, numel(name));
    
    if ~any(logical_idx)
        error(message('images:validate:unknownParamName',name));
    elseif numel(find(logical_idx)) > 1
        error(message('images:validate:ambiguousParamName',name));
    end
    
    % Validate the value.
    validateFcn = ValidateFcn{logical_idx};
    options.(ParamName{logical_idx}) = validateFcn(value);
        
end

end

function validateImage(A)

supportedTypes = {'uint8','uint16','uint32','int8','int16','int32','single','double'};
supportedAttributes = {'real','nonsparse'};
validateattributes(A, supportedTypes, supportedAttributes, mfilename, 'A');

end

function pad = validatePadding(pad)

if ~ischar(pad)
    validateattributes(pad, {'numeric'}, {'real','scalar','nonsparse'}, mfilename, 'Padding');
else
    pad = validatestring(pad, {'replicate','circular','symmetric'}, mfilename, 'Padding');
end

end

function normalize = validateNormalizationFactor(normalize)

validateattributes(normalize, {'numeric'}, {'real','scalar','nonsparse'}, mfilename, 'NormalizationFactor');
normalize = double(normalize);

end

function TF = isImfilterFaster(A,hsize)

% We use imfilter (accelerated with IPP) if the kernel is small.
useIPP = images.internal.useIPPLibrary() && isImageIPPFilterType(class(A));

isKernelSmall = prod(hsize) < images.internal.getBoxFilterThreshold();

TF = useIPP && isKernelSmall;

end

function A = boxFilterFromImfilter(A, hsize, padding, normFactor)

box = ones(hsize) .* normFactor;
A = imfilter(A, box, padding);

end
