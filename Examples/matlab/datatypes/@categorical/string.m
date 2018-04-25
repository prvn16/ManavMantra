function b = string(a)
%STRING Convert categorical array to a string array.
%   B = STRING(A) converts the categorical array A to a string array.
%   Each element of B contains the category name for the corresponding element
%   of A.
%
%   See also CELLSTR, CHAR, CATEGORIES.

%   Copyright 2016 The MathWorks, Inc.

names = string([string(nan); a.categoryNames]);
b = reshape(names(a.codes+1),size(a.codes));
