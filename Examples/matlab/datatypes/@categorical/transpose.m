function b = transpose(a)
%TRANSPOSE Transpose a categorical matrix.
%   B = TRANSPOSE(A) returns the transpose of the 2-dimensional categorical
%   matrix A.  Note that CTRANSPOSE is identical to TRANSPOSE for categorical
%   arrays.
%
%   TRANSPOSE is called for the syntax A.'.
%
%   See also CTRANSPOSE, PERMUTE.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = a;
b.codes = a.codes.';
