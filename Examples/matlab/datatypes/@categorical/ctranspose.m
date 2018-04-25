function b = ctranspose(a)
%CTRANSPOSE Transpose a categorical matrix.
%   B = CTRANSPOSE(A) returns the transpose of the 2-dimensional categorical
%   matrix A.  Note that CTRANSPOSE is identical to TRANSPOSE for categorical
%   arrays.
%
%   CTRANSPOSE is called for the syntax A'.
%
%   See also TRANSPOSE, PERMUTE.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = a;
b.codes = a.codes';
