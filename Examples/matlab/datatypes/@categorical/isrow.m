function t = isrow(a)
%ISROW True if categorical array is a row vector.
%   ISROW(V) returns logical 1 (true) if SIZE(V) returns [1 n] 
%   with a nonnegative integer value n, and logical 0 (false) otherwise.
%
%   See also ISCOLUMN, ISSCALAR, ISVECTOR, ISMATRIX, ISEMPTY, SIZE.

%   Copyright 2012-2013 The MathWorks, Inc. 

t = isrow(a.codes);
