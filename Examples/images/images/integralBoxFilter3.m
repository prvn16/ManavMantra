function B = integralBoxFilter3(intA, varargin)
%INTEGRALBOXFILTER3 3-D box filtering of 3-D integral images
%
%   B = integralBoxFilter3(intA) filters 3-D integral image intA with a
%   3x3x3 box filter. B is a 3-D image of class double containing the
%   filtered output. integralBoxFilter3 returns only the parts of the
%   filtering that are computed without padding.
%
%   B = integralBoxFilter3(intA, filterSize) filters 3-D integral image
%   intA with a 3-D box filter with size specified by filterSize.
%   filterSize can be a scalar or 3-element vector of positive, odd
%   integers. If filterSize is a scalar, a cube box filter is used.
%
%   B = integralBoxFilter3(__,Name,Value,...) filters 3-D integral image
%   intA with a 3-D box filter with Name-Value pairs to control various
%   aspects of the filtering.
%
%   Parameters include:
%
%   'NormalizationFactor' - Numeric scalar specifying normalization factor
%                           applied to the box filter. 
%                           Default value is 1/filterSize.^3 if filterSize
%                           is scalar and 1/prod(filterSize) if filterSize 
%                           is a vector.
%
%   Class Support
%   -------------
%   The input integral image intA must be a real, non-sparse, double matrix
%   of 3 dimensions.
%
%   Notes
%   -----
%   integralBoxFilter3 expects the input intA to be an upright integral
%   image computed using integralImage3. Rotated integral images are not
%   supported. The first row, column and page of the integral image is
%   assumed to be padded, as returned by integralImage3.
%
%   Example 1
%   ---------
%   This example filters an MRI volume with a box filter over a [5 5 3]
%   neighborhood.
%
%   volData = load('mri');
%   vol = squeeze(volData.D);
%   
%   % Pad the image volume be radius of the filter neighborhood
%   filterSize = [5 5 3];
%   padSize = (filterSize-1)/2;
%   volPad = padarray(vol, padSize, 'replicate', 'both');
%
%   % Compute the 3-D integral image of the padded input
%   intVol = integralImage3(volPad);
%
%   % Filter the 3-D integral image with a [5 5 3] filter
%   volFilt = integralBoxFilter3(intVol, filterSize);
%
%
%   See also integralImage3, imboxfilt3.

%   Copyright 2015-2017 The MathWorks, Inc.

varargin = matlab.images.internal.stringToChar(varargin);
options = parseInputs(intA, varargin{:});

filterSize = options.FilterSize;
normFactor = options.NormalizationFactor;
outSize    = options.OutputSize;
outType    = 'double';

B = images.internal.boxfilter3mex(intA, filterSize, normFactor, outType, outSize);

end

function options = parseInputs(intA, varargin)

% validate image
validateattributes(intA,{'double'},{'real','nonsparse','nonempty'},mfilename,'Integral Image',1);

if any([size(intA) ones(3-ndims(intA))] < 2)
    error(message('images:integralBoxFilter:intImage3TooSmall'));
end

options = struct(...
    'FilterSize',[3 3 3],...
    'NormalizationFactor',1/27,...
    'OutputSize',[]);

beginningOfNameVal = find(cellfun(@isstr,varargin),1);
if isempty(beginningOfNameVal)
    beginningOfNameVal = numel(varargin)+1;
end
numOptionalArgs = beginningOfNameVal-1;

if numOptionalArgs == 0
    %integralBoxFilter3(A);
elseif numOptionalArgs == 1
    options.FilterSize = images.internal.validateThreeDFilterSize(varargin{1});
    options.NormalizationFactor = 1/prod(options.FilterSize);
else
    error(message('images:validate:tooManyOptionalArgs'));
end

if any( [size(intA) ones(1,3-ndims(intA))]-1 < options.FilterSize )
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
    options.OutputSize = [size(intA) ones(1,3-ndims(intA))] - [options.FilterSize zeros(1,3-numel(options.FilterSize))];
end
end

function normalize = validateNormalizationFactor(normalize)

validateattributes(normalize, {'numeric'}, {'real','scalar','nonsparse'}, mfilename, 'NormalizationFactor');
normalize = double(normalize);

end