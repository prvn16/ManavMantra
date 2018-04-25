function Y = movstd(X, k, varargin)
%MOVSTD   Moving standard deviation value.
%   Y = MOVSTD(X,K)
%   Y = MOVSTD(X,[NB NF])
%   Y = MOVSTD(X,K,NRM)
%   Y = MOVSTD(...,DIM)
%   MOVSTD(...,MISSING)
%   MOVSTD(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVSTD(...,'SamplePoints',T) is not supported
%
%   See also MOVSTD

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 1);
X = lazyValidate(X, {@(z) isfloat(z) || islogical(z), 'MATLAB:movfun:integerInput'});
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

% Output type is same as input except that logical promotes to double
if ~isempty(X.Adaptor.Class) && strcmpi('logical', X.Adaptor.Class)
    Y = setKnownType(Y, 'double');
end

end
