%EIG    Eigenvalues and eigenvectors.
%   E = EIG(A) produces a column vector E containing the eigenvalues of 
%   a square matrix A.
%
%   [V,D] = EIG(A) produces a diagonal matrix D of eigenvalues and 
%   a full matrix V whose columns are the corresponding eigenvectors  
%   so that A*V = V*D.
% 
%   [V,D,W] = EIG(A) also produces a full matrix W whose columns are the
%   corresponding left eigenvectors so that W'*A = D*W'.
%
%   [...] = EIG(A,'nobalance') performs the computation with balancing
%   disabled, which sometimes gives more accurate results for certain
%   problems with unusual scaling. If A is symmetric, EIG(A,'nobalance')
%   is ignored since A is already balanced.
%
%   [...] = EIG(A,'balance') is the same as EIG(A).
%
%   E = EIG(A,B) produces a column vector E containing the generalized 
%   eigenvalues of square matrices A and B.
%
%   [V,D] = EIG(A,B) produces a diagonal matrix D of generalized
%   eigenvalues and a full matrix V whose columns are the corresponding
%   eigenvectors so that A*V = B*V*D.
%
%   [V,D,W] = EIG(A,B) also produces a full matrix W whose columns are the
%   corresponding left eigenvectors so that W'*A = D*W'*B.
%
%   [...] = EIG(A,B,'chol') is the same as EIG(A,B) for symmetric A and
%   symmetric positive definite B.  It computes the generalized eigenvalues
%   of A and B using the Cholesky factorization of B.
%
%   [...] = EIG(A,B,'qz') ignores the symmetry of A and B and uses the QZ
%   algorithm. In general, the two algorithms return the same result,
%   however using the QZ algorithm may be more stable for certain problems.
%   The flag is ignored when A or B are not symmetric.
%
%   [...] = EIG(...,'vector') returns eigenvalues in a column vector 
%   instead of a diagonal matrix.
%
%   [...] = EIG(...,'matrix') returns eigenvalues in a diagonal matrix
%   instead of a column vector.
%
%   See also CONDEIG, EIGS, ORDEIG.

%   Copyright 1984-2013 The MathWorks, Inc.
%   Built-in function.
