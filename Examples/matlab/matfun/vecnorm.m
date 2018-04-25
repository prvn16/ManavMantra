%VECNORM   Vector norm.
%   N = VECNORM(A) returns the 2-norm of the elements of vector A. For
%   matrices, N is a row vector containing the 2-norm of each column. For
%   N-D arrays, N is the 2-norm of the elements along the first array
%   dimension whose size does not equal 1. The size of the dimension
%   operated on by VECNORM becomes 1 while the size of all other dimensions
%   remains the same.
%
%   N = VECNORM(A,p) returns the vector p-norm defined by
%   sum(abs(v).^p)^(1/p), where p is any positive real value or Inf.
%
%   N = VECNORM(A,p,DIM) finds the p-norm along the dimension DIM of A.
%
%   Example:
%
%       % Find the 2-norm along the columns and rows of a matrix
%       A = [0 1 2; 3 4 5]
%       c = vecnorm(A)
%       r = vecnorm(A,2,2)
%
%   See also NORM.
 
%   Copyright 2017 The MathWorks, Inc.
%   Built-in function.
