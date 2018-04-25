%TRUE   True array.
%   TRUE is short-hand for logical(1).
%   TRUE(N) is an N-by-N matrix of logical ones.
%   TRUE(M,N) or TRUE([M,N]) is an M-by-N matrix of logical ones.
%   TRUE(M,N,P,...) or TRUE([M N P ...]) is an M-by-N-by-P-by-...
%   array of logical ones.
%   TRUE(SIZE(A)) is the same size as A and all logical ones.
%   TRUE(..., 'like', Y) is an array of logical ones with the same data type
%   and sparsity as the logical array Y.
%
%   TRUE(N) is much faster and more memory efficient than LOGICAL(ONES(N)).
%
%   Note: The size inputs M, N, and P... should be nonnegative integers. 
%   Negative integers are treated as 0.
%
%   See also FALSE, LOGICAL.

%   Copyright 1984-2013 The MathWorks, Inc.
%   Built-in function.

