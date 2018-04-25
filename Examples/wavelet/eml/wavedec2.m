function [c,s] = wavedec2(x,n,IN3,IN4)
%MATLAB Code Generation Library Function

%   Limitations:
%   * With three inputs, i.e. when suppling a "wname", the third input must
%     be constant.
%   * Variable sizing is required.

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Check arguments.
narginchk(3,4);
if nargin == 3
    coder.internal.prefer_const(IN3);
    [Lo_D,Hi_D] = wfiltersConst(IN3,'d');
else
    Lo_D = IN3;
    Hi_D = IN4;
end

% Initialization.
coder.varsize('c');
coder.varsize('xv');
nd = eml_ndims(x);
s = zeros(n + 2,nd);
c = zeros(1,0);
if isempty(x)
    return
end
xv = x;
for j = 1:nd
    s(n + 2,j) = size(xv,j);
end
for k = 1:n
    [xv,h,v,d] = dwt2(xv,Lo_D,Hi_D); % decomposition
    c = [h(:).',v(:).',d(:).',c]; %#ok<AGROW> % store details
    for j = 1:nd
        s(n - k + 2,j) = size(xv,j); % store size
    end
end

% Last approximation.
c = [xv(:).',c];
for j = 1:nd
    s(1,j) = size(xv,j); % store size
end
