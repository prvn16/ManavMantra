function y = calyears(n)
%CALYEARS Create calendar durations from numeric values in units of calendar years.
%   Y = CALYEARS(N) returns an array of calendar durations with each element
%   equal to the number of calendar years in the corresponding element of N. N
%   must contain integer values. Y is the same size as N.
%
%   CALYEARS creates an array of years that account for leap days when used in
%   calendar calculations. To create exact fixed-length (i.e. 365.2425 day)
%   years, use the YEARS function.
%
%   See also CALDAYS, CALWEEKS, CALMONTHS, CALQUARTERS, SECONDS, MINUTES,
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
    y = calendarDuration(n,0,0);
catch ME
    if strcmp(ME.identifier,'MATLAB:calendarDuration:MustBeInteger')
        error(message('MATLAB:calendarDuration:NonintegerCalYearsData'));
    else
        throw(ME);
    end
end
