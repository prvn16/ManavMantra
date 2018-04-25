%AMD  Approximate minimum degree permutation.
%   P = AMD(A) returns the approximate minimum degree permutation vector
%   for the sparse matrix C = A + A'.  The Cholesky factorization of
%   C(P,P), or A(P,P), tends to be sparser than that of C or A.  AMD tends
%   to be faster than SYMAMD. A must be square. If A is full, AMD(A) is
%   equivalent to AMD(SPARSE(A)).
%
%   P = AMD(A,OPTS) allows additional options for the reordering.
%   OPTS is structure with up to two fields:
%      dense      --- indicates what is considered to be dense.
%      aggressive --- aggressive absorption
%   Only the fields of interest must be set.
%
%   dense is a nonnegative scalar such that if A is n-by-n, then rows/columns
%   with more than max(16, (dense * sqrt(n))) entries in A + A' are
%   considered "dense" and ignored during the ordering.  They are placed
%   last in the output permutation.  The default is 10.0 if this option
%   is not present.
%
%   aggressive is a scalar controlling aggressive absorption.  If aggressive
%   is nonzero, then aggressive absorption is performed.  This is the default
%   if this option is not present.
%
%   An assembly tree post-ordering is performed, which is typically the same
%   as an elimination tree post-ordering.  It is not always identical because
%   of the approximate degree update used, and because "dense" rows/columns
%   do not take part in the post-order.  It well-suited for a subsequent
%   "chol", however.  If you require a precise elimination tree post-ordering,
%   then do:
%
%      P = amd(S);
%      C = spones(S) + spones(S');  % skip this if S already symmetric
%      [~, Q] = etree(C(P,P));
%      P = P(Q);
%
%   AMD Version 2.0 is written and copyrighted by Timothy A. Davis,
%   Patrick R. Amestoy, and Iain S. Duff.
%
%   Availability:
%
%      http://www.cise.ufl.edu/research/sparse/amd
%
%   See also COLAMD, COLPERM, SYMAMD, SYMRCM, SLASH.

%   Copyright 2004-2013 The MathWorks, Inc. 
%   Built-in function.
