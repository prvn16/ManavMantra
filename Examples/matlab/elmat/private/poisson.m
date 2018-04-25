function A = poisson(n,classname)
%POISSON Block tridiagonal matrix from Poisson's equation (sparse).
%   GALLERY('POISSON',N) is the block tridiagonal (sparse) matrix
%   of order N^2 resulting from discretizing Poisson's equation with
%   the 5-point operator on an N-by-N mesh.  The matrix is symmettric
%   positive definite and has eigenvalues
%     2*( 2 - cos(pi*i/(N+1)) - cos(pi*j/(N+1)) ), i = 1:N, j = 1:N.

%   Reference:
%   G. H. Golub and C. F. Van Loan, Matrix Computations, third edition,
%   Johns Hopkins University Press, Baltimore, Maryland, 1996,
%   Sec. 4.5.4.
%
%   Nicholas J. Higham
%   Copyright 1984-2008 The MathWorks, Inc.

S = tridiag(n,-1,2,-1,classname);
I = speye(n);
A = kron(I,S) + kron(S,I);
