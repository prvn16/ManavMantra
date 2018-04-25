function m = milliseconds(x)
%MILLISECONDS Create tall durations from numeric values in units of milliseconds
%   M = MILLISECONDS(T)
%
%   See also DURATION/MILLISECONDS, MILLISECONDS.

% Copyright 2016 The MathWorks, Inc.

m = durationToggleFcn(@milliseconds, x);
end
