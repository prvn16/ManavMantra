function Y = movmax(X, k, varargin)
%MOVMAX   Moving maximum value.
%   Y = MOVMAX(X,K)
%   Y = MOVMAX(X,[NB NF])
%   Y = MOVMAX(...,DIM)
%   MOVMAX(...,MISSING)
%   MOVMAX(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVMAX(...,'SamplePoints',T) is not supported
%
%   See also MOVMAX

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
