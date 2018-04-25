function varargout = mink(A, k, varargin)
%MINK   Return smallest K elements from array
%
%   B = MINK(A,k)
%   B = MINK(A,k,dim)
%   B = MINK(...,'ComparisonMethod',c)
%   [B,I] = MINK(...)
%
%   See also MAXK, SORT, TOPKROWS, MIN.

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