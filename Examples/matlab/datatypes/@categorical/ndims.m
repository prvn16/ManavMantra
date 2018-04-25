function n = ndims(a)
%NDIMS Number of dimensions of a categorical array.
%   N = NDIMS(A) returns the number of dimensions in the categorical array A.
%   The number of dimensions in an array is always greater than or equal to 2.
%   Trailing singleton dimensions are ignored. Put simply, NDIMS(A) is
%   LENGTH(SIZE(A)).
%
%   See also SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

n = ndims(a.codes);
