function edges = integersrule(xMin, xMax, limits, numBinsMax)
;%#ok<NOSEM> Undocumented

% Implementation copied from toolbox/matlab/datafun/private/integerrule.m 
% refactored to support tall arrays

% Assumes that this rule is only used when the underlying strong type is
% some integer type or logical.

%   Copyright 2016 The MathWorks, Inc.

if ~isempty(xMax) && (xMax > flintmax(class(xMax))/2 || ...
        xMin < -flintmax(class(xMin))/2)
    st = dbstack;
    name = st(2).name;
    m = message(['MATLAB:' name ':InputOutOfIntRange']);
    throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end

xrange = xMax - xMin;

if ~isempty([xMin xMax])
    if xrange > numBinsMax
        % If there'd be more than maximum bins, center them on an appropriate
        % power of 10 instead.
        binwidth = 10^ceil(log10(xrange/numBinsMax));
    else
        % Otherwise bins are centered on integers.
        binwidth = 1;
    end
    if isempty(limits)
        xMin = binwidth*round(xMin/binwidth); % make the edges bin width multiples
        xMax = binwidth*round(xMax/binwidth);
        edges = (floor(xMin)-.5*binwidth):binwidth:(ceil(xMax)+.5*binwidth);
    else
        low = limits(1);
        high = limits(2);
        minxi = binwidth*ceil(low/binwidth)+0.5;
        maxxi = binwidth*floor(high/binwidth)-0.5;
        edges = [low minxi:binwidth:maxxi high];
    end
else
    if isempty(limits)
        edges = cast([-0.5 0.5], 'like', xrange);
    else
        low = limits(1);
        high = limits(2);
        minxi = ceil(low)+0.5;
        maxxi = floor(high)-0.5;
        edges = [low minxi:maxxi high];
    end
end