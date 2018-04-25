%BETAINC Incomplete beta function.
%   Y = BETAINC(X,Z,W) computes the incomplete beta function for corresponding
%   elements of X, Z, and W.  The elements of X must be in the closed interval
%   [0,1], and those of Z and W must be nonnegative. X, Z, and W must all be
%   real and the same size (or any of them can be scalar).
%
%   The incomplete beta function is defined as
%
%      I_x(z,w) = 1./BETA(z,w) .*
%                 integral from 0 to x of t.^(z-1) .* (1-t).^(w-1) dt
%
%   Y = BETAINC(X,Z,W,TAIL) specifies the tail of the incomplete beta function.
%   Choices are 'lower' (the default) to compute the integral from 0 to x, or
%   'upper' to compute the integral from x to 1.  These two choices are
%   related as
%
%      BETAINC(X,Z,W,'upper') = 1 - BETAINC(X,Z,W,'lower').
%
%   When the upper tail value is close to 0, the 'upper' option provides a way
%   to compute that value more accurately than by subtracting the lower tail
%   value from 1.
%
%   If either Z or W is very large, BETAINC uses an approximation whose
%   absolute accuracy is at least 5e-3 if Z+W > 6.
%
%   Class support for inputs X,Z,W:
%      float: double, single
%
%   See also BETAINCINV, BETA, BETALN.

%   Reference: Abramowitz & Stegun, Handbook of Mathematical Functions,
%   Sec. 26.5, especially 26.5.8, 26.5.20 and 26.5.21.

%   Copyright 1984-2009 The MathWorks, Inc.
