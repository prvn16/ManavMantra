function m = minutes(x)
%MINUTES Create tall durations from numeric values in units of minutes.
%   M = MINUTES(T)
%
%   See also DURATION/MINUTES, MINUTES.
        
%   Copyright 2016 The MathWorks, Inc.

m = durationToggleFcn(@minutes, x);
end
