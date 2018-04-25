function Y = movvar(X, k, varargin)
%MOVVAR   Moving variance value.
%   Y = MOVVAR(X,K)
%   Y = MOVVAR(X,[NB NF])
%   Y = MOVVAR(X,K,NRM)
%   Y = MOVVAR(...,DIM)
%   MOVVAR(...,MISSING)
%   MOVVAR(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVVAR(...,'SamplePoints',T) is not supported
%
%   See also MOVVAR

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric' 'logical'}, 1);
X = lazyValidate(X, {@(z) isfloat(z) || islogical(z), 'MATLAB:movfun:integerInput'});
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

% Output type is same as input except that logical promotes to double
if ~isempty(X.Adaptor.Class) && strcmpi('logical', X.Adaptor.Class)
    Y = setKnownType(Y, 'double');
end

end
