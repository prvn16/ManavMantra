function P = pei(n, alpha, classname)
%PEI    Pei matrix.
%   GALLERY('PEI',N,ALPHA), where ALPHA is a scalar, is the symmetric
%   matrix ALPHA*EYE(N) + 1. The default for ALPHA is 1.
%   The matrix is singular for ALPHA = 0, -N.

%   Reference:
%   M. L. Pei, A test matrix for inversion procedures, Comm. ACM,
%   5 (1962), p. 508.
%
%   Copyright 1984-2013 The MathWorks, Inc.

if isempty(alpha)
   alpha = 1; 
end

P = alpha*eye(n,classname) + 1;
