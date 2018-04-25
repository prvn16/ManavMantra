%GAMMALN Logarithm of gamma function.
%   Y = GAMMALN(X) computes the natural logarithm of the gamma function 
%   for each element of X.  GAMMALN is defined as LOG(GAMMA(X)) and 
%   is obtained without computing GAMMA(X).  Since the gamma function 
%   can range over very large or very small values, its logarithm is 
%   sometimes more useful.
%
%   Class support for input X:
%      float: double, single
%
%   See also GAMMA, GAMMAINC, GAMMAINCINV, PSI.

%   References:
%      [1] W. J. Cody and K. E. Hillstrom, 'Chebyshev Approximations for
%          the Natural Logarithm of the Gamma Function,' Math. Comp. 21,
%          1967, pp. 198-203.
%      [2] K. E. Hillstrom, ANL/AMD Program ANLC366S, DGAMMA/DLGAMA, May,
%          1969.
%      [3] Hart, Et. Al., Computer Approximations, Wiley and sons, New
%          York, 1968.

%   Copyright 1984-2009 The MathWorks, Inc.
