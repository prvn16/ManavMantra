function h = hours(x)
% HOURS Create durations from numeric values in units of hours.
%   H = HOURS(X) returns an array of durations with each element equal to the
%   number of hours in the corresponding element of X. H is the same size as
%   X. X may contain non-integer values.
%
%   See also SECONDS, MINUTES, DAYS, YEARS, CALDAYS, CALWEEKS, CALMONTHS,
%            CALQUARTERS, CALYEARS, DURATION, CALENDARDURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 1
    x = 1;
elseif (isnumeric(x) && isreal(x)) || islogical(x)
    % Convert any numeric to double before scaling to avoid integer saturation, etc.
    x = full(double(x));
elseif isa(x,'datetime')
    error(message('MATLAB:duration:DatetimeInput','HOUR','hour'));    
else
    error(message('MATLAB:duration:InvalidDurationData'));
end
h = duration.fromMillis(3600*1000*x,'h');

