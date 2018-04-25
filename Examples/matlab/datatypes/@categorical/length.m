function n = length(a)
%LENGTH Length of a categorical vector.
%   N = LENGTH(A), when A is not empty, returns the size of the longest
%   dimension of the categorical array A.  If A is a vector, this is the same
%   as its length.  LENGTH is equivalent to MAX(SIZE(X)) for non-empty arrays,
%   and 0 for empty arrays.
%
%   See also NUMEL, SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

n = length(a.codes);
