%EPS  Spacing of floating point numbers.
%   D = EPS(X), is the positive distance from ABS(X) to the next larger in
%   magnitude floating point number of the same precision as X.
%   X may be either double precision or single precision.
%   For all X, EPS(X) is equal to EPS(ABS(X)).
%
%   EPS, with no arguments, is the distance from 1.0 to the next larger double
%   precision number, that is EPS with no arguments returns 2^(-52).
%
%   EPS('double') is the same as EPS, or EPS(1.0).
%   EPS('single') is the same as EPS(single(1.0)), or single(2^-23).
%
%   Except for numbers whose absolute value is smaller than REALMIN,
%   if 2^E <= ABS(X) < 2^(E+1), then
%      EPS(X) returns 2^(E-23) if ISA(X,'single')
%      EPS(X) returns 2^(E-52) if ISA(X,'double')
%
%   For all X of class double such that ABS(X) <= REALMIN, EPS(X)
%   returns 2^(-1074).   Similarly, for all X of class single such that
%   ABS(X) <= REALMIN('single'), EPS(X) returns 2^(-149).
%
%   Replace expressions of the form
%      if Y < EPS * ABS(X)
%   with
%      if Y < EPS(X)
%
%   Example return values from calling EPS with various inputs are
%   presented in the table below:
%
%         Expression                   Return Value
%        ===========================================
%         eps(1/2)                     2^(-53)
%         eps(1)                       2^(-52)
%         eps(2)                       2^(-51)
%         eps(realmax)                 2^971
%         eps(0)                       2^(-1074)
%         eps(realmin/2)               2^(-1074)
%         eps(realmin/16)              2^(-1074)
%         eps(Inf)                     NaN
%         eps(NaN)                     NaN
%        -------------------------------------------
%         eps(single(1/2))             2^(-24)
%         eps(single(1))               2^(-23)
%         eps(single(2))               2^(-22)
%         eps(realmax('single'))       2^104
%         eps(single(0))               2^(-149)
%         eps(realmin('single')/2)    2^(-149)
%         eps(realmin('single')/16)   2^(-149)
%         eps(single(Inf))             single(NaN)
%         eps(single(NaN))             single(NaN)
%
%   See also REALMAX, REALMIN.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Built-in function.
