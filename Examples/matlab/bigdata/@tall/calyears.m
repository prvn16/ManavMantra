function y = calyears(x)
%CALYEARS Convert tall calendar durations to and from numbers of whole calendar years.
%   Y = CALYEARS(T)
%
%   See also CALENDARDURATION/CALYEARS, CALYEARS.

%   Copyright 2016 The MathWorks, Inc.

y = calendarDurationToggleFcn(@calyears, x);
end
