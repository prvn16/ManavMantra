function A = parter(n,classname)
%PARTER Parter matrix (Toeplitz with singular values near pi).
%     C = GALLERY('PARTER',N) returns the matrix C such that
%     C(i,j) = 1/(i-j+0.5).
%     C is a Cauchy matrix and a Toeplitz matrix.
%     Most of the singular values of C are very close to pi.

%   References:
%   [1] MathWorks Newsletter, Volume 1, Issue 1, March 1986, page 2.
%   [2] A. Bottcher and B. Silbermann, Introduction to Large Truncated
%       Toeplitz Matrices, Springer-Verlag, New York, 1999; Sec. 4.5.
%   [3] S. V. Parter, On the distribution of the singular values of
%       Toeplitz matrices, Linear Algebra and Appl., 80(1986), pp. 115-130.
%   [4] E. E. Tyrtyshnikov, Cauchy-Toeplitz matrices and some applications,
%       Linear Algebra and Appl., 149 (1991), pp. 1-18.

%   Copyright 1984-2008 The MathWorks, Inc.

A = gallery('cauchy', (1:n)+0.5, -(1:n), classname);
