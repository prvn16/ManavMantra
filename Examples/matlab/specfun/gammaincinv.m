%GAMMAINCINV Inverse incomplete gamma function.
%   X = GAMMAINCINV(Y,A) evaluates the inverse incomplete gamma function for
%   corresponding elements of Y and A, such that Y = GAMMAINC(X,A).  The
%   elements of Y must be in the closed interval [0,1], and those of A must be
%   non-negative.  Y and A must be real and the same size (or either can be a
%   scalar).
%
%   The incomplete gamma function is defined as:
%
%      gammainc(x,a) = 1 ./ gamma(a) .*
%                      integral from 0 to x of t^(a-1) exp(-t) dt
%
%   and GAMMAINCINV computes the inverse of that function with respect to the
%   integration limit x, using Newton's method.
%
%   For any a>0, as y approaches 1, gammaincinv(y,a) approaches infinity. For
%   small x and a, gammainc(x,a) ~= x^a, so gammaincinv(1,0) = 0.
%
%   X = GAMMAINCINV(Y,A,TAIL) specifies the tail of the incomplete gamma
%   function.  Choices are 'lower' (the default) to use the integral from 0 to
%   X, or 'upper' to use the integral from X to infinity.  These two choices
%   are related as
%
%      GAMMAINCINV(Y,A,'upper') = GAMMAINCINV(1-Y,A,'lower').
%
%   When Y is close to 0, the 'upper' option provides a way to compute X more
%   accurately than by subtracting Y from 1.
%
%   Class support for inputs Y,A:
%      float: double, single
%
%   See also GAMMAINC, GAMMA, GAMMALN, PSI.

%   References:
%      [1] Abramowitz & Stegun, Handbook of Mathematical Functions,
%          Sec. 6.5, especially 6.5.29 and 26.5.31.
%      [2] Knuesel, L. (1986) "Computation of the Chi-square and Poisson
%          Distribution", SIAM J. Sci. Stat. Comput., 7(3):1022-1036.

%   Copyright 2008-2014 The MathWorks, Inc.
