% Box-shaped interpolation kernel
% Copyright 2016 The MathWorks, Inc.

function f = box(x)
f = (-0.5 <= x) & (x < 0.5);
end
