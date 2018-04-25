function edges = integerrule(x, minx, maxx, hardlimits, maximumbins)
% INTEGERRULE  Integer binning rule for histogram functions.

%   Copyright 1984-2015 The MathWorks, Inc.

if ~isempty(maxx) && (maxx > flintmax(class(maxx))/2 || ...
        minx < -flintmax(class(minx))/2)
    st = dbstack;
    name = st(2).name;
    m = message(['MATLAB:' name ':InputOutOfIntRange']);
    throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end
xrange = maxx-minx;
if ~isempty(x)
    xscale = max(abs(x(:)));
    xrange = max(x(:)) - min(x(:));
    if xrange > maximumbins
        % If there'd be more than maximum bins, center them on an appropriate
        % power of 10 instead.
        binwidth = 10^ceil(log10(xrange/maximumbins));
    elseif isfloat(x) && eps(xscale) > 1
        % If a bin width of 1 is effectively zero relative to the magnitude of
        % the endpoints, use a bigger power of 10.
        binwidth = 10^ceil(log10(eps(xscale)));
    else
        % Otherwise bins are centered on integers.
        binwidth = 1;
    end
    if ~hardlimits
        minx = binwidth*round(minx/binwidth); % make the edges bin width multiples
        maxx = binwidth*round(maxx/binwidth);
        edges = (floor(minx)-.5*binwidth):binwidth:(ceil(maxx)+.5*binwidth);
    else
        minxi = binwidth*ceil(minx/binwidth)+0.5;
        maxxi = binwidth*floor(maxx/binwidth)-0.5;
        edges = [minx minxi:binwidth:maxxi maxx];
    end
else
    if ~hardlimits
        edges = cast([-0.5 0.5], 'like', xrange);
    else
        minxi = ceil(minx)+0.5;
        maxxi = floor(maxx)-0.5;
        edges = [minx minxi:maxxi maxx];
    end
end