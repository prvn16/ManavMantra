%BESSELK Modified Bessel function of the second kind.
%   K = BESSELK(NU,Z) is the modified Bessel function of the second kind,
%   K_nu(Z).  The order NU need not be an integer, but must be real.
%   The argument Z can be complex.  The result is real where Z is positive.
%
%   K = BESSELK(NU,Z,SCALE) returns a scaled K_nu(Z) specified by SCALE:
%       0 - (default) is the same as BESSELK(NU,Z)
%       1 -  scales K_nu(Z) by exp(Z)
%
%   Class support for inputs NU and Z:
%      float: double, single
%
%   See also AIRY, BESSELH, BESSELI, BESSELJ, BESSELY.

%   Reference:
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2012 The MathWorks, Inc. 
%   Built-in function.
