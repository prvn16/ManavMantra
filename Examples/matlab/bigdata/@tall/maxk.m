function varargout = maxk(A, k, varargin)
%MAXK   Return largest K elements from array
%
%   B = MAXK(A,k)
%   B = MAXK(A,k,dim)
%   B = MAXK(...,'ComparisonMethod',c)
%   [B,I] = MAXK(...)
%
%   See also MINK, SORT, TOPKROWS, MAX.

%   Copyright 2017 The MathWorks, Inc.

narginchk(2, inf);
nargoutchk(0, 2);
tall.checkIsTall(upper(mfilename), 1, A);
tall.checkNotTall(upper(mfilename), 1, k, varargin{:});

A = tall.validateType(A, mfilename, {...
    'numeric', 'logical', 'char', 'categorical', 'datetime', 'duration'}, 1);

fcn = str2func(mfilename);

[varargout{1:max(1,nargout)}] = minkmaxkCommon(fcn, A, k, varargin{:});
end