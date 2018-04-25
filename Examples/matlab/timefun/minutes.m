function m = minutes(x)
% MINUTES Create durations from numeric values in units of minutes.
%   H = MINUTES(X) returns an array of durations with each element equal to
%   the number of minutes in the corresponding element of X. H is the same
%   size as X. X may contain non-integer values.
%
%   See also SECONDS, HOURS, DAYS, YEARS, CALDAYS, CALWEEKS, CALMONTHS,
%            CALQUARTERS, CALYEARS, DURATION, CALENDARDURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 1
    x = 1;
elseif (isnumeric(x) && isreal(x)) || islogical(x)
    % OK
elseif isa(x,'datetime')
    error(message('MATLAB:duration:DatetimeInput','MINUTE','minute'));    
else
    error(message('MATLAB:duration:InvalidDurationData'));
end
% Convert any numeric to double before scaling to avoid integer saturation, etc.
m = duration.fromMillis(60*1000*full(double(x)),'m');

