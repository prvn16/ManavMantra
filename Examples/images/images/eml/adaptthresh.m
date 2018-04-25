function T = adaptthresh(I_,varargin) %#codegen
%ADAPTTHRESH Adaptive image threshold using local first-order statistics.

%   Copyright 2015 The MathWorks, Inc.

%   Syntax
%   ------
%
%       T = adaptthresh(I)
%       T = adaptthresh(I,sensitivity)
%       T = adaptthresh(I,sensitivity,Param,Value,...)
%
%   Input Specs
%   -----------
%
%      I:
%        real
%        non-sparse
%        2d
%        uint8, uint16, uint32, int8, int16, int32, single or double
%
%      sensitivity:
%        numeric
%        real
%        scalar
%        non-negative
%        <= 1
%        default: 0.5
%        converted to double
%
%      ForegroundPolarity:
%        string with value either 'bright' or 'dark'
%        default: 'bright'
%
%      Statistic:
%        string with value: 'mean', 'median', or 'gaussian'
%        default: 'mean'
%
%      NeighborhoodSize: (images.internal.validateTwoDFilterSize)
%        numeric
%        real
%        non-sparse
%        non-empty
%        positive
%        integer
%        odd
%        default: 2*floor(size(I)/16)+1
%        converted to double
%        reshaped to 1-by-2
%
%   Output Specs
%   ------------
%
%     T:
%       double
%       2D matrix
%       same size as I
%

% Validate I
validateImage(I_);

% Parse and validate optional inputs
[sensitivity,isFBright,statistic,nhoodSize] = parseOptionalInputs(I_,varargin{:});
coder.internal.prefer_const(sensitivity,isFBright,statistic,nhoodSize);

% Return early if the image is empty
if isempty(I_)
    T = zeros(size(I_));
    return
end

% Convert image to double
I = convertToDouble(I_);

% Convert sensitivity in [0,1] to a scale factor
scaleFactor = sensitivityToScaleFactor(sensitivity,isFBright);

switch statistic
    case 'mean'
        T = localMeanThresh(I,nhoodSize,scaleFactor);
    case 'median'
        T = localMedianThresh(I,nhoodSize,scaleFactor);
    case 'gaussian'
        T = localGaussThresh(I,nhoodSize,scaleFactor);
    otherwise
        assert(false,'Unknown statistic string.')
end

% Restrict T to [0,1].
% Saturate output values to lie in [0,1]
% data range for double-precision images.
for k = 1:numel(T)
    T(k) = max(min(T(k),1),0);
end

%--------------------------------------------------------------------------
% Validate the input image
function validateImage(I)

supportedClasses = {'uint8','uint16','uint32','int8', ...
                    'int16','int32','single','double'};
supportedAttribs = {'real','nonsparse','2d'};
validateattributes(I,supportedClasses,supportedAttribs,mfilename,'I');

%--------------------------------------------------------------------------
% Parse and validate optional inputs
function [sensitivity,isFBright,statistic,nhoodSize] = parseOptionalInputs(I,varargin)

narginchk(1,8);

defaultSensitivity        = 0.5;
defaultForegroundPolarity = 'bright';
defaultStatistic          = 'mean';
defaultNeighborhoodSize   = 2*floor(size(I)/16)+1;

% Parse
if nargin > 1
    if ~ischar(varargin{1})
        % adaptthresh(I,sensitivity,...)
        sensitivity = validateSensitivity(varargin{1});
        idxBeginNVPairs = 2;
    else
        % adaptthresh(I,Name,Value)
        sensitivity = defaultSensitivity;
        idxBeginNVPairs = 1;
    end
    [polarity,statistic_,nhoodSize_] = parseNameValuePairs( ...
        defaultForegroundPolarity,defaultStatistic,defaultNeighborhoodSize, ...
        varargin{idxBeginNVPairs:end});
else
    sensitivity = defaultSensitivity;
    polarity   = defaultForegroundPolarity;
    statistic_  = defaultStatistic;
    nhoodSize_  = defaultNeighborhoodSize;
end

% Validate ForegroundPolarity
isFBright = validateForegroundPolarity(polarity);

% Validate Statistic
statistic = validateStatistic(statistic_);

% Validate NeighborhoodSize
nhoodSize = validateFilterSize(nhoodSize_);

%--------------------------------------------------------------------------
function sensitivity = validateSensitivity(sensitivity_)

validateattributes(sensitivity_,{'numeric'}, ...
    {'real','scalar','nonnegative','<=',1},mfilename,'sensitivity',2);
sensitivity = double(sensitivity_);

%--------------------------------------------------------------------------
% Parse the (Name,Value) pairs
function [polarity,statistic,nhoodSize] = parseNameValuePairs( ...
    defaultForegroundPolarity,defaultStatistic,defaultNeighborhoodSize,varargin)

% Parse optional PV pairs:
% 'ForegroundPolarity', 'Statistic', 'NeighborhoodSize'

params = struct( ...
    'ForegroundPolarity',uint32(0), ...
    'Statistic',         uint32(0), ...
    'NeighborhoodSize',  uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

polarity = eml_get_parameter_value( ...
    optarg.ForegroundPolarity, ...
    defaultForegroundPolarity, ...
    varargin{:});

statistic = eml_get_parameter_value( ...
    optarg.Statistic, ...
    defaultStatistic, ...
    varargin{:});

nhoodSize = eml_get_parameter_value( ...
    optarg.NeighborhoodSize, ...
    defaultNeighborhoodSize, ...
    varargin{:});

function filterSize = validateFilterSize(filterSizeIn)

    coder.inline('always');
    coder.internal.prefer_const(filterSizeIn);

    validateattributes(filterSizeIn,{'numeric'}, ...
    {'real','nonsparse','nonempty','positive','integer','odd'}, ...
    mfilename,'filterSize');
    
    filterSize = coder.nullcopy(zeros(1,2));
    
    if isscalar(filterSizeIn)
        filterSize(:) = [double(filterSizeIn),double(filterSizeIn)];
    else
        coder.internal.errorIf(numel(filterSizeIn) ~= 2, ...
            'images:validate:badVectorLength','filterSize',2);

        filterSize(:) = [double(filterSizeIn(1)),double(filterSizeIn(2))];
    end
    

%--------------------------------------------------------------------------
function isFBright = validateForegroundPolarity(polarity_)

polarity = validatestring(polarity_,{'bright','dark'}, ...
    mfilename,'ForegroundPolarity');

isFBright = isequal(polarity(1),'b');

%--------------------------------------------------------------------------
function statistic = validateStatistic(statistic_)

statistic = validatestring(statistic_,{'mean','median','gaussian'}, ...
    mfilename,'Statistic');


%--------------------------------------------------------------------------
% im2double is not supported for all classes. This function does the
% conversion for other classes too.
function I = convertToDouble(I_)

switch class(I_)
    case {'uint8','uint16','int16','single','double'}
        I = im2double(I_);
    case {'int8','uint32','int32'}
        type = class(I_);
        range = double(intmax(type)) - double(intmin(type));
        I = (double(I_) - double(intmin(type))) / range;
    otherwise
        assert('Incorrect class');
end

%--------------------------------------------------------------------------
% Convert sensitivity on a 0-1 scale to scaleFactor. For images with a
% bright foreground, map the sensitivity in [0, 1] to scale factor in [1.6,
% 0.6]. For images with a dark foreground, map the sensitivity in [0, 1] to
% scale factor in [0.4, 1.4]. So, a sensitivity of 0.5 corresponds to a
% scale factor of 1.1 for polarity 'bright' and 0.9 for polarity 'dark'.
% This is done to assure that the default choice (0.5) for sensitivity maps
% to a 'good' scale factor for either polarity.
function scaleFactor = sensitivityToScaleFactor(sensitivity,isFBright)

if isFBright
    scaleFactor = 0.6 + (1-sensitivity);
else
    scaleFactor = 0.4 + sensitivity;
end

%--------------------------------------------------------------------------
function T = localMeanThresh(I,nhoodSize,scaleFactor)

T = imboxfilt(I,nhoodSize, ...
    'NormalizationFactor',scaleFactor/prod(nhoodSize), ...
    'Padding','replicate');

%--------------------------------------------------------------------------
function T = localMedianThresh(I,nhoodSize,scaleFactor)

T = scaleFactor * medfilt2(I,nhoodSize,'symmetric');

%--------------------------------------------------------------------------
function T = localGaussThresh(I,nhoodSize,scaleFactor)

T = scaleFactor * imgaussfilt(I,nhoodSize);
