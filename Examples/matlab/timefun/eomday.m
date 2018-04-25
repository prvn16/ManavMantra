function d = eomday(y,m)
%EOMDAY End of month.
%   D = EOMDAY(Y,M) returns the last day of the month for the given
%   year, Y, and month, M. 
%   Algorithm:
%      "Thirty days hath September, ..."
%
%   See also WEEKDAY, DATENUM, DATEVEC.

%   Copyright 1984-2002 The MathWorks, Inc. 

if ~isnumeric(y) || any(fix(y(:)) ~= y(:))
    error(message('MATLAB:eomday:NotAYearNumber'));
end
if ~isnumeric(m) || any(m(:) < 1) || any(12 < m(:)) || any(fix(m(:)) ~= m(:))
    error(message('MATLAB:eomday:NotAMonthNumber'));
end

% Number of days in the month.
dpm = [31 28 31 30 31 30 31 31 30 31 30 31]';

% Make result the right size and orientation.
d = y - m;

d(:) = dpm(m);
d((m == 2) & ((rem(y,4) == 0 & rem(y,100) ~= 0) | rem(y,400) == 0)) = 29;
