% Triangular kernel
% Copyright 2016 The MathWorks, Inc.

function f = triangle(x)
f = (x+1) .* ((-1 <= x) & (x < 0)) + (1-x) .* ((0 <= x) & (x <= 1));
end