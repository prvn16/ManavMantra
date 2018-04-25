%CHOL   Cholesky factorization.
%   CHOL(A) uses only the diagonal and upper triangle of A.
%   The lower triangle is assumed to be the (complex conjugate)
%   transpose of the upper triangle.  If A is positive definite, then
%   R = CHOL(A) produces an upper triangular R so that R'*R = A.
%   If A is not positive definite, an error message is printed.
%
%   L = CHOL(A,'lower') uses only the diagonal and the lower triangle
%   of A to produce a lower triangular L so that L*L' = A.  If
%   A is not positive definite, an error message is printed.  When
%   A is sparse, this syntax of CHOL is typically faster.
%
%   [R,p] = CHOL(A), with two output arguments, never produces an
%   error message.  If A is positive definite, then p is 0 and R
%   is the same as above.   But if A is not positive definite, then
%   p is a positive integer.
%   When A is full, R is an upper triangular matrix of order q = p-1
%   so that R'*R = A(1:q,1:q).
%   When A is sparse, R is an upper triangular matrix of size q-by-n
%   so that the L-shaped region of the first q rows and first q
%   columns of R'*R agree with those of A.
%
%   [L,p] = CHOL(A,'lower'), functions as described above, only a lower
%   triangular matrix L is produced.  That is, when A is full, L is a
%   lower triangular matrix of order q = p-1 so that L*L' = A(1:q,1:q).
%   When A is sparse, L is a lower triangular matrix of size n-by-q
%   so that the L-shaped region of the first q rows and first q columns
%   of L*L' agree with those of A.
%
%   [R,p,S] = CHOL(A), when A is sparse, returns a permutation matrix
%   S which is a preordering of A obtained by AMD.  When p = 0, R is an
%   upper triangular matrix such that R'*R = S'*A*S.  When p is not zero,
%   R is an upper triangular matrix of size q-by-n so that the L-shaped
%   region of the first q rows and first q columns of R'*R agree with
%   those of S'*A*S.  The factor of S'*A*S tends to be sparser than the
%   factor of A.
%
%   [R,p,s] = CHOL(A,'vector') returns the permutation information as
%   a vector s such that A(s,s) = R'*R, when p = 0.  The flag 'matrix'
%   may be used in place of 'vector' to obtain the default behavior.
%
%   [L,p,s] = CHOL(A,'lower','vector') uses only the diagonal and the
%   lower triangle of A and returns a lower triangular matrix L and
%   a permutation vector s such that A(s,s) = L*L', when p = 0.
%   As above, 'matrix' may be used in place of 'vector' to obtain a
%   permutation matrix.
%
%   For sparse A, CHOLMOD is used to compute the Cholesky factor.
%
%   See also CHOLUPDATE, ICHOL, LDL, LU.

%   Copyright 1984-2010 The MathWorks, Inc.
%   Built-in function.

