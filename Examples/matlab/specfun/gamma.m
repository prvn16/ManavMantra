%GAMMA Gamma function.
%   Y = GAMMA(X) evaluates the gamma function for each element of X.
%   X must be real.  The gamma function is defined as:
%
%      gamma(x) = integral from 0 to inf of t^(x-1) exp(-t) dt.
%
%   The gamma function interpolates the factorial function.  For
%   integer n, gamma(n+1) = n! (n factorial) = prod(1:n).
%
%   Class support for input X:
%      float: double, single
%
%   See also GAMMALN, GAMMAINC, GAMMAINCINV, PSI.

%   References:
%      [1] Abramowitz & Stegun, Handbook of Mathematical Functions, 
%          sec. 6.1.
%      [2] W. J. Cody, An Overview of Software Development for Special 
%          Functions,  Lecture Notes in Mathematics, 506, Numerical 
%          Analysis Dundee, 1975, G. A. Watson (ed.), Springer Verlag, 
%          Berlin, 1976.
%      [3] Hart, Et. Al., Computer Approximations, Wiley and sons, New
%          York, 1968.

%   Copyright 1984-2009 The MathWorks, Inc.
