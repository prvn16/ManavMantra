%MINK   Return smallest K elements from array
%   B = MINK(A,K) returns array B that has the same type as A:
%   - For vectors, MINK(A,K) returns the K smallest elements of A.
%   - For matrices, MINK(A,K) returns the K smallest elements for each 
%     column of A.
%   - For N-D arrays, MINK(A,K) returns the K smallest elements along the 
%     first dimension whose size does not equal one.
%
%   B = MINK(A,K,DIM) also specifies a dimension DIM to operate along.
%
%   B = MINK(...,'ComparisonMethod',C) specifies how to compare complex
%   numbers. The comparison method C must be:
%       'auto' - (default) Compares real numbers according to 'real', and
%                complex numbers according to 'abs'.
%       'real' - Compares according to REAL(A). Elements with equal real 
%                parts are then sorted by IMAG(A).
%       'abs'  - Compares according to ABS(A). Elements with equal 
%                magnitudes are then sorted by ANGLE(A).
%
%   [B,I] = MINK(...) also returns an index I that specifies how the
%   K elements of A were rearranged to obtain B:
%   - If A is a vector, then B = A(I).  
%   - If A is an m-by-n matrix and DIM = 1, then
%       for j = 1:n, B(:,j) = A(I(:,j),j); end
%
%   See also MAXK, SORT, TOPKROWS, MIN.

%   Copyright 2017 The MathWorks, Inc.
%   Built-in function.