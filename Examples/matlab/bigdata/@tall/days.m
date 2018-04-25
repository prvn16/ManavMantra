function d = days(x)
%DAYS Create tall durations from numeric values in units of standard-length days.
%   D = DAYS(T)
%
%   See also DURATION/DAYS, DAYS.
        
%   Copyright 2016 The MathWorks, Inc.

d = durationToggleFcn(@days, x);
end
