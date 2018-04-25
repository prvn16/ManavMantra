function out = integralBoxFilter(intA, varargin) %#codegen
%INTEGRALBOXFILTER 2-D box filtering of integral images

%   Copyright 2015 The MathWorks, Inc.

narginchk(1,4);

validateattributes(intA,{'double'}, ...
    {'real','nonsparse','nonempty'},mfilename,'Integral Image',1);

coder.internal.errorIf(any([size(intA,1),size(intA,2)] < 2), ...
    'images:integralBoxFilter:intImageTooSmall');

[normFactor,filterSize] = parseInputs(varargin{:});

% OutSize of Image = size(integralImage) - size(filter)
outSize = size(intA) - [filterSize(1:2),zeros(1,numel(size(intA))-2)];

out = coder.nullcopy(zeros(outSize,'like',intA));

nPlanes = coder.internal.prodsize(out,'above',2);

for p = 1:coder.internal.indexInt(nPlanes)
    parfor n = 1:coder.internal.indexInt(outSize(2))
        sC = n;
        eC = coder.internal.indexPlus(sC, coder.internal.indexInt(filterSize(2))); %#ok<PFBNS>
        for m = 1:coder.internal.indexInt( outSize(1)) %#ok<PFBNS>
            sR = m;
            eR = coder.internal.indexPlus(sR, coder.internal.indexInt(filterSize(1)));
            
            firstTerm  = intA(eR,eC,p); %#ok<PFBNS>
            secondTerm = intA(sR,sC,p);
            thirdTerm  = intA(sR,eC,p);
            fourthTerm = intA(eR,sC,p);
            
            regionSum = firstTerm + secondTerm - thirdTerm - fourthTerm;
            
            out(m,n,p) = normFactor * regionSum;
        end
    end
end
end

%--------------------------------------------------------------------------
function [NormalizationFactor, FilterSize] = parseInputs(varargin)

coder.inline('always');
coder.internal.prefer_const(varargin);

% Default values
FilterSizeDefault = [3,3];
NormalizationFactorDefault = 1/9;

if nargin > 0
    % If first input is FilterSize
    if ~ischar(varargin{1})
        % Validate FilterSize
        FilterSize = images.internal.validateTwoDFilterSize(varargin{1});
        % compute Norm factor
        NormalizationFactorDefault = 1/prod(FilterSize);
        beginNVIdx = 2;
    else
        % The first input is NV pair
        FilterSize = FilterSizeDefault;
        beginNVIdx = 1;
    end
    
    % Parse the VN pair for NormalizationFactor
    normFactor = parseNameValuePairs( ...
        NormalizationFactorDefault, ...
        varargin{beginNVIdx:end});
    NormalizationFactor = validateNormalizationFactor(normFactor);
    
else
    % No input params given use the default filter values
    FilterSize = FilterSizeDefault;
    NormalizationFactor = NormalizationFactorDefault;
end
end

%--------------------------------------------------------------------------
function normalizationFactor = parseNameValuePairs(normFactorDefault,varargin)

coder.inline('always');
coder.internal.prefer_const(normFactorDefault,varargin);

params = struct('NormalizationFactor',uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

normalizationFactor = eml_get_parameter_value( ...
    optarg.NormalizationFactor, ...
    normFactorDefault, ...
    varargin{:});
end

%--------------------------------------------------------------------------
function normalize = validateNormalizationFactor(normalizeIn)

coder.inline('always');
coder.internal.prefer_const(normalizeIn);

validateattributes(normalizeIn,{'numeric'}, ...
    {'real','scalar','nonsparse'}, ...
    mfilename,'NormalizationFactor');

normalize = double(normalizeIn);
end
