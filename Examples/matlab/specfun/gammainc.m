%GAMMAINC Incomplete gamma function.
%   Y = GAMMAINC(X,A) evaluates the incomplete gamma function for
%   corresponding elements of X and A.  The elements of A must be nonnegative.
%   X and A must be real and the same size (or either can be a scalar).
%
%   The incomplete gamma function is defined as:
%
%    gammainc(x,a) = 1 ./ gamma(a) .*
%       integral from 0 to x of t^(a-1) exp(-t) dt
%
%   For any a>=0, as x approaches infinity, gammainc(x,a) approaches 1. For
%   small x and a, gammainc(x,a) ~ x^a, so gammainc(0,0) = 1.
%
%   Y = GAMMAINC(X,A,TAIL) specifies the tail of the incomplete gamma function
%   when X is non-negative.  Choices are 'lower' (the default) to compute the
%   integral from 0 to X, or 'upper' to compute the integral from X to
%   infinity.  These two choices are related as
%
%      GAMMAINC(X,A,'upper') = 1 - GAMMAINC(X,A,'lower').
%
%   When the upper tail value is close to 0, the 'upper' option provides a way
%   to compute that value more accurately than by subtracting the lower tail
%   value from 1.
%
%   Warning: When X is negative, Y can be inaccurate for abs(X) > A+1.
%
%   Y = GAMMAINC(X,A,'scaledlower') and GAMMAINC(X,A,'scaledupper') return
%   the incomplete gamma function, scaled by GAMMA(A+1)*EXP(X)/X^A.  These
%   functions are unbounded above, but are useful for values of X and A where
%   GAMMAINC(X,A,'lower') or GAMMAINC(X,A,'upper') underflow to zero.
%
%   Class support for inputs X,A:
%      float: double, single
%
%   See also GAMMAINCINV, GAMMA, GAMMALN, PSI.

%   References:
%      [1] Abramowitz & Stegun, Handbook of Mathematical Functions,
%          Sec. 6.5, especially 6.5.29 and 26.5.31.
%      [2] Knuesel, L. (1986) "Computation of the Chi-square and Poisson
%          Distribution", SIAM J. Sci. Stat. Comput., 7(3):1022-1036.

%   Copyright 1984-2014 The MathWorks, Inc.
