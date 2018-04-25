%ISHERMITIAN Determine whether a matrix is real symmetric or complex Hermitian.
%   ISHERMITIAN(X) returns true if a square matrix X is Hermitian. 
%   That is, X equals to X'. Otherwise, it returns false.
%
%   ISHERMITIAN(X,'skew') returns true if a square matrix X is skew-Hermitian.
%   That is, X equals to -X'. Otherwise, it returns false.
%
%   ISHERMITIAN(X, 'nonskew') is same as ISHERMITIAN(X).
%
%   X must be a double or single matrix.
%
%   See also ISSYMMETRIC.

%   Copyright 2013 The MathWorks, Inc.
%   Built-in function.
