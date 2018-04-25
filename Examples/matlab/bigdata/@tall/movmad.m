function Y = movmad(X, k, varargin)
%MOVMAD   Moving median absolute deviation value.
%   Y = MOVMAD(X,K)
%   Y = MOVMAD(X,[NB NF])
%   Y = MOVMAD(...,DIM)
%   MOVMAD(...,MISSING)
%   MOVMAD(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVMAD(...,'SamplePoints',T) is not supported
%
%   See also MOVMAD

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 1);
X = lazyValidate(X, {@isreal, 'MATLAB:movfun:complexInput'});
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

% Output type is same as input except that logical promotes to double
if ~isempty(X.Adaptor.Class) && strcmpi('logical', X.Adaptor.Class)
    Y = setKnownType(Y, 'double');
end

end
