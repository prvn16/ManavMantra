function A = minij(n,classname)
%MINIJ Symmetric positive definite matrix MIN(i,j).
%   A = GALLERY('MINIJ',N) is the N-by-N symmetric positive definite
%   matrix with A(i,j) = MIN(i,j).
%
%   Properties:
%   A has eigenvalues 0.25*SEC((1:N)*PI/(2*N+1)).^2.
%   INV(A) is tridiagonal. It is minus the second difference matrix
%     except its (N,N) element is 1.
%   A.^r is symmetric positive semidefinite for all nonnegative r.
%   2*A-ONES(N) (Givens' matrix) has tridiagonal inverse and
%     eigenvalues 0.5*SEC((2*(1:N)-1)*PI/(4*N)).^2.
%   FLIPUD(GALLERY('TRIW',N,1)) is a square root of A.

%   References:
%   [1] R. Bhatia, Infinitely divisible matrices, Amer. Math. Monthly,
%       (2005), to appear. (For the "A.^r" property.)
%   [2] J. Fortiana and C. M. Cuadras, A family of matrices, the
%       discretized Brownian bridge, and distance-based regression,
%       Linear Algebra Appl., 264 (1997), pp. 173-188.  (For the
%       eigensystem of A.)
%   [3] J. Todd, Basic Numerical Mathematics, Vol 2: Numerical Algebra,
%       Birkhauser, Basel, and Academic Press, New York, 1977, p. 158.
%   [4] D.E. Rutherford, Some continuant determinants arising in
%       physics and chemistry---II, Proc. Royal Soc. Edin., 63,
%       A (1952), pp. 232-241. (For the eigenvalues of Givens' matrix.)
%
%   Nicholas J. Higham
%   Copyright 1984-2015 The MathWorks, Inc.

a = 1:cast(n,classname);
A = min(a,a');
