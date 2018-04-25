function t = isvector(a)
%ISVECTOR True if categorical array is a vector.
%   ISVECTOR(V) returns logical 1 (true) if SIZE(V) returns [1 n] or [n 1] 
%   with a nonnegative integer value n, and logical 0 (false) otherwise.
%
%   See also ISSCALAR, ISMATRIX, ISEMPTY, ISROW, ISCOLUMN, SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

t = isvector(a.codes);
