function y = years(x)
% YEARS Create durations from numeric values in units of standard-length years.
%   Y = YEARS(X) returns an array of durations with each element equal to the
%   number of exact fixed-length (i.e. 365.2425 day) years in the corresponding
%   element of X. Y is the same size as X. X may contain non-integer values.
%
%   To create an array of calendar years that account for leap days when used in
%   calendar calculations, use the CALYEARS function.
%
%   See also SECONDS, MINUTES, HOURS, DAYS, CALDAYS, CALWEEKS, CALMONTHS,
%            CALQUARTERS, CALYEARS, DURATION, CALENDARDURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 1
    x = 1;
elseif (isnumeric(x) && isreal(x)) || islogical(x)
    % OK
elseif isa(x,'datetime')
    error(message('MATLAB:duration:DatetimeInput','YEAR','year'));    
else
    error(message('MATLAB:duration:InvalidDurationData'));
end
% Convert any numeric to double before scaling to avoid integer saturation, etc.
y = duration.fromMillis(365.2425*86400*1000*full(double(x)),'y');
