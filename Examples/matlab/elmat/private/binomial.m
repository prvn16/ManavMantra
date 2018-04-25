function A = binomial(n,classname)
%BINOMIAL    Binomial matrix (multiple of involutory matrix).
%   A = GALLERY('BINOMIAL',N) is an N-by-N matrix with integer entries
%   such that A^2 = 2^(N-1)*EYE(N).
%   Thus B = A*2^((1-N)/2) is involutory, that is, B^2 = EYE(N).

%   Reference:
%   G. Boyd, C. A. Micchelli, G. Strang and D.-X. Zhou,
%   Binomial matrices, Adv. in Comput. Math., 14 (2001), pp. 379-391.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

L = abs( pascal(n,1,classname) );
U = L(n:-1:1,n:-1:1);
D = diag( (-2).^(0:n-1) );
A = L*D*U;
