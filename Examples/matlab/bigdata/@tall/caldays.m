function y = caldays(x)
%CALDAYS Convert tall calendar durations to and from numbers of whole calendar days.
%   D = CALDAYS(T)
%
%   See also CALENDARDURATION/CALDAYS, CALDAYS.

%   Copyright 2016 The MathWorks, Inc.

y = calendarDurationToggleFcn(@caldays, x);
end
