function varargout = detcoef(coefs,longs,levels,dummy) %#ok<INUSD>
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(2,4);
coder.internal.prefer_const(longs);
if nargout == 0
    % Do nothing.
elseif nargin == 2
    coder.internal.assert(nargout <= 1,'MATLAB:maxlhs');
    varargout{1} = localDetCoefLevelMax(coefs,longs);
elseif nargin == 3 && isnumeric(levels)
    coder.internal.prefer_const(levels);
    [varargout{1:nargout}] = localDetCoef(coefs,longs,levels);
else
    coder.internal.prefer_const(levels);
    varargout{1} = localDetCoefCell(coefs,longs,levels);
end

%--------------------------------------------------------------------------

function y = localDetCoefLevelMax(coefs,longs)
nlongs = coder.internal.indexInt(length(longs));
coder.internal.assert(nlongs >= 2,'MATLAB:badsubscript');
first = coder.internal.indexInt(longs(1)) + 1;
last = first + coder.internal.indexInt(longs(2)) - 1;
y = coefs(first:last);

%--------------------------------------------------------------------------

function varargout = localDetCoef(coefs,longs,levels)
ONE = coder.internal.indexInt(1);
nlongs = coder.internal.indexInt(length(longs));
coder.internal.assert(nlongs >= 3,'MATLAB:badsubscript');
maxlevel = nlongs - 2;
coder.internal.assert(allIntegersInRange(levels,ONE,maxlevel), ...
    'Wavelet:FunctionArgVal:Invalid_LevVal');
[first,last] = calcDetCoefFirstLast(longs);
assertFirstLastInRange(first,last,numel(coefs));
nlevels = coder.internal.indexInt(numel(levels));
for j = 1:min(nlevels,nargout)
    k = levels(j);
    varargout{j} = coefs(first(k):last(k));
end

%--------------------------------------------------------------------------

function y = localDetCoefCell(coefs,longs,levels)
ONE = coder.internal.indexInt(1);
coder.internal.prefer_const(levels);
coder.internal.assert(nargout <= 1,'MATLAB:maxlhs');
nlongs = coder.internal.indexInt(length(longs));
coder.internal.assert(nlongs >= 3,'MATLAB:badsubscript');
maxlevel = nlongs - 2;
if isnumeric(levels)
    coder.internal.assert(allIntegersInRange(levels,ONE,maxlevel), ...
        'Wavelet:FunctionArgVal:Invalid_LevVal');
    nlevels = coder.internal.indexInt(numel(levels));
    lev = levels;
else
    % levels not supplied, so is implicitly 1:max.
    nlevels = maxlevel;
    lev = 1:maxlevel;
end
[first,last] = calcDetCoefFirstLast(longs);
assertFirstLastInRange(first,last,numel(coefs));
y = coder.nullcopy(cell(1,nlevels));
for j = 1:nlevels
    k = lev(j);
    y{1,j} = coefs(first(k):last(k));
end

%--------------------------------------------------------------------------

function p = allIntegersInRange(x,lower,upper)
coder.inline('always');
p = true;
for k = 1:numel(x)
    p = p && x(k) >= lower && x(k) <= upper && x(k) == floor(x(k));
end

%--------------------------------------------------------------------------

function assertFirstLastInRange(first,last,ncoefs)
coder.internal.assert(first(end) >= min(ncoefs,1) && last(1) <= ncoefs, ...
    'MATLAB:badsubscript');

%--------------------------------------------------------------------------
