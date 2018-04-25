function Y = movmedian(X, k, varargin)
%MOVMEDIAN   Moving median value.
%   Y = MOVMEDIAN(X,K)
%   Y = MOVMEDIAN(X,[NB NF])
%   Y = MOVMEDIAN(...,DIM)
%   MOVMEDIAN(...,MISSING)
%   MOVMEDIAN(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVMEDIAN(...,'SamplePoints',T) is not supported
%
%   See also MOVMEDIAN

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 1);
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

if ~isempty(X.Adaptor.Class) && strcmpi('logical', X.Adaptor.Class)
    % For movmedian: output is double for logical input
    Y = setKnownType(Y, 'double');
end
end
