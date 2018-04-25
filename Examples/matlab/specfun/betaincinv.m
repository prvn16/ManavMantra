%BETAINCINV Inverse incomplete beta function.
%   X = BETAINCINV(Y,Z,W) computes the inverse incomplete beta function for
%   corresponding elements of Y, Z, and W, such that Y = BETAINC(X,Z,W).  The
%   elements of Y must be in the closed interval [0,1], and those of Z and W
%   must be nonnegative.  Y, Z, and W must all be real and the same size (or
%   any of them can be scalar).
%
%   The incomplete beta function is defined as
%
%     I_x(z,w) = 1./BETA(z,w) .*
%                integral from 0 to x of t.^(z-1) .* (1-t).^(w-1) dt
%
%   and BETAINCINV computes the inverse of that function with respect to the
%   integration limit x, using Newton's method.
%
%   X = BETAINCINV(Y,Z,W,TAIL) specifies the tail of the incomplete beta
%   function.  Choices are 'lower' (the default) to use the integral from 0 to
%   x, or 'upper' to use the integral from x to 1.  These two choices are
%   related as follows:
%
%        BETAINCINV(Y,Z,W,'upper') = BETAINCINV(1-Y,Z,W,'lower')
%
%   When Y is close to 0, the 'upper' option provides a way to compute X more
%   accurately than by subtracting from Y from 1.
%
%   Class support for inputs Y,Z,W:
%      float: double, single
%
%   See also BETAINC, BETA, BETALN.

%   Reference: Abramowitz & Stegun, Handbook of Mathematical Functions,
%   Sec. 26.5, especially 26.5.8, 26.5.20 and 26.5.21.

%   Copyright 2008 The MathWorks, Inc.
