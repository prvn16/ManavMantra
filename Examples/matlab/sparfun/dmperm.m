%DMPERM Dulmage-Mendelsohn permutation.
%   p = DMPERM(A) finds a maximum matching p such that p(j) = i if column j
%   is matched to row i, or 0 if column j is unmatched.  If A is a square
%   matrix with full structural rank, p is a row permutation and A(p,:) has a
%   zero-free diagonal.  The structural rank of A is sprank(A) = sum(p>0).
%
%   [p,q,r,s,cc,rr] = DMPERM(A) finds the Dulmage-Mendelsohn decomposition
%   of A.  p and q are row and column permutation vectors, respectively
%   such that A(p,q) has block upper triangular form.  r and s are vectors
%   indicating the block boundaries for the fine decomposition.  cc and rr
%   are vectors of length five indicating the block boundaries of the
%   coarse decomposition.
%
%   C = A(p,q) is split into a 4-by-4 set of coarse blocks:
%
%       A11 A12 A13 A14
%        0  0   A23 A24
%        0  0    0  A34
%        0  0    0  A44
%
%   where A12, A23, and A34 are square with zero-free diagonals.  The
%   columns of A11 are the unmatched columns, and the rows of A44 are the
%   unmatched rows. Any of these blocks can be empty.  In the coarse
%   decomposition, the (i,j)th block is C(rr(i):rr(i+1)-1,cc(j):cc(j+1)-1).
%   In terms of a linear system, [A11 A12] is the underdetermined part of
%   the system (it is always rectangular and with more columns and rows, or
%   0-by-0), A23 is the well-determined part of the system (it is always
%   square), and [A34 ; A44] is the overdetermined part of the system (it
%   is always rectangular with more rows than columns, or 0-by-0).
%
%   The structural rank of A is sprank(A) = rr(4)-1, which is an upper
%   bound on the numerical rank of A.  sprank(A) = rank(full(sprand(A)))
%   with probability 1 in exact arithmetic.
%
%   The A23 submatrix is further subdivided into block upper triangular
%   form via the fine decomposition (the strongly-connected components of
%   A23). If A is square and structurally nonsingular, A23 is the entire
%   matrix.
%
%   C(r(i):r(i+1)-1,s(j):s(j+1)-1) is the (i,j)th block of the fine
%   decomposition.  The (1,1) block is the rectangular block [A11 A12],
%   unless this block is 0-by-0.  The (b,b) block is the rectangular block
%   [A34 ; A44], unless this block is 0-by-0, where b = length(r)-1.  All
%   other blocks of the form C(r(i):r(i+1)-1,s(i):s(i+1)-1) are diagonal
%   blocks of A23, and are square with a zero-free diagonal.
%
%   DMPERM uses CSparse.
%
%   See also SPRANK.

%   CSparse is written by Timothy A. Davis.
%   See http://www.cise.ufl.edu/research/sparse/CSparse for details.
%   
%   T. A. Davis, Direct Methods for Sparse Linear Systems, SIAM,
%   Philadelphia,  2006.
%
%   Copyright 1984-2013 The MathWorks, Inc. 
%   Built-in function.
