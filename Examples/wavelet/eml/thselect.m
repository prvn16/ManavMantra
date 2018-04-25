function thr = thselect(x,tptr)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

coder.internal.prefer_const(tptr);
RIGRSURE = strcmp(tptr,'rigrsure');
HEURSURE = strcmp(tptr,'heursure');
SQTWOLOG = strcmp(tptr,'sqtwolog');
MINIMAXI = strcmp(tptr,'minimaxi');
coder.internal.assert( RIGRSURE || HEURSURE || SQTWOLOG || MINIMAXI , ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
if isrow(x)
    xc = x';
else
    xc = x;
end
[n,m] = size(xc);
if RIGRSURE
    thr = rigrsure(xc);
elseif HEURSURE
    thr = heursure(xc);
elseif SQTWOLOG
    thr = repelem(sqrtwolog(n),m);
else % if MINIMAXI
    thr = repelem(minimaxi(n),m);
end

%--------------------------------------------------------------------------

function thr = rigrsure(x)
% Assumes input is a vector.
n = size(x,1);
m = size(x,2);

sx = sort(abs(x),1);
sx2 = sx.^2;
N1 = repmat((n-2*(1:n))',1,m);
N2 = repmat((n-1:-1:0)',1,m);
CS1 = cumsum(sx2,1);
risks = (N1+CS1+N2.*sx2)./n;
[~,best] = min(risks,[],1);
% thr will be row vector
thr = sx(best);

%--------------------------------------------------------------------------

function thr = heursure(x)
% Assumes input is a vector.
n = size(x,1);
hthr = (2*log(n)).^0.5;
eta = sum(abs(x).^2-n,1)./n;
crit = (log(n)/log(2))^(1.5)/(n.^0.5);
thr = thselect(x,'rigrsure');
thr(thr > hthr) = hthr;
thr(eta < crit) = hthr;


%--------------------------------------------------------------------------

function thr = sqrtwolog(n)
% Input is size(x,1).
coder.inline('always');
thr = sqrt(2*log(n));

%--------------------------------------------------------------------------

function thr = minimaxi(n)
% Input is size(x,1).
coder.inline('always');
if n <= 32
    thr = 0;
else
    thr = 0.3936 + 0.1829*(log(n)/log(2));
end

%--------------------------------------------------------------------------
