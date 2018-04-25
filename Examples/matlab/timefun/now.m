function t = now()
%NOW    Current date and time as date number.
%   T = NOW returns the current date and time as a serial date 
%   number.
%
%   FLOOR(NOW) is the current date and REM(NOW,1) is the current time.
%   DATESTR(NOW) is the current date and time as a character vector.
%
%   See also DATE, DATENUM, DATESTR, CLOCK.

%   Author(s): C.F. Garvin, 2-23-95
%   Copyright 1984-2016 The MathWorks, Inc.

% Clock representation of current time
t = datenum(clock);
