function y = betaln(z,w)
%BETALN Logarithm of beta function.
%   Y = BETALN(Z,W) computes the natural logarithm of the beta
%   function for corresponding elements of Z and W.   The arrays Z and
%   W must be real and nonnegative. Both arrays must be the same size, 
%   or either can be scalar.  BETALN is defined as:
%
%       BETALN = LOG(BETA(Z,W)) 
%
%   and is obtained without computing BETA(Z,W). Since the beta
%   function can range over very large or very small values, its
%   logarithm is sometimes more useful.
%
%   Class support for inputs Z,W:
%      float: double, single
%
%   See also BETAINC, BETA.

%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 6.2.
%   Copyright 1984-2004 The MathWorks, Inc. 

y = gammaln(z)+gammaln(w)-gammaln(z+w);
