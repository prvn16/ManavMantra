%HYPOT   Robust computation of the square root of the sum of squares
%   C = HYPOT(A,B) returns SQRT(ABS(A).^2+ABS(B).^2) carefully computed to
%   avoid underflow and overflow. A and B must have compatible sizes. In
%   the simplest cases, they can be the same size or one can be a scalar.
%   Two inputs have compatible sizes if, for every dimension, the dimension
%   sizes of the inputs are either the same or one of them is 1.
%
%   Example:
%      format short e
%      a = 3*[1e300 1e-300]
%      b = 4*[1e300 1e-300]
%      c1 = sqrt(a.^2 + b.^2)
%      c2 = hypot(a,b)
%
%      x = 1.271161e308
%      y = hypot(x,x)
%
%   Class support for inputs A, B:
%      float: double, single
%
%   See also ABS, NORM, SQRT.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.
