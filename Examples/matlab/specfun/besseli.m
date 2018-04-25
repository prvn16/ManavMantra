%BESSELI Modified Bessel function of the first kind.
%   I = BESSELI(NU,Z) is the modified Bessel function of the first kind,
%   I_nu(Z).  The order NU need not be an integer, but must be real.
%   The argument Z can be complex.  The result is real where Z is positive.
%
%   I = BESSELI(NU,Z,SCALE) returns a scaled I_nu(Z) specified by SCALE:
%       0 - (default) is the same as BESSELI(NU,Z)
%       1 -  scales I_nu(Z) by exp(-abs(real(Z)))
%
%   Class support for inputs NU and Z:
%      float: double, single
%
%   See also AIRY, BESSELH, BESSELJ, BESSELK, BESSELY.

%   Reference:
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2012 The MathWorks, Inc. 
%   Built-in function.
