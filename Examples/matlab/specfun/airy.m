%AIRY   Airy functions.
%   W = AIRY(Z) is the Airy function, Ai(Z), of the elements of Z.
%
%   W = AIRY(K,Z) returns various Airy functions specified by K:
%       0 - (default) is the same as AIRY(Z)
%       1 - returns the derivative, Ai'(Z)
%       2 - returns the Airy function of the second kind, Bi(Z)
%       3 - returns the derivative, Bi'(Z)
%
%   W = AIRY(K,Z,SCALE) returns a scaled AIRY(K,Z) specified by SCALE:
%       0 - (default) is that same as AIRY(K,Z)
%       1 - returns AIRY(K,Z) scaled by EXP(2/3.*Z.^(3/2)) for K = 0,1,
%           and scaled by EXP(-ABS(2/3.*REAL(Z.^(3/2)))) for K = 2,3.
%
%   The relationship between the Airy and modified Bessel functions is:
%
%       Ai(z) = 1/pi*sqrt(z/3)*K_1/3(zeta)
%       Bi(z) = sqrt(z/3)*(I_-1/3(zeta)+I_1/3(zeta))
%       where zeta = 2/3*z^(3/2)
%
%   See also BESSELH, BESSELI, BESSELJ, BESSELK, BESSELY.

%   Reference:
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2012 The MathWorks, Inc. 
%   Built-in function.
