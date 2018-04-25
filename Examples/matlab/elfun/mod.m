%MOD    Modulus after division.
%   MOD(x,y) returns x - floor(x./y).*y if y ~= 0, carefully computed to
%   avoid rounding error. If y is not an integer and the quotient x./y is
%   within roundoff error of an integer, then n is that integer. The inputs
%   x and y must be real and have compatible sizes. In the simplest cases,
%   they can be the same size or one can be a scalar. Two inputs have
%   compatible sizes if, for every dimension, the dimension sizes of the
%   inputs are either the same or one of them is 1.
%
%   The statement "x and y are congruent mod m" means mod(x,m) == mod(y,m).
%
%   By convention:
%      MOD(x,0) is x.
%      MOD(x,x) is 0.
%      MOD(x,y), for x~=y and y~=0, has the same sign as y.
%
%   Note: REM(x,y), for x~=y and y~=0, has the same sign as x.
%   MOD(x,y) and REM(x,y) are equal if x and y have the same sign, but
%   differ by y if x and y have different signs.
%
%   See also REM.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.
