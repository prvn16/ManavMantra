function Y = movsum(X, k, varargin)
%MOVSUM   Moving sum value.
%   Y = MOVSUM(X,K)
%   Y = MOVSUM(X,[NB NF])
%   Y = MOVSUM(...,DIM)
%   MOVSUM(...,MISSING)
%   MOVSUM(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVSUM(...,'SamplePoints',T) is not supported
%
%   See also MOVSUM

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 1);
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

if ~isempty(X.Adaptor.Class) && ~strcmpi('single', X.Adaptor.Class)
    % For movsum: output is always double except when input is single
    Y = setKnownType(Y, 'double');
end
end
