%REM    Remainder after division.
%   REM(x,y) returns x - fix(x./y).*y if y ~= 0, carefully computed to
%   avoid rounding error. If y is not an integer and the quotient x./y is
%   within roundoff error of an integer, then n is that integer. The inputs
%   x and y must be real and have compatible sizes. In the simplest cases,
%   they can be the same size or one can be a scalar. Two inputs have
%   compatible sizes if, for every dimension, the dimension sizes of the
%   inputs are either the same or one of them is 1.
%
%   By convention:
%      REM(x,0) is NaN.
%      REM(x,x), for x~=0, is 0.
%      REM(x,y), for x~=y and y~=0, has the same sign as x.
%
%   Note: MOD(x,y), for x~=y and y~=0, has the same sign as y.
%   REM(x,y) and MOD(x,y) are equal if x and y have the same sign, but
%   differ by y if x and y have different signs.
%
%   See also MOD.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.
