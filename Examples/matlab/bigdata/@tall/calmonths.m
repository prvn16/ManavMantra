function y = calmonths(x)
%CALMONTHS Convert tall calendar durations to and from numbers of whole calendar months.
%   M = CALMONTHS(T)
%
%   See also CALENDARDURATION/CALMONTHS, CALMONTHS.

%   Copyright 2016 The MathWorks, Inc.

y = calendarDurationToggleFcn(@calmonths, x);
end
