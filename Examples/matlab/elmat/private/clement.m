function A = clement(n,k,classname)
%CLEMENT Clement matrix.
%   GALLERY('CLEMENT',N,K) is a tridiagonal matrix with zero diagonal
%   entries and known eigenvalues. It is singular if N is odd. About 64
%   percent of the entries of the inverse are zero. The eigenvalues
%   are plus and minus the numbers N-1, N-3, N-5, ..., (1 or 0).
%   For K = 0 (the default) the matrix is unsymmetric, while for
%   K = 1 it is symmetric. GALLERY('CLEMENT',N,1) is diagonally similar
%   to GALLERY('CLEMENT',N).
%   For odd N = 2*M+1, M+1 of the singular values are the integers
%   SQRT((2*M+1)^2 - (2*K+1).^2), K = 0:M.
%
%   Note:
%   Similar properties hold for GALLERY('TRIDIAG',X,Y,Z) where
%   Y = ZEROS(N,1). The eigenvalues still come in plus/minus pairs but
%   they are not known explicitly.
%

%   References:
%   [1] T. Boros and P. Rozsa,  An Explicit Formula for Singular
%       Values of the Sylvester--Kac Matrix, Linear Algebra and Appl.,
%       421 (2007), pp. 407-416.
%   [2] P. A. Clement, A class of triple-diagonal matrices for test
%   purposes, SIAM Review, 1 (1959), pp. 50-52.
%   [3] O. Taussky and J. Todd, Another look at a matrix of Mark Kac,
%   Linear Algebra and Appl., 150 (1991), pp. 341-360.
%
%   Nicholas J. Higham
%   Copyright 1984-2008 The MathWorks, Inc.

if isempty(k), k = 0; end

n = n-1;

z = cast(1:n,classname);
x = z(n:-1:1);

if k == 0
   A = diag(x, -1) + diag(z, 1);
else
   y = sqrt(x.*z);
   A = diag(y, -1) + diag(y, 1);
end
