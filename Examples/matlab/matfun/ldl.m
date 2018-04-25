%LDL   Block LDL' factorization for Hermitian indefinite matrices.
%   Assuming that A is a Hermitian matrix (that is, A == A'),
%   [L,D] = LDL(A) stores a block diagonal matrix D and a permuted
%   unit lower triangular matrix (i.e. a product of unit lower triangular and
%   permutation matrices) in L so that A = L*D*L'.  The block diagonal matrix
%   D has 1x1 and 2x2 blocks on its diagonal.  This syntax is not valid for
%   sparse A.
%
%   [L,D,P] = LDL(A) returns unit lower triangular matrix L, block diagonal D,
%   and permutation matrix P so that P'*A*P = L*D*L'.  This is equivalent
%   to [L,D,P] = LDL(A,'matrix').
%
%   [L,D,p] = LDL(A,'vector') returns the permutation information as a
%   vector instead of a matrix.  That is, p is a row vector such that
%   A(p,p) = L*D*L'.
%
%   L = LDL(A) returns only the permuted unit lower triangular matrix L
%   as in the two output form.  The permutation information is lost, as is
%   the block diagonal factor D.  This syntax is not valid for sparse A.
%
%   By default, LDL references only the diagonal and lower triangle of A,
%   and assumes that the upper triangle is the complex conjugate transpose
%   of the lower triangle.  Therefore [L,D,P] = LDL(TRIL(A)) and
%   [L,D,P] = LDL(A) both return the exact same factors.
%
%   [U,D,P] = LDL(A,'upper') references only the diagonal and upper triangle
%   of A and assumes that the lower triangle is the complex conjugate
%   transpose of the upper triangle.  This call returns a unit upper triangular
%   matrix U such that P'*A*P = U'*D*U (assuming that A is Hermitian, and not
%   just upper triangular).  Similarly, [L,D,P] = LDL(A,'lower') gives
%   the default behavior.
%
%   [U,D,p] = LDL(A,'upper','vector') returns the permutation information
%   as a vector, as does [L,D,p] = LDL(A,'lower','vector').
%
%   [L,D,P,S] = LDL(A) returns unit lower triangular L, block diagonal D,
%   permutation matrix P, and scaling matrix S such that P'*S*A*S*P =
%   L*D*L'.  This syntax is only available for real sparse matrices, and
%   only the lower triangle of A is referenced. LDL uses MA57 for real
%   sparse A.
%
%   [L,D,P,S] = LDL(A,THRESH) uses THRESH as the pivot tolerance in MA57.
%   THRESH must be a double scalar lying in the interval [0, 0.5]. The
%   default value for THRESH is 0.01.  Using smaller values of THRESH may
%   give faster factorization times and fewer entries, but it may also
%   result in a less stable factorization. This syntax is only available
%   for real sparse matrices.
%
%   [U,D,p,S] = LDL(A,THRESH,'upper','vector') sets the pivot tolerance and
%   returns upper triangular U and permutation vector p as described above.
%
%   See also CHOL, LU, QR.

%   Copyright 2006-2014 The MathWorks, Inc.
%   Built-in function.
