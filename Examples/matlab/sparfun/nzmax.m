%NZMAX  Amount of storage allocated for nonzero matrix elements.
%   N = NZMAX(A) returns the number of storage locations allocated for the
%   nonzero elements in sparse matrix A.
%
%   * For a full matrix A, NZMAX(A) is equal to prod(size(A)).
%   * For a sparse matrix A, NZMAX(A) >= 1.
%   * For both sparse and full matrices, NNZ(A) <= NZMAX(A).
%
%   See also NNZ, NONZEROS, SPALLOC.

%   Copyright 1984-2016 The MathWorks, Inc. 
%   Built-in function.
