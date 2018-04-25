function c = wthcoef2(o,c,s,niv,thr,sorh)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Check arguments.
coder.internal.assert(nargin >= 3, ...
    'Wavelet:FunctionInput:NotEnough_ArgNum');
coder.internal.assert(nargin ~= 5, ...
    'Wavelet:FunctionInput:Invalid_ArgNum');
coder.internal.prefer_const(o);
o1 = lower(o(1));
if o1 == 'a'
    coder.internal.assert(nargin <= 3, ...
        'Wavelet:FunctionInput:TooMany_ArgNum');
    n2z = prodRowOne(s);
    for k = 1:n2z
        c(k) = 0;
    end
    return
end
coder.internal.assert(o1=='h' || o1=='v' || o1=='d' || o1=='t', ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
nmax = size(s,1) - 2;
coder.internal.assert(allIntInRange(niv,1,nmax), ...
    'Wavelet:FunctionArgVal:Invalid_LevVal');
coder.internal.assert(nargin < 6 || ...
    (length(niv) == length(thr) && allNonneg(thr)), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
% Compression.
szs1 = coder.internal.indexInt(size(s,1));
for k = 1:length(niv)
    kn = szs1 - coder.internal.indexInt(niv(k));
    [first,last] = calcFirstLast(o1,s,kn);
    if nargin == 6
        c(first:last) = wthresh(c(first:last),sorh,thr(k));
    else
        c(first:last) = 0;
    end
end

%--------------------------------------------------------------------------

function n = prodRowOne(s)
% n = prod(s(1,:)) without forming the temporary array s(1,:).
n = coder.internal.indexInt(1);
nc = coder.internal.prodsize(s,'above',1);
for k = 1:nc
    n = coder.internal.indexTimes(n,s(1,k));
end

%--------------------------------------------------------------------------

function p = allNonneg(x)
% Return true iff x(k) >= 0 for all valid k.
p = true;
for k = 1:numel(x)
    p = p && (x(k) >= 0);
end

%--------------------------------------------------------------------------

function [first,last] = calcFirstLast(o1,s,kn)
coder.internal.prefer_const(o1);
first = coder.internal.indexTimes(s(1,1),s(1,2)) + 1;
for k = 2:kn-1
    first = first + 3*coder.internal.indexTimes(s(k,1),s(k,2));
end
add = coder.internal.indexTimes(s(kn,1),s(kn,2));
if o1 == 'v'
    first = first + add;
elseif o1 == 'd'
    first = first + 2*add;
end
if o1 == 't'
    last = first + 3*add - 1;
else
    last = first + add - 1;
end

%--------------------------------------------------------------------------
