function [c,l] = wavedec(x,n,IN3,IN4)
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
XISROW = coder.internal.isConst(isrow(x)) && isrow(x);
XISCOL = coder.internal.isConst(iscolumn(x)) && iscolumn(x);
VERTCAT = XISCOL && ~XISROW;
if VERTCAT
    c = zeros(0,1);
    l = zeros(n + 2,1);
    xv = x(:);
else
    c = zeros(1,0);
    l = zeros(1,n + 2);
    xv = x(:).';
end
if isempty(x)
    return
end
l(n + 2) = length(x);
for k = 1:n
    [xv,d] = dwt(xv,Lo_D,Hi_D); % decomposition
    % store detail
    if VERTCAT
        c = [d;c]; %#ok<AGROW>
        l(n - k + 2) = size(d,1);     % store length
    else
        c = [d,c]; %#ok<AGROW>
        l(n - k + 2) = size(d,2);     % store length
    end
end

% Last approximation.
if VERTCAT
    c = [xv;c];
    l(1) = size(xv,1);
else
    c = [xv,c];
    l(1) = size(xv,2);
end

