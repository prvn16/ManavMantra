function [dd,precedesLeapSec,isLeapSecDay] = addLeapSeconds(dd)
% Add leap seconds to each internal time value.

%   Copyright 2015 The MathWorks, Inc.

millisPerDay = 86400 * 1000;
millisPerSec = 1000;

% dd may exceed the range of flint-milliseconds (1970 +/- ~285Ky), but that
% won't matter because all leap seconds are well within that range
wholeMillis = floor(real(dd));
edges = [-Inf leapSecMillis() Inf];
n = discretize(wholeMillis,edges);
dd = matlab.internal.datetime.datetimeAdd(dd,(n-1)*millisPerSec); % s -> ms

if nargout > 1
    % Is the time within 1sec before a leap second?
    del = wholeMillis - edges(n);
    precedesLeapSec = (-millisPerSec <= del & del < 0);
    
    if nargout > 2
        % Is the time within 1day before a leap second?
        del = wholeMillis - edges(n+1);
        isLeapSecDay = (-millisPerDay <= del & del < 0);
    end
end
