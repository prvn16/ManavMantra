function Y = movmin(X, k, varargin)
%MOVMIN   Moving minimum value.
%   Y = MOVMIN(X,K)
%   Y = MOVMIN(X,[NB NF])
%   Y = MOVMIN(...,DIM)
%   MOVMIN(...,MISSING)
%   MOVMIN(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVMIN(...,'SamplePoints',T) is not supported
%
%   See also MOVMIN

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 1);
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

% The output always has same type as the input
Y = setKnownType(Y, X.Adaptor.Class);
end
