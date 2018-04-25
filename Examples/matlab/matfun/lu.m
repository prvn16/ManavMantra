%LU     LU factorization.
%   [L,U] = LU(A) stores an upper triangular matrix in U and a
%   "psychologically lower triangular matrix" (i.e. a product of lower
%   triangular and permutation matrices) in L, so that A = L*U. A can be
%   rectangular.
%
%   [L,U,P] = LU(A) returns unit lower triangular matrix L, upper
%   triangular matrix U, and permutation matrix P so that P*A = L*U.
%
%   [L,U,p] = LU(A,'vector') returns the permutation information as a
%   vector instead of a matrix.  That is, p is a row vector such that
%   A(p,:) = L*U.  Similarly, [L,U,P] = LU(A,'matrix') returns a
%   permutation matrix P.  This is the default behavior.
%
%   Y = LU(A) returns the output from LAPACK'S DGETRF or ZGETRF routine if
%   A is full. If A is sparse, Y contains the strict lower triangle of L
%   embedded in the same matrix as the upper triangle of U. In both full
%   and sparse cases, the permutation information is lost.
%
%   [L,U,P,Q] = LU(A) returns unit lower triangular matrix L, upper
%   triangular matrix U, a permutation matrix P and a column reordering
%   matrix Q so that P*A*Q = L*U for sparse non-empty A. This uses UMFPACK
%   and is significantly more time and memory efficient than the other
%   syntaxes, even when used with COLAMD.
%
%   [L,U,p,q] = LU(A,'vector') returns two row vectors p and q so that
%   A(p,q) = L*U.  Using 'matrix' in place of 'vector' returns permutation
%   matrices.
%
%   [L,U,P,Q,R] = LU(A) returns unit lower triangular matrix L, upper
%   triangular matrix U, permutation matrices P and Q, and a diagonal
%   scaling matrix R so that P*(R\A)*Q = L*U for sparse non-empty A.
%   This uses UMFPACK as well.  Typically, but not always, the row-scaling
%   leads to a sparser and more stable factorization.  Note that this
%   factorization is the same as that used by sparse MLDIVIDE when
%   UMFPACK is used.
%
%   [L,U,p,q,R] = LU(A,'vector') returns the permutation information in two
%   row vectors p and q such that R(:,p)\A(:,q) = L*U.  Using 'matrix'
%   in place of 'vector' returns permutation matrices.
%
%   [L,U,P] = LU(A,THRESH) controls pivoting in sparse matrices, where
%   THRESH is a pivot threshold in [0,1].  Pivoting occurs when the
%   diagonal entry in a column has magnitude less than THRESH times the
%   magnitude of any sub-diagonal entry in that column.  THRESH = 0 forces
%   diagonal pivoting.  THRESH = 1 is the default.
%
%   [L,U,P,Q,R] = LU(A,THRESH) controls pivoting in UMFPACK.  THRESH is a
%   one or two element vector which defaults to [0.1 0.001].  If UMFPACK
%   selects its unsymmetric pivoting strategy, THRESH(2) is not used. It
%   uses its symmetric pivoting strategy if A is square with a mostly
%   symmetric nonzero structure and a mostly nonzero diagonal.  For its
%   unsymmetric strategy, the sparsest row i which satisfies the criterion
%   A(i,j) >= THRESH(1) * max(abs(A(j:m,j))) is selected.  A value of 1.0
%   results in conventional partial pivoting. Entries in L have absolute
%   value of 1/THRESH(1) or less.  For its symmetric strategy, the diagonal
%   is selected using the same test but with THRESH(2) instead.  If the
%   diagonal entry fails this test, a pivot entry below the diagonal is
%   selected, using THRESH(1). In this case, L has entries with absolute
%   value 1/min(THRESH) or less. Smaller values of THRESH(1) and THRESH(2)
%   tend to lead to sparser LU factors, but the solution can become
%   inaccurate.  Larger values can lead to a more accurate solution (but
%   not always), and usually an increase in the total work and memory
%   usage.
%
%   [L,U,p] = LU(A,THRESH,'vector') and [L,U,p,q,R] = LU(A,THRESH,'vector')
%   are also valid for sparse matrices and return permutation vectors.
%   Using 'matrix' in place of 'vector' returns permutation matrices.
%
%   See also CHOL, ILU, QR.

%   Copyright 1984-2010 The MathWorks, Inc.
%   Built-in function.

