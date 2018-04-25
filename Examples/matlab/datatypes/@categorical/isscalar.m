function t = isscalar(a)
%ISSCALAR True if categorical array is a scalar.
%   ISSCALAR(S) returns logical 1 (true) if SIZE(S) returns [1 1] and 
%   logical 0 (false) otherwise.
%
%   See also ISVECTOR, ISMATRIX, ISEMPTY, ISROW, ISCOLUMN, SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

t = isscalar(a.codes);
