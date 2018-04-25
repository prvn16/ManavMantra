%PSI  Psi (polygamma) function.
%   Y = PSI(X) evaluates the psi function for each element of X.
%   X must be real and nonnegative.  SIZE(Y) is the same as SIZE(X).
%   The psi function, also know as the digamma function, is the logarithmic
%   derivative of the gamma function: 
%
%      psi(x) = digamma(x) = d(log(gamma(x)))/dx = (d(gamma(x))/dx)/gamma(x).
%
%   Y = PSI(K,X) evaluates the K-derivative of psi at the elements of X.
%   For real integer-valued scalar K, SIZE(Y) is the same as SIZE(X).
%   PSI(0,X) is the digamma function, PSI(1,X) is the trigamma function,
%   PSI(2,X) is the tetragamma function, etc.
%
%   Examples:
%
%      -psi(1) = -psi(0,1) is Euler's constant, 0.5772156649015323.
%
%      psi(1,2) = pi^2/6 - 1.
%
%      x = (1:.005:1.250)';  [x gamma(x) gammaln(x) psi(0,x) psi(1,x) x-1]
%      produces the first page of table 6.1 of Abramowitz and Stegun.
%
%      x = (1:.01:2)'; [psi(2,x) psi(3,x)] is a portion of table 6.2.
%
%   See also GAMMA, GAMMALN, GAMMAINC, GAMMAINCINV.

%   References:
%      [1] Abramowitz & Stegun, Handbook of Mathematical Functions, 
%          sec. 6.3 and 6.4
%
%   Copyright 1984-2012 The MathWorks, Inc.
%   Built-in function.
