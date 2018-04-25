function q = calquarters(n)
%CALQUARTERS Create calendar durations from numeric values in units of calendar quarters.
%   Q = CALQUARTERS(N) returns an array of calendar durations with each element
%   equal to the number of calendar quarters in the corresponding element of N.
%   N must contain integer values. Q is the same size as N.
%
%   See also CALDAYS, CALWEEKS, CALMONTHS, CALYEARS, SECONDS, MINUTES,
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
    q = calendarDuration(0,3*n,0,'Format','qmdt');
catch ME
    if strcmp(ME.identifier,'MATLAB:calendarDuration:MustBeInteger')
        error(message('MATLAB:calendarDuration:NonintegerCalQuartersData'));
    else
        throw(ME);
    end
end
