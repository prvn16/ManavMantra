%BESSELY Bessel function of the second kind.
%   Y = BESSELY(NU,Z) is the Bessel function of the second kind, Y_nu(Z).
%   The order NU need not be an integer, but must be real.
%   The argument Z can be complex.  The result is real where Z is positive.
%
%   Y = BESSELY(NU,Z,SCALE) returns a scaled Y_nu(Z) specified by SCALE:
%       0 - (default) is the same as BESSELY(NU,Z)
%       1 -  scales Y_nu(Z) by exp(-abs(imag(Z)))
%
%   Class support for inputs NU and Z:
%      float: double, single
%
%   See also AIRY, BESSELH, BESSELI, BESSELJ, BESSELK.

%   Reference:
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2012 The MathWorks, Inc. 
%   Built-in function.
