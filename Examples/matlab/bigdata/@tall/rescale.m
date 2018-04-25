function R = rescale(A, varargin)
%RESCALE  Rescales the range of data.
%   R = RESCALE(A)
%   R = RESCALE(A,B,C)
%   R = RESCALE(...,'InputMin',IMIN)
%   R = RESCALE(...,'InputMax',IMAX)
%
%   Limitations:
%   The inputs B, C, IMIN, and IMAX must not have more than one row.
%
%   Example:
%       % Clip all entries to [3,8] and then rescale all entries to [-1,1]
%       a = tall((1:10)');
%       r = rescale(a,-1,1,'InputMin',3,'InputMax',8)
%
%   See also RESCALE, TALL.

%   Copyright 2017 The MathWorks, Inc.

% Early abort for known empties
if A.Adaptor.isKnownEmpty()
    R = elementfun(@(x) rescale(x, varargin{:}), A);
    return
end

% Process inputs
[A, a, b, inputMin, inputMax] = preprocessInputs(A, varargin{:});

% Perform calculation.
R = elementfun(@iScaleValues, A, a, b, inputMin, inputMax);

% Output type will be double unless any input was single
R.Adaptor = iDeduceOutputAdaptor(R.Adaptor, A, a, b, inputMin, inputMax);
end


%--------------------------------------------------------------------------
function R = iScaleValues(A, a, b, inputMin, inputMax)
% Perform the actual rescaling. Note that all operations are elementwise
% across the five arguments, with dimension expansion.

R = rescale(A, a, b, 'InputMin', inputMin, 'InputMax', inputMax);

if isempty(A)
    % The MATLAB function sometimes returns the incorrect output type for empty
    % chunks of non-empty arrays (gives double where it should be single). Fix that now. 
    clz = cellfun(@class, {A,a,b,inputMin,inputMax}, 'UniformOutput', false);
    if any(strcmp(clz, "single"))
        R = single(R);
    end
end

end

%--------------------------------------------------------------------------
function [A, a, b, inputMin, inputMax] = preprocessInputs(A, varargin)
% Parse RESCALE inputs

% A must be tall and numeric
tall.checkIsTall(upper(mfilename), 1, A);
A = iValidate(A, {@(x) (isnumeric(x) || islogical(x)) && isreal(x), 'MATLAB:rescale:InvalidA'});

% Parse the remaining arguments
parser = inputParser;
addOptional(parser, 'a', 0)
addOptional(parser, 'b', 1)
addParameter(parser, 'InputMin', nan)
addParameter(parser, 'InputMax', nan)
try
    parser.parse(varargin{:});
catch err
    % Rescale has its own parser error messages
    switch err.identifier
        case 'MATLAB:InputParser:ParamMissingValue'
            error(message('MATLAB:rescale:KeyWithoutValue'));
        otherwise
            error(message('MATLAB:rescale:ParseFlags'));
    end
end

a = parser.Results.a;
b = parser.Results.b;
inputMin = parser.Results.InputMin;
inputMax = parser.Results.InputMax;

% If one of a,b was supplied, then both must be
aSupplied = ~ismember('a',parser.UsingDefaults);
bSupplied = ~ismember('b',parser.UsingDefaults);
if aSupplied
    if bSupplied
        % User specified the bounds, so validate them
        a = iValidate(a, {@(x) isnumeric(x) && isreal(x), 'MATLAB:rescale:InvalidOutputRange'});
        b = iValidate(b, {@(x) isnumeric(x) && isreal(x), 'MATLAB:rescale:InvalidOutputRange'});
        if ~istall(a) && size(a,1)~=1
            error(message('MATLAB:rescale:NumberDimsOut'));
        end
        if ~istall(b) && size(b,1)~=1
            error(message('MATLAB:rescale:NumberDimsOut'));
        end
    else
        % Only one bound specified.
        error(message('MATLAB:rescale:RequiredThirdInput'));
    end
end

% Set input range if not set above, otherwise validate.
userInputRange = false;
if ismember('InputMin', parser.UsingDefaults)
    % Try to use metadata if set
    inputMin = iGetLimitFromMetadata(A, 'Min1OmitNaN', @(x) min(x(:)));
    if isempty(inputMin)
        % Not already known, so calculate it.
        inputMin = reducefun(@iMinElement, A);
    end
else
    inputMin = iValidate(inputMin, {@(x) isnumeric(x) && isreal(x), 'MATLAB:rescale:InvalidInputMin'});
    userInputRange = true;
end
if ismember('InputMax', parser.UsingDefaults)
    inputMax = iGetLimitFromMetadata(A, 'Max1OmitNaN', @(x) max(x(:)));
    if isempty(inputMax)
        % Not already known, so calculate it.
        inputMax = reducefun(@iMaxElement, A);
    end
else
    inputMax = iValidate(inputMax, {@(x) isnumeric(x) && isreal(x), 'MATLAB:rescale:InvalidInputMax'});
    userInputRange = true;
end
% If the user specified either of the input bounds, check them
if userInputRange
    % Make sure both min and max have exactly one row, unless tall
    if ~istall(inputMin) && size(inputMin,1)~=1
        error(message('MATLAB:rescale:NumberDimsInLower'));
    end
    if ~istall(inputMax) && size(inputMax,1)~=1
        error(message('MATLAB:rescale:NumberDimsInUpper'));
    end
end

end % preprocessInputs

%--------------------------------------------------------------------------
function x = iValidate(x, pred)
% Helper to validate an argument that may be tall or in memory. For tall
% inputs the validation is deferred. For in-memory it is immediate.
if istall(x)
    x = lazyValidate(x, pred);
else
    check = pred{1};
    err = pred(2:end);
    if ~check(x)
        error(message(err{:}));
    end
end
end

%--------------------------------------------------------------------------
function y = iMinElement(x)
% Find the max element of x. inf if empty so that other values take precedence.
if isempty(x)
    y = nan;
else
    y = min(x(:));
end
end

%--------------------------------------------------------------------------
function y = iMaxElement(x)
% Find the max element of x. -inf if empty so that other values take precedence.
if isempty(x)
    y = nan;
else
    y = max(x(:));
end
end

%--------------------------------------------------------------------------
function adap = iDeduceOutputAdaptor(adap, A, a, b, inputMin, inputMax)
% Try to work out the output type. If any input is single, the output is
% single. Otherwise double or unknown.
clz = {
    tall.getClass(A)
    tall.getClass(a)
    tall.getClass(b)
    tall.getClass(inputMin)
    tall.getClass(inputMax)
    };

if any(ismember("single", clz))
    % If any input is single, result will be too.
    clzAdap = matlab.bigdata.internal.adaptors.getAdaptorForType('single');
    adap = clzAdap.copySizeInformation(adap);
elseif any(cellfun(@isempty, clz))
    % At least one is unknown, so result is unknown
else
    % All known and none is single. Must be double.
    clzAdap = matlab.bigdata.internal.adaptors.getAdaptorForType('double');
    adap = clzAdap.copySizeInformation(adap);
end

end

%--------------------------------------------------------------------------
function value = iGetLimitFromMetadata(A, name, fcn)
% Extract some named metadata, and if it exists summarize it using fcn.
value = [];
metadata = hGetMetadata(hGetValueImpl(A));
if ~isempty(metadata)
    [gotValue, v] = getValue(metadata, name);
    if gotValue
        value = fcn(v);
    end
end
end
