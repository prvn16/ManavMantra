%BESSELH Bessel function of the third kind (Hankel function).
%   H = BESSELH(NU,K,Z), for K = 1 or 2, computes the Hankel function
%   H1_nu(Z) or H2_nu(Z) for each element of the complex array Z.
%
%   H = BESSELH(NU,Z) uses K = 1.
%
%   H = BESSELH(NU,K,Z,SCALE) returns a scaled Hankel function 
%   specfied by SCALE:
%       0 - (default) is the same as BESSELH(NU,K,Z)
%       1 - returns the following depending on K
%
%   H = BESSELH(NU,1,Z,1) scales H1_nu(Z) by exp(-i*Z))).
%   H = BESSELH(NU,2,Z,1) scales H2_nu(Z) by exp(+i*Z))).
%
%   The relationship between the Hankel and Bessel functions is:
%
%       besselh(nu,1,z) = besselj(nu,z) + i*bessely(nu,z)
%       besselh(nu,2,z) = besselj(nu,z) - i*bessely(nu,z)
%
%   Example:
%       This example generates the contour plot of the modulus and
%       phase of the Hankel Function H1_0(z) shown on page 359 of
%       Abramowitz and Stegun, "Handbook of Mathematical Functions".
%
%       [X,Y] = meshgrid(-4:0.025:2,-1.5:0.025:1.5);
%       H = besselh(0,1,X+i*Y);
%       contour(X,Y,abs(H),0:0.2:3.2), hold on
%       contour(X,Y,(180/pi)*angle(H),-180:10:180); hold off
%
%   Class support for inputs NU and Z:
%      float: double, single
%
%   See also AIRY, BESSELI, BESSELJ, BESSELK, BESSELY.

%   Reference:
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2012 The MathWorks, Inc. 
%   Built-in function.
