function BW = imbinarize(I,varargin) %#codegen
%imbinarize Binarize image by thresholding.

%   Copyright 2015 The MathWorks, Inc.

%   Syntax
%   ------
%
%       BW = imbinarize(I)
%       BW = imbinarize(I,method)
%       BW = imbinarize(I,'adaptive',Param,Value,...)
%       BW = imbinarize(I,t)
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
%      method:
%        string with value: 'global' or 'adaptive'
%        default: 'global'
%
%      Sensitivity:
%        numeric
%        real
%        non-sparse
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
%      t:
%        numeric
%        real
%        non-sparse
%        2d
%        either scalar or matrix of the same size as I
%
%   Output Specs
%   ------------
%
%     BW:
%       logical
%       2D matrix
%       same size as I
%

% Validate the input image
validateImage(I);

% Parse and validate optional inputs
[isNumericThreshold,options] = parseOptionalInputs(I,varargin{:});
coder.internal.prefer_const(isNumericThreshold,options);

if isNumericThreshold
    % BW = imbinarize(I,t)
    BW = binarize(I,options.t);
else
    if strcmp(options.method,'global')
        % BW = imbinarize(I,'global')
        t = computeGlobalThreshold(I);
    else
        % BW = imbinarize(I,'adaptive',...)
        t = adaptthresh(I,options.sensitivity,'ForegroundPolarity',options.polarity);
    end
    BW = binarize(I,t);
end

%--------------------------------------------------------------------------
function BW = binarize(I,T)

% Map a threshold in [0,1] to the range of the image (e.g., [-128,127])
range = getrangefromclass(I);

% We need to distinguish b/w the scalar and matrix cases
% to accomodate variable sizing for the threshold input
if isscalar(T)
    BW = I > (range(1) + (range(2)-range(1))*T(1));
else
    BW = I > (range(1) + (range(2)-range(1))*T);
end

%--------------------------------------------------------------------------
function T = computeGlobalThreshold(I)
% Otsu's threshold is used to compute the global threshold. We convert
% floating point images to uint8 prior to computing the image histogram to
% avoid issues with NaN/Inf values in the input data. im2uint8 nicely
% handles these so that we get a clean histogram for otsuthresh. For other
% types, we compute the histogram in the native type, using 256 bins (this
% is the default in imhist).

if isfloat(I)
    T = otsuthresh( imhist(im2uint8(I)) );
else
    T = otsuthresh( imhist(I) );
end

%--------------------------------------------------------------------------
function validateImage(I)

supportedClasses = {'uint8','uint16','uint32','int8', ...
                    'int16','int32','single','double'};
supportedAttribs = {'real','nonsparse','2d'};
validateattributes(I,supportedClasses,supportedAttribs,mfilename,'I');

%--------------------------------------------------------------------------
% Parse and validate optional inputs
% options is a struct with the following fields:
%    - t:          user-specified threshold
%    - method:     string 'global' or 'adaptive'
%    - sensitivty: scalar in [0,1]
%    - polarity:   string 'bright' or 'dark'
% If the user has specified a threshold, then isNumericThreshold is true.
function [isNumericThreshold,options] = parseOptionalInputs(I,varargin)

narginchk(1,6);

% Default parameters
defaultMethod      = 'global';
defaultSensitivity = 0.5;
defaultPolarity    = 'bright';

% True if the syntax used is imbinarize(I,t)
isNumericThreshold = ~isempty(varargin) && ~ischar(varargin{1});

if isNumericThreshold
    % imbinarize(I,t)
    options.t = validateThreshold(varargin{1},I);
    coder.internal.errorIf(numel(varargin)>1, ...
        'MATLAB:TooManyInputs');
else
    if isempty(varargin)
        % imbinarize(I)
        options.method = defaultMethod;
    else
        method = validateMethod(varargin{1});
        options.method = method;
        
        if strcmp(method,defaultMethod)
            % imbinarize(I,'global')
            coder.internal.errorIf(numel(varargin)>1, ...
                'MATLAB:TooManyInputs');
        else
            % imbinarize(I,'adaptive',...)
            [sensitivity,polarity] = parseNameValuePairs( ...
                defaultSensitivity,defaultPolarity,varargin{2:end});
            % Validate
            options.sensitivity = validateSensitivity(sensitivity);
            options.polarity    = validatePolarity(polarity);
        end
    end
end

%--------------------------------------------------------------------------
function T = validateThreshold(T_,I)

validateattributes(T_,{'numeric'},{'real','nonsparse','2d'}, ...
    mfilename,'Threshold',2);

% t must be a scalar or have the same size as I
coder.internal.errorIf(~isscalar(T_) && ~isequal(size(T_),size(I)), ...
    'images:imbinarize:badSizedThreshold');

T = double(T_);

%--------------------------------------------------------------------------
function method = validateMethod(method_)

method = validatestring(method_,{'global','adaptive'},mfilename,'Method',2);

%--------------------------------------------------------------------------
% Parse optional PV pairs without validating
function [sensitivity,polarity] = parseNameValuePairs( ...
    defaultSensitivity,defaultPolarity,varargin)

% Parse optional PV pairs: 'Sensitivity' and 'ForegroundPolarity'

params = struct( ...
    'Sensitivity',       uint32(0), ...
    'ForegroundPolarity',uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

sensitivity = eml_get_parameter_value( ...
    optarg.Sensitivity, ...
    defaultSensitivity, ...
    varargin{:});

polarity = eml_get_parameter_value( ...
    optarg.ForegroundPolarity, ...
    defaultPolarity, ...
    varargin{:});

%--------------------------------------------------------------------------
function sensitivity = validateSensitivity(sensitivity_)

validateattributes(sensitivity_,{'numeric'}, ...
    {'real','nonsparse','scalar','nonnegative','<=',1}, ...
    mfilename,'Sensitivity');

sensitivity = double(sensitivity_);

%--------------------------------------------------------------------------
function polarity = validatePolarity(polarity_)

polarity = validatestring(polarity_,{'bright','dark'}, ...
                          mfilename,'ForegroundPolarity');
