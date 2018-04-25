function b = char(a)
%CHAR Convert categorical array to character array.
%   B = CHAR(A) converts the categorical array A to a 2-dimensional character
%   matrix.  CHAR does not preserve the shape of A.  B contains NUMEL(A) rows,
%   and each row of B contains the category name for the corresponding element
%   of A(:).
%
%   See also CELLSTR, CATEGORIES, STRING.

%   Copyright 2006-2013 The MathWorks, Inc. 

names = [categorical.undefLabel; a.categoryNames];
b = char(names(a.codes+1));
