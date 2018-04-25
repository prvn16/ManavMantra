function A = lehmer(n,classname)
%LEHMER Lehmer matrix.
%   A = GALLERY('LEHMER',N) is the symmetric positive definite
%   N-by-N matrix such that A(i,j) = i/j for j >= i.
%
%   Properties:
%      A is totally nonnegative.
%      INV(A) is tridiagonal and explicitly known.
%      A.^r is symmetric positive semidefinite for all nonnegative r.
%      N <= COND(A) <= 4*N*N.

%   References:
%   [1] R. Bhatia, Infinitely divisible matrices, Amer. Math. Monthly,
%       133 (2006), pp. 221-235.  (For the "A.^r" property.)
%   [2] M. Newman and J. Todd, The evaluation of matrix inversion
%       programs, J. Soc. Indust. Appl Math, 6 (1958),pp. 466-476.
%   [3] Solutions to problem E710 (proposed by D.H. Lehmer):
%       The inverse of a matrix, Amer. Math. Monthly, 53 (1946),
%       pp. 534-535.
%   [4] J. Todd, Basic Numerical Mathematics, Vol. 2: Numerical
%       Algebra, Birkhauser, Basel, and Academic Press, New York,
%       1977, p. 154.
%
%   Nicholas J. Higham
%   Copyright 1984-2015 The MathWorks, Inc.

a = 1:cast(n,classname);
A = a ./ a';
A = tril(A) + tril(A,-1)';
