%EYE Identity matrix.
%   EYE(N) is the N-by-N identity matrix.
%
%   EYE(M,N) or EYE([M,N]) is an M-by-N matrix with 1's on
%   the diagonal and zeros elsewhere.
%
%   EYE(SIZE(A)) is the same size as A.
%
%   EYE with no arguments is the scalar 1.
%
%   EYE(..., CLASSNAME) is a matrix with ones of class specified by
%   CLASSNAME on the diagonal and zeros elsewhere.
%
%   EYE(..., 'like', Y) is an identity matrix with the same data type, sparsity,
%   and complexity (real or complex) as the numeric variable Y.
%
%   Note: The size inputs M and N should be nonnegative integers. 
%   Negative integers are treated as 0.
%
%   Example:
%      x = eye(2,3,'int8');
%
%   See also SPEYE, ONES, ZEROS, RAND, RANDN.

%   Copyright 1984-2013 The MathWorks, Inc. 
%   Built-in function.
