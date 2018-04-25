function Y = movprod(X, k, varargin)
%MOVPROD   Moving product value.
%   Y = MOVPROD(X,K)
%   Y = MOVPROD(X,[NB NF])
%   Y = MOVPROD(...,DIM)
%   MOVPROD(...,MISSING)
%   MOVPROD(...,'Endpoints',ENDPT)
%
%   Restrictions:
%   MOVPROD(...,'SamplePoints',T) is not supported
%
%   See also MOVPROD

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tall.checkIsTall(upper(mfilename), 1, X);
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 1);
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});
movFcn = str2func(mfilename);
Y = movcommon(X, k, movFcn, varargin{:});

if ~isempty(X.Adaptor.Class) && ~strcmpi('single', X.Adaptor.Class)
    % For movprod: output is always double except when input is single
    Y = setKnownType(Y, 'double');
end
end
