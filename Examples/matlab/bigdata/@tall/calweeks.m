function y = calweeks(x)
%CALWEEKS Convert tall calendar durations to and from numbers of whole calendar weeks.
%   W = CALWEEKS(T)
%
%   See also CALENDARDURATION/CALWEEKS, CALWEEKS.

%   Copyright 2016 The MathWorks, Inc.

y = calendarDurationToggleFcn(@calweeks, x);
end
