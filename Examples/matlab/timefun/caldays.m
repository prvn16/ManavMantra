function d = caldays(n)
%CALDAYS Create calendar durations from numeric values in units of calendar days.
%   D = CALDAYS(N) returns an array of calendar durations with each element
%   equal to the number of calendar days in the corresponding element of N. N
%   must contain integer values. D is the same size as N.
%
%   CALDAYS creates days that account for Daylight Saving Time shifts when
%   used in calendar calculations. To create exact fixed-length (i.e. 24 hour)
%   days, use the DAYS function.
%
%   See also CALWEEKS, CALMONTHS, CALQUARTERS, CALYEARS, SECONDS, MINUTES,
%            HOURS, DAYS, YEARS, DURATION, CALENDARDURATION.

%   Copyright 2014 The MathWorks, Inc.

if nargin < 1
    n = 1;
elseif isnumeric(n)
    % OK
elseif islogical(n)
    n = double(n);
else
    error(message('MATLAB:calendarDuration:InvalidCalDurationData'));
end

try
    d = calendarDuration(0,0,n);
catch ME
    if strcmp(ME.identifier,'MATLAB:calendarDuration:MustBeInteger')
        error(message('MATLAB:calendarDuration:NonintegerCalDaysData'));
    else
        throw(ME);
    end
end
