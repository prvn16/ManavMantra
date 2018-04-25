function B = integralBoxFilter(intA, varargin)
%INTEGRALBOXFILTER 2-D box filtering of integral images
%
%   B = integralBoxFilter(intA) filters integral image intA with a 3x3 box
%   filter. B is an image of class double containing the filtered output.
%   integralBoxFilter returns only the parts of the filtering that are
%   computed without padding.
%
%   B = integralBoxFilter(intA, filterSize) filters integral image intA
%   with a 2-D box filter with size specified by filterSize. filterSize can
%   be a scalar or 2-element vector of positive, odd integers. If
%   filterSize is a scalar, a square box filter is used.
%
%   B = integralBoxFilter(__,Name,Value,...) filters integral image intA
%   with a 2-D box filter with Name-Value pairs to control various aspects
%   of the filtering.
%
%   Parameters include:
%
%   'NormalizationFactor' - Numeric scalar specifying normalization factor
%                           applied to the box filter. 
%                           Default value is 1/filterSize.^2 if filterSize
%                           is scalar and 1/prod(filterSize) if filterSize 
%                           is a vector.
%
%   Class Support
%   -------------
%   The input integral image intA must be a real, non-sparse, double matrix
%   of any dimension.
%
%   Notes
%   -----
%   1. integralBoxFilter expects the input intA to be an upright integral
%      image computed using integralImage. Rotated integral images are not
%      supported. The first row and column of the integral image is assumed
%      to be zero-padded, as returned by integralImage.
%
%   2. If the integral image intA has more than two dimensions, such as for
%      the integral image of an RGB image, the same 2-D box filter is
%      applied to all 2-D planes along the higher dimensions.
%
%   Example 1
%   ---------
%   This example filters an image with a box filter over a [11 11]
%   neighborhood.
%
%   A = imread('cameraman.tif');
%
%   % Pad the image by radius of the filter neighborhood
%   filterSize = [11 11];
%   padSize = (filterSize-1)/2;
%   Apad = padarray(A, padSize, 'replicate','both');
%   
%   % Compute integral image of the padded input
%   intA = integralImage(Apad);
%   
%   % Filter the integral image
%   B = integralBoxFilter(intA, filterSize);
%
%
%   Example 2
%   ---------
%   This example filters an image with a horizontal and a vertical motion
%   blur of length 11.
%
%   A = imread('cameraman.tif');
%   
%   % Pad the image by radius of the filter neighborhood
%   padSize = [5 5]; % (11-1)/2
%   Apad = padarray(A, padSize, 'replicate', 'both');
% 
%   % Compute the integral image of the padded input
%   intA = integralImage(Apad);
% 
%   % Filter the integral image with a vertical [11 1] filter
%   Bvert = integralBoxFilter(intA, [11 1]);
% 
%   % Crop the output to retain input image size
%   Bvert = Bvert(:,6:end-5);
%
%   % Filter the integral image with a horizontal [1 11] filter
%   Bhorz = integralBoxFilter(intA, [1 11]);
%
%   % Crop the output to retain input image size
%   Bhorz = Bhorz(6:end-5,:);
%
%   See also integralImage, imboxfilt.

%   Copyright 2015-2017 The MathWorks, Inc.

varargin = matlab.images.internal.stringToChar(varargin);
options = parseInputs(intA, varargin{:});

filterSize = options.FilterSize;
normFactor = options.NormalizationFactor;
outSize    = options.OutputSize;
outType    = 'double';

B = images.internal.boxfiltermex(intA, filterSize, normFactor, outType, outSize);

end

function options = parseInputs(intA, varargin)

% validate image
validateattributes(intA,{'double'},{'real','nonsparse','nonempty'},mfilename,'Integral Image',1);

if any([size(intA,1) size(intA,2)] < 2)
    error(message('images:integralBoxFilter:intImageTooSmall'));
end

options = struct(...
    'FilterSize',[3 3],...
    'NormalizationFactor',1/9,...
    'OutputSize',[]);

beginningOfNameVal = find(cellfun(@isstr,varargin),1);
if isempty(beginningOfNameVal)
    beginningOfNameVal = numel(varargin)+1;
end
numOptionalArgs = beginningOfNameVal-1;

if numOptionalArgs == 0
    %integralBoxFilter(A);
elseif numOptionalArgs == 1
    options.FilterSize = images.internal.validateTwoDFilterSize(varargin{1});
    options.NormalizationFactor = 1/prod(options.FilterSize);
else
    error(message('images:validate:tooManyOptionalArgs'));
end

if any([size(intA,1) size(intA,2)]-1 < options.FilterSize)
    error(message('images:integralBoxFilter:filterTooBig'));
end

numPVPairs = numel(varargin) - numOptionalArgs;
if ~isequal(mod(numPVPairs,2),0)
    error(message('images:validate:invalidNameValue'));
end

ParamName = {'NormalizationFactor'};
ValidateFcn = {@validateNormalizationFactor};
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

if isempty(options.OutputSize)
    options.OutputSize = size(intA) - [options.FilterSize zeros(1,ndims(intA)-2)];
end
end

function normalize = validateNormalizationFactor(normalize)

validateattributes(normalize, {'numeric'}, {'real','scalar','nonsparse'}, mfilename, 'NormalizationFactor');
normalize = double(normalize);

end