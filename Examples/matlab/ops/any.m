%ANY    True if any element of a vector is a nonzero number or is
%   logical 1 (TRUE).  ANY ignores entries that are NaN (Not a Number).
%
%   For vectors, ANY(V) returns logical 1 (TRUE) if any of the 
%   elements of the vector is a nonzero number or is logical 1 (TRUE).
%   Otherwise it returns logical 0 (FALSE).  For matrices, ANY(X) 
%   operates on the columns of X, returning a row vector of logical 1's 
%   and 0's.  For multi-dimensional arrays, ANY(X) operates on the 
%   first non-singleton dimension.
%
%   ANY(X,DIM) works down the dimension DIM.  For example, ANY(X,1)
%   works down the first dimension (the rows) of X.
%
%   See also ALL, NNZ.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.
