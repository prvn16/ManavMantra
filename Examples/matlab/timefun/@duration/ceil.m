function that = ceil(this,unit)
%CEIL Round durations towards infinity.
%   B = CEIL(A) rounds the durations in the array A up to a whole number of
%   seconds. B is a duration array.
%
%   B = CEIL(A,UNIT) rounds the durations in the array A up to a whole
%   number of the specified unit of time. UNIT is 'seconds', 'minutes', 'hours',
%   'days', or 'years'.
%
%   Note: A duration of 1 year is equal to exactly 365.2425 24-hour days. For
%   flexible-length calendar years, use calendar durations.
%
%   Examples:
%
%      dt = hours(8) + minutes(29:31) + seconds(1.2345)
%      dh = ceil(dt,'hours')
%
%   See also FLOOR, ROUND, DURATION

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 2
    scale = 1000; % default: round up to next second
else
    scale = checkUnit(unit);
end
that = this;
that.millis = scale * (ceil(this.millis / scale));
