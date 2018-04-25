function t = ismatrix(a)
%ISMATRIX True if categorical array is a matrix.
%   ISMATRIX(M) returns logical 1 (true) if SIZE(M) returns [m n] 
%   with nonnegative integer values m and n, and logical 0 (false) otherwise.
%
%   See also ISSCALAR, ISVECTOR, ISEMPTY, ISROW, ISCOLUMN, SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

t = ismatrix(a.codes);
