function h = hours(x)
%HOURS Create tall durations from numeric values in units of hours.
%   H = HOURS(T)
%
%   See also DURATION/HOURS, HOURS.
        
%   Copyright 2016 The MathWorks, Inc.

h = durationToggleFcn(@hours, x);
end
