function s = seconds(d)
%SECONDS Create tall durations from numeric values in units of seconds.
%   S = SECONDS(T)
%
%   See also DURATION/SECONDS, SECONDS.
        
%   Copyright 2016 The MathWorks, Inc.

s = durationToggleFcn(@seconds, d);
end
