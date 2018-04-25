function y = calquarters(x)
%CALQUARTERS Convert tall calendar durations to and from numbers of whole calendar quarters.
%   Q = CALQUARTERS(T)
%
%   See also CALENDARDURATION/CALQUARTERS, CALQUARTERS.

%   Copyright 2016 The MathWorks, Inc.

y = calendarDurationToggleFcn(@calquarters, x);
end
