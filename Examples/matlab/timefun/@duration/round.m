function that = round(this,unit)
%ROUND Round durations.
%   B = ROUND(A) rounds the durations in the array A the nearest whole number
%   of seconds. B is a duration array.
%
%   B = ROUND(A,UNIT) rounds the durations in the array A to the nearest whole
%   number of the specified unit of time. UNIT is 'seconds', 'minutes', 'hours',
%   'days', or 'years'.
%
%   Note: A duration of 1 year is equal to exactly 365.2425 24-hour days. For
%   flexible-length calendar years, use calendar durations.
%
%   Examples:
%
%      dt = hours(8) + minutes(29:31) + seconds(1.2345)
%      dh = round(dt,'hours')
%
%   See also FLOOR, ROUND, DURATION

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 2
    scale = 1000; % default: round to nearest second
else
    scale = checkUnit(unit);
end
that = this;
that.millis = scale * (round(this.millis / scale));
