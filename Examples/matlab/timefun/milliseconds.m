function s = milliseconds(x)
% MILLISECONDS Create durations from numeric values in units of milliseconds.
%   S = MILLISECONDS(X) returns an array of durations with each element equal to
%   the number of milliseconds in the corresponding element of X. S is the same
%   size as X. X may contain non-integer values.
%
%   See also SECONDS, MINUTES, HOURS, DAYS, YEARS, CALDAYS, CALWEEKS, CALMONTHS,
%            CALQUARTERS, CALYEARS, DURATION, CALENDARDURATION.

%   Copyright 2015-2017 The MathWorks, Inc.

if nargin < 1
    x = 1;
elseif (isnumeric(x) && isreal(x)) || islogical(x)
    % OK
elseif isa(x,'datetime')
    error(message('MATLAB:duration:DatetimeInput','SECOND','second'));    
else
    error(message('MATLAB:duration:InvalidDurationData'));
end
% Convert any numeric to double
s = duration.fromMillis(full(double(x)),'s');
