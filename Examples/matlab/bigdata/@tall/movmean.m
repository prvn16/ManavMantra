function Y = movmean(X, k, varargin)
%MOVMEAN   Moving mean value.
%   Y = MOVMEAN(X,K)
%   Y = MOVMEAN(X,[NB NF])
%   Y = MOVMEAN(...,DIM)
%   MOVMEAN(...,MISSING)
%   MOVMEAN(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVMEAN(...,'SamplePoints',T) is not supported
%
%   See also MOVMEAN

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 1);
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

if ~isempty(X.Adaptor.Class) && ~strcmpi('single', X.Adaptor.Class)
    % For movmean: output is always double except when input is single
    Y = setKnownType(Y, 'double');
end
end
