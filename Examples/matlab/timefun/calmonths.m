function m = calmonths(n)
%CALMONTHS Create calendar durations from numeric values in units of calendar months.
%   M = CALMONTHS(N) returns an array of calendar durations with each element
%   equal to the number of calendar months in the corresponding element of N. N
%   must contain integer values. M is the same size as N.
%
%   See also CALDAYS, CALWEEKS, CALQUARTERS, CALYEARS, SECONDS, MINUTES,
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
    m = calendarDuration(0,n,0);
catch ME
    if strcmp(ME.identifier,'MATLAB:calendarDuration:MustBeInteger')
        error(message('MATLAB:calendarDuration:NonintegerCalMonthsData'));
    else
        throw(ME);
    end
end
