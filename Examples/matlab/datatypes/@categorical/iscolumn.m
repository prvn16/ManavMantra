function t = iscolumn(a)
%ISCOLUMN True if categorical array is a column vector.
%   ISCOLUMN(V) returns logical 1 (true) if SIZE(V) returns [n 1] 
%   with a nonnegative integer value n, and logical 0 (false) otherwise.
%
%   See also ISROW, ISSCALAR, ISVECTOR, ISMATRIX, ISEMPTY, SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

t = iscolumn(a.codes);
