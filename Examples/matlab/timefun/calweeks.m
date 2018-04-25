function w = calweeks(n)
%CALWEEKS Create calendar durations from numeric values in units of calendar weeks.
%   W = CALWEEKS(N) returns an array of calendar durations with each element
%   equal to the number of calendar weeks in the corresponding element of N. N
%   must contain integer values. W is the same size as N.
%
%   See also CALDAYS, CALMONTHS, CALQUARTERS, CALYEARS, SECONDS, MINUTES,
%            HOURS, DAYS, YEARS, DURATION, CALENDARDURATION.

%   Copyright 2014 The MathWorks, Inc.

if nargin < 1
    n = 1;
elseif isnumeric(n) || islogical(n)
    n = double(n); % so ints can be scaled below
else
    error(message('MATLAB:calendarDuration:InvalidCalDurationData'));
end

try
    w = calendarDuration(0,0,7*n,'Format','ymwdt');
catch ME
    if strcmp(ME.identifier,'MATLAB:calendarDuration:MustBeInteger')
        error(message('MATLAB:calendarDuration:NonintegerCalWeeksData'));
    else
        throw(ME);
    end
end
