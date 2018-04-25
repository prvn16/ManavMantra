function out = calendarDurationToggleFcn(fcn, in)
%durationToggleFcn Toggle between numeric and duration
%   Shared implementation for calhours, caldays etc.

% Copyright 2016 The MathWorks, Inc.

out = durationToggleSharedFcn('calendarDuration', fcn, in);
end
