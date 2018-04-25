function stdX = std(x, flag, varargin)
%STD Standard deviation
%   Y = STD(X)
%   Y = STD(X,FLAG) where FLAG is 0 or 1
%   Y = STD(X,FLAG,DIM)
%   Y = STD(...,MISSING)
%
%   Limitations:
%   1) Weight vector is not supported.
%
%   See also: STD, TALL.

%   Copyright 2015-2017 The MathWorks, Inc.

x = tall.validateType(x, mfilename, {'numeric', 'logical', 'duration', 'datetime'}, 1);
if nargin < 2
    flag = 0;
end
tall.checkNotTall(upper(mfilename), 1, flag, varargin{:});

if nargin == 2 && isNonTallScalarString(flag)
    % Presume 'flag' is actually a 'missing' indicator
    varargin = {flag};
    flag = 0;
end

if ~(isnumeric(flag) && ~isobject(flag) && isscalar(flag))
    error(message('MATLAB:bigdata:array:WeightVectorNotSupported', upper(mfilename)));
end

if strcmp(tall.getClass(x), 'datetime')
    % Cannot support STD for datetime
    error(message('MATLAB:bigdata:array:FcnNotSupportedForType', ...
                  upper(mfilename), 'datetime'));
elseif strcmp(tall.getClass(x), 'duration')
    % This is essentially copied from the duration/std implementation
    x = milliseconds(x);
    % TODO: need to preserve Format field here.
    fixOutput = @(result) duration(0, 0, 0, result);
else
    fixOutput = @(result) result;
end

stdX = sqrt(var(x, flag, varargin{:}));
stdX = fixOutput(stdX);
end

