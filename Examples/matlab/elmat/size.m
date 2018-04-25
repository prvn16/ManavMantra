%SIZE   Size of array.  
%   D = SIZE(X), for M-by-N matrix X, returns the two-element row vector
%   D = [M,N] containing the number of rows and columns in the matrix.
%   For N-D arrays, SIZE(X) returns a 1-by-N vector of dimension lengths.
%   Trailing singleton dimensions are ignored.
%
%   [M,N] = SIZE(X) for matrix X, returns the number of rows and columns in
%   X as separate output variables. 
%   
%   [M1,M2,M3,...,MN] = SIZE(X) for N>1 returns the sizes of the first N 
%   dimensions of the array X.  If the number of output arguments N does
%   not equal NDIMS(X), then for:
%
%   N > NDIMS(X), SIZE returns ones in the "extra" variables, i.e., outputs
%                 NDIMS(X)+1 through N.
%   N < NDIMS(X), MN contains the product of the sizes of dimensions N
%                 through NDIMS(X).
%
%   M = SIZE(X,DIM) returns the length of the dimension specified
%   by the scalar DIM.  For example, SIZE(X,1) returns the number
%   of rows. If DIM > NDIMS(X), M will be 1.
%
%   When SIZE is applied to a Java array, the number of rows
%   returned is the length of the Java array and the number of columns
%   is always 1.  When SIZE is applied to a Java array of arrays, the
%   result describes only the top level array in the array of arrays.
%
%   Example:
%   If
%      X = rand(2,3,4);
%   then
%      d = size(X)              returns  d = [2 3 4]
%      [m1,m2,m3,m4] = size(X)  returns  m1 = 2, m2 = 3, m3 = 4, m4 = 1
%      [m,n] = size(X)          returns  m = 2, n = 12
%      m2 = size(X,2)           returns  m2 = 3
%
%   See also LENGTH, NDIMS, NUMEL.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

