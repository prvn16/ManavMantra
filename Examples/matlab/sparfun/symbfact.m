%SYMBFACT Symbolic factorization analysis.
%
%   Analyzes the Cholesky factorization of A, A'*A, or A*A'.
%
%   count = SYMBFACT(A)        returns row counts of R = CHOL(A)
%   count = SYMBFACT(A,'sym')  same as SYMBFACT(A)
%   count = SYMBFACT(A,'col')  returns row counts of R = CHOL(A'*A)
%   count = SYMBFACT(A,'row')  returns row counts of R = CHOL(A*A')
%   count = SYMBFACT(A,'lo')   same as SYMBFACT(A'), uses TRIL(A)
%
%   The flop count for a subsequent Cholesky factorization is sum(count.^2)
%
%   [count,h,parent,post,R] = SYMBFACT(...) returns:
%
%       h:       height of the elimination tree
%       parent:  the elimination tree itself
%       post:    postordering of the elimination tree
%       R:       a 0-1 matrix whose structure is that of CHOL(A) for the
%                symmetric case, CHOL(A'*A) for the 'col' case, or
%                CHOL(A*A') for the 'row' case.
%
%   SYMBFACT(A) and SYMBFACT(A,'sym') uses the upper triangular part of A
%   (TRIU(A)) and assumes the lower triangular part is the transpose of
%   the upper triangular part.  SYMBFACT(A,'lo') uses TRIL(A) instead.
%
%   [count, h, parent, post, L] = SYMBFACT(A,TYPE,'lower'), where TYPE is
%   one of 'sym', 'col', 'row', or 'lo' returns a lower triangular symbolic
%   factor L = R'.  This form is quicker and requires less memory.
%
%   See also CHOL, ETREE, TREELAYOUT.

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.


