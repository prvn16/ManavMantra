function c = wthcoef(o,c,l,niv,percent,sorh)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Check arguments.
narginchk(3,6);
ONE = coder.internal.indexInt(1);
coder.internal.prefer_const(o);
if nargin >= 4
    lenniv = coder.internal.indexInt(length(niv));
end
if nargin >= 5
    lenpercent = coder.internal.indexInt(length(percent));
end
if nargin == 6
    coder.internal.prefer_const(sorh);
end
o1 = lower(o(1));
if o1 == 'a'
    coder.internal.assert(nargin == 3, ...
        'Wavelet:FunctionInput:TooMany_ArgNum');
    c(1:l(1)) = 0;  
    return
end
rmax = coder.internal.indexInt(length(l));
nmax = rmax - 2;
coder.internal.assert(allIntInRange(niv,ONE,nmax), ...
    'Wavelet:FunctionArgVal:Invalid_LevVal');
if o1 == 'd' && nargin == 5
    coder.internal.assert(lenniv == lenpercent && ...
        isInRange(percent,0,100), ...
        'Wavelet:FunctionArgVal:Invalid_ArgVal');
elseif o1 == 't'
    coder.internal.assert(nargin >= 5, ...
        'Wavelet:FunctionInput:NotEnough_ArgNum')
    coder.internal.assert(lenniv == lenpercent && ...
        isInRange(percent,0), ...
        'Wavelet:FunctionArgVal:Invalid_ArgVal');
end

% Calculate the following without using COLON:
% first = cumsum(l) + 1;
% first = first(end-2:-1:1);
% ld    = l(rmax-1:-1:2);
% last  = first+ld-1;
first = coder.nullcopy(zeros(1,nmax,coder.internal.indexIntClass));
ld = coder.nullcopy(zeros(1,nmax,coder.internal.indexIntClass));
for k = 1:nmax
    ld(k) = coder.internal.indexInt(l(rmax - k));
end
first(nmax) = coder.internal.indexInt(l(1)) + 1;
for k = 2:nmax
    first(nmax - k + 1) = first(nmax - k + 2) + ld(nmax - k + 2);
end

if o1 == 'd' && nargin == 5
    for k = 1:lenniv
        p = niv(k);
        pc = percent(k);
        % cfs = c(first(p):last(p));
        cfs = coder.nullcopy(zeros(1,ld(p),'like',c));
        for j = 1:ld(p)
            cfs(j) = c(first(p) - 1 + j);
        end
        [~,ind] = sort(abs(cfs));
        annul = coder.internal.indexInt(fix(double(ld(p))*pc/100));
        % cfs(ind(1:annul)) = 0;
        for j = 1:annul
            cfs(ind(j)) = 0;
        end
        % c(first(p):last(p)) = cfs;
        for j = 1:ld(p)
            c(first(p) - 1 + j) = cfs(j);
        end
    end
elseif o1 == 't'
    for k = 1:lenniv
        p = niv(k);
        pc = percent(k); % thresholds
        % cfs = c(first(p):last(p));
        cfs = coder.nullcopy(zeros(1,ld(p),'like',c));
        for j = 1:ld(p)
            cfs(j) = c(first(p) - 1 + j);
        end
        cfs = wthresh(cfs,sorh,pc);
        % c(first(p):last(p)) = cfs;
        for j = 1:ld(p)
            c(first(p) - 1 + j) = cfs(j);
        end
    end
else
    for k = 1:lenniv
        p = niv(k);
        % c(first(p):last(p)) = 0;
        for j = 1:ld(p)
            c(first(p) - 1 + j) = 0;
        end
    end
end

%--------------------------------------------------------------------------

function p = isInRange(x,low,high)
% Return true if all(x >= low) && all(x <= high). If nargin == 2, only
% checks that all(x >= low).
p = true;
if nargin == 2
    for k = 1:numel(x)
        p = p && x(k) >= low;
    end
else
    for k = 1:numel(x)
        p = p && x(k) >= low && x(k) <= high;
    end
end
        
%--------------------------------------------------------------------------
