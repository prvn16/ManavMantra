%DISSECT  Nested dissection permutation.
%   P = DISSECT(A) returns a permutation vector computed using nested
%   dissection of the sparsity structure of the matrix A. A can be full or
%   sparse but must be square. If the sparsity structure is nonsymmetric,
%   the structure is symmetrized. The Cholesky factorization of A(P,P)
%   tends to be sparser than that of A.
%
%   P = DISSECT(...,'VertexWeights',V) specifies weights for each vertex.
%   The vector of weights V must have length equal to size(A,1) and contain
%   positive integers. By default, all vertices are weighted equally.
%
%   P = DISSECT(...,'NumSeparators',N) specifies the number of separators
%   to compute at each level. N must be a positive integer. Larger values
%   may produce a better permutation, but can increase execution time. The
%   default value is 1.
%
%   P = DISSECT(...,'NumIterations',N) specifies the number of refinement
%   iterations to use during the uncoarsening phase of nested dissection. N
%   must be a positive integer. Larger values may produce a better
%   permutation, but can increase execution time. The default is 10.
%
%   P = DISSECT(...,'MaxImbalance',M) specifies the maximum acceptable
%   imbalance among partitions. M must be an integer multiple of 0.001
%   greater than or equal to 1.001 and less than or equal to 1.999. Larger
%   values can reduce execution time by accepting a worse permutation. The
%   default is 1.2.
%
%   P = DISSECT(...,'MaxDegreeThreshold',T) specifies that DISSECT should
%   ignore vertices with degree larger than T*(average degree)/10 during
%   ordering. Vertices ignored in this way are placed at the end of the
%   permutation. T must be a nonnegative integer. The default value is 0,
%   which means all vertices are ordered.
%
%   Examples:
%     % Create a sparse matrix.
%       A = delsq(numgrid('L',502));
%     % Reorder for Cholesky factorization
%       p = dissect(A);
%       L = chol(A(p,p));
%     % Accept up to 25% imbalance during reordering
%       p = dissect(A, 'MaxImbalance', 1.25);
%     % Reduce the number of refinement iterations
%       p = dissect(A, 'NumIterations', 2);
%
%   See also AMD, COLAMD, COLPERM, SYMAMD, SYMRCM, SLASH.

%   This utility uses the METIS graph reordering library. For details, see:
%   "A Fast and High Quality Multilevel Scheme for Partitioning Irregular
%   Graphs". George Karypis and Vipin Kumar. SIAM Journal on Scientific
%   Computing, Vol. 20, No. 1, pp. 359-392, 1999.

%   Copyright 2017 The MathWorks, Inc.
%   Built-in function.
