function p = allIntInRange(x,low,high)
%MATLAB Code Generation Private Function

%   Return true iff low <= x(k) <= high and floor(x(k)) == x(k) for all
%   valid k.

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

p = true;
for k = 1:numel(x)
    p = p && (x(k) >= low) && (x(k) <= high) && (floor(x(k)) == x(k));
end
