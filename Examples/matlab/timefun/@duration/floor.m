function that = floor(this,unit)
%FLOOR Round durations towards minus infinity.
%   B = FLOOR(A) rounds the durations in the array A down to a whole number
%   of seconds. B is a duration array.
%
%   B = FLOOR(A,UNIT) rounds the durations in the array A down to a whole
%   number of the specified unit of time. UNIT is 'seconds', 'minutes', 'hours',
%   'days', or 'years'.
%
%   Note: A duration of 1 year is equal to exactly 365.2425 24-hour days. For
%   flexible-length calendar years, use calendar durations.
%
%   Examples:
%
%      dt = hours(8) + minutes(29:31) + seconds(1.2345)
%      dh = floor(dt,'hours')
%
%   See also CEIL, ROUND, DURATION

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 2
    scale = 1000; % default: round down to previous second
else
    scale = checkUnit(unit);
end
that = this;
that.millis = scale * (floor(this.millis / scale));
