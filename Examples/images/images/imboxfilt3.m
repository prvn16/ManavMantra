function B = imboxfilt3(A, varargin)
%IMBOXFILT3 3-D box filtering of 3-D images
%
%   B = imboxfilt3(A) filters 3-D image A with a 3x3x3 box filter.
%
%   B = imboxfilt3(A,filterSize) filters 3-D image A with a 3-D box filter
%   with size specified by filterSize. filterSize can be a scalar or
%   3-element vector of positive, odd integers. If filterSize is scalar, a
%   cube box filter is used.
%
%   B = imboxfilt3(___,Name,Value,...) filters 3-D image A with a 3-D box
%   filter with Name-Value pairs used to control aspects of the filtering.
%
%   Parameters incude:
%
%   'Padding'             - String, character array or numeric scalar that
%                           specifies padding to be used on image before
%                           filtering.
%  
%                           If a scalar (X) is specified, input image 
%                           values outside the bounds of the image are 
%                           implicitly assumed to have the value X.
%  
%                           If a string or a character array is specified,
%                           it can be 'replicate', 'circular' or
%                           'symmetric'. These options are analogous to the
%                           padding options provided by imfilter.
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
%                           Default value is 1/filterSize.^3 if filterSize
%                           is scalar and 1/prod(filterSize) if filterSize 
%                           is a vector.
%
%   Class Support
%   -------------
%   The input image A must be a real, non-sparse 3-D matrix of the
%   following classes: uint8, int8, uint16, int16, uint32, int32, single or
%   double.
%
%   Notes
%   -----
%   1. If the image A contains Infs or NaNs, the behavior of imboxfilt3 is
%      undefined. This can happen when integral image based filtering is
%      used. To restrict the propagation of Infs and NaNs in the output,
%      consider using imfilter instead.
%
%   2. The default 'NormalizationFactor' is selected to have the effect of
%      a mean filter, i.e. the pixels in output image B are the local means
%      of the image. In order to get local area sums, choose the
%      'NormalizationFactor' to be 1. In such circumstances consider not
%      using integer type images to avoid overflow.
%
%
%   Example 1
%   ---------
%   This example computes a mean filter over a [5 5 3] neighborhood in an
%   MRI volume. 
%   
%   volData = load('mri');
%   vol = squeeze(volData.D);
%
%   localMean = imboxfilt3(vol, [5 5 3]);
%
%
%   See also imboxfilt, imfilter, integralBoxFilter3.

%   Copyright 2014-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
options = parseInputs(A,args{:});

filterSize  = options.FilterSize;
padding     = options.Padding;
normFactor  = options.NormalizationFactor;

outType = class(A);
outSize = [size(A) ones(1,3-ndims(A))];

if isempty(A)
    B = zeros(size(A),'like',A);
    return;
end

A = padImage(A, padding, filterSize);

A = integralImage3(A);

B = images.internal.boxfilter3mex(A, filterSize, normFactor, outType, outSize);

end

function A = padImage(A, padding, hsize)

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
    'FilterSize', [3 3 3],...
    'Padding', 'replicate',...
    'NormalizationFactor',1/27);

beginningOfNameVal = find(cellfun(@isstr,varargin),1);
if isempty(beginningOfNameVal)
    beginningOfNameVal = numel(varargin)+1;
end
numOptionalArgs = beginningOfNameVal-1;

if numOptionalArgs==0
    %imboxfilt3(A)
elseif numOptionalArgs==1
    options.FilterSize = images.internal.validateThreeDFilterSize(varargin{1});
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
supportedAttributes = {'real','nonsparse','3d'};
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