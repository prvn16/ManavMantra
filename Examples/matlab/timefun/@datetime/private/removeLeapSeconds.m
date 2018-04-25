function [dd,isLeapSec,isLeapSecDay] = removeLeapSeconds(dd)
% Remove leap seconds from each internal time value.

%   Copyright 2015 The MathWorks, Inc.

millisPerDay = 86400 * 1000;
millisPerSec = 1000;

% dd may exceed the range of flint-milliseconds (1970 +/- ~285Ky), but that
% won't matter because all leap seconds are well within that range
wholeMillis = floor(real(dd));
leaps = leapSecMillis(); leaps = leaps + millisPerSec*(0:(length(leaps)-1)); % adjusted to include leap secs
edges = [-Inf leaps Inf];
n = discretize(wholeMillis,edges);
dd = matlab.internal.datetime.datetimeSubtract(dd,(n-1)*millisPerSec); % s -> ms

if nargout > 1
    % Is the time within 1sec after a leap second?
    del = wholeMillis - edges(n);
    isLeapSec = (0 <= del & del < millisPerSec);
    
    if nargout > 2
        % Is the time within 1day before or 1sec after a leap second?
        del = wholeMillis - edges(n+1);
        isLeapSecDay = isLeapSec | (-millisPerDay <= del & del < 0);
    end
end
