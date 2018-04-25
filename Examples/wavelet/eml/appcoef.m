function a = appcoef(c,l,varargin)
%MATLAB Code Generation Library Function

%   Limitations:
%   * Requires variable sizing.

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Check arguments.
narginchk(2,5)
coder.internal.prefer_const(varargin);
rmax = coder.internal.indexInt(length(l));
nmax = rmax - 2;
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfiltersConst(varargin{1},'r');
    next = 2;
else
    Lo_R = varargin{1};
    Hi_R = varargin{2};
    next = 3;
end
if nargin >= next + 2
    n = varargin{next};
else
    n = nmax;
end
coder.internal.assert(isscalar(n) && n >= 0 && n <= nmax && ...
    n == floor(n), ...
    'Wavelet:FunctionArgVal:Invalid_LevVal');
coder.varsize('acol');
% Initialization.
% Since the output vector may grow from a scalar, we need to take some
% care to grow it in a consistent direction. We will grow it as a column
% vector and then transpose it before returning if the input is a
% variable-length row vector.
acol = coder.nullcopy(zeros(l(1),1,'like',c));
for k = 1:l(1)
    acol(k) = c(k);
end
% Iterated reconstruction.
imax = rmax + 1;
for p = nmax:-1:n+1
    d = detcoef(c(:),l(:),p); % extract detail
    acol = idwt(acol(:),d(:),Lo_R,Hi_R,l(imax - p));
end
if coder.internal.isConst(iscolumn(c)) && iscolumn(c) && ...
        ~(coder.internal.isConst(isscalar(c)) && isscalar(c))
    a = acol;
else
    a = acol.';
end
