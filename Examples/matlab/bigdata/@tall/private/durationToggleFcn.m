function out = durationToggleFcn(fcn, in)
%durationToggleFcn Toggle between numeric and duration
%   Shared implementation for hours, minutes, seconds etc.

% Copyright 2016 The MathWorks, Inc.

out = durationToggleSharedFcn('duration', fcn, in);
end
