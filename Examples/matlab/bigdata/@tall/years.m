function y = years(x)
%YEARS Create tall durations from numeric values in units of standard-length years.
%   Y = YEARS(T)
%
%   See also DURATION/YEARS, YEARS.
        
%   Copyright 2016 The MathWorks, Inc.

y = durationToggleFcn(@years, x);
end
