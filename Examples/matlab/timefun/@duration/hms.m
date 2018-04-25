function [h,m,s] = hms(d)
%HMS Split durations into separate time unit values.
%   [H,M,S] = HMS(T) splits the durations in T into separate numeric arrays
%   containing hours, minutes, and seconds. HMS returns hours and minutes as
%   whole numbers, and seconds with a fractional part.
%
%   Examples:
%      dt = hours(23:25) + minutes(8) + seconds(1.2345)
%      [h,m,s] = hms(dt)
%
%   See also DAYS, HOURS, MINUTES, SECONDS, DURATION.

%   Copyright 2014 The MathWorks, Inc.

s = d.millis / 1000; % ms -> s
h = fix(s / 3600);
s = s - 3600*h;
m = fix(s / 60);
s = s - 60*m;

% Return the same non-finite in all fields.
nonfiniteElems = ~isfinite(h);
nonfiniteVals = h(nonfiniteElems);
if ~isempty(nonfiniteVals)
    m(nonfiniteElems) = nonfiniteVals;
    s(nonfiniteElems) = nonfiniteVals;
end
