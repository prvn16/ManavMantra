function a = appcoef2(c,s,varargin)
%MATLAB Code Generation Library Function

%   Limitations:
%   * Requires variable sizing.

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Check arguments.
narginchk(2,5)
coder.internal.prefer_const(varargin);
rmax = coder.internal.indexInt(size(s,1));
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
coder.varsize('a');
% Initialization.
nl   = s(1,1);
nc   = s(1,2);
coder.varsize('a');
if length(s(1,:))<3
    a = zeros(nl,nc);
else
    a = zeros(nl,nc,3);
end
a(:) = c(1:numel(a));
% Iterated reconstruction.
rm = rmax + 1;
for p = nmax:-1:n+1
    [h,v,d] = detcoef2('all',c,s,p); % extract detail
    a = idwt2(a,h,v,d,Lo_R,Hi_R,s(rm - p,:));
end
