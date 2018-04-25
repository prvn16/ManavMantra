function p = colperm(S)
%COLPERM Column permutation.
%   p = COLPERM(S) returns a permutation vector that reorders the
%   columns of the sparse matrix S in nondecreasing order of nonzero
%   count.  This is sometimes useful as a preordering for LU
%   factorization: lu(S(:,p)).
%
%   If S is symmetric, then COLPERM generates a permutation so that
%   both the rows and columns of S(p,p) are ordered in nondecreasing
%   order of nonzero count.  If S is positive definite, this is
%   sometimes useful as a preordering for Cholesky factorization:
%   chol(S(p,p)).
%
%   See also AMD, COLAMD, SYMAMD, SYMRCM.

%   Copyright 1984-2013 The MathWorks, Inc.

if ~ismatrix(S)
    error(message('MATLAB:colperm:invalidInput'));
end
[~,p] = sort(full(sum(S ~= 0, 1)));

