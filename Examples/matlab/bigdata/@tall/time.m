function tt = time(td)
%TIME Extract the time portion of tall calendar durations.
%   T = TIME(D)
%
%   See also CALENDARDURATION/TIME.

%   Copyright 2016 The MathWorks, Inc.

td = tall.validateType(td, mfilename, {'calendarDuration'}, 1);
tt = elementfun(@time, td);
tt = setKnownType(tt, 'duration');
end
