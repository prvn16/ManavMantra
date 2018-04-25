function d = days(x)
% DAYS Create durations from numeric values in units of standard-length days.
%   D = DAYS(X) returns an array of durations with each element equal to the
%   number of exact fixed-length days (i.e. 24 hours) in the corresponding
%   element of X. D is the same size as X. X may contain non-integer values.
%
%   To create an array of calendar days that account for Daylight Saving Time
%   changes when used in calendar calculations, use the CALDAYS function.
%
%   See also SECONDS, MINUTES, HOURS, YEARS, CALDAYS, CALWEEKS, CALMONTHS,
%            CALQUARTERS, CALYEARS, DURATION, CALENDARDURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 1
    x = 1;
elseif (isnumeric(x) && isreal(x)) || islogical(x)
    % OK
elseif isa(x,'datetime')
    error(message('MATLAB:duration:DatetimeInput','DAY','day'));    
else
    error(message('MATLAB:duration:InvalidDurationData'));
end
% Convert any numeric to double before scaling to avoid integer saturation, etc.
d = duration.fromMillis(86400*1000*full(double(x)),'d');
