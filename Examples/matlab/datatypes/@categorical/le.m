function t = le(a,b)
%LE Less than or equal to for ordinal categorical arrays.
%   TF = LE(A,B) returns a logical array the same size as the ordinal
%   categorical arrays A and B, containing logical 1 (true) where the
%   elements of A are less than or equal to those of B, and logical 0
%   (false) otherwise. A and B must have the same sets of categories,
%   including their order.  Either A or B may also be a string scalar or
%   character vector.
%
%   Categorical arrays that are not ordinal can not be compared for less than or
%   equal to inequality.
%
%   TF = LE(A,S) or TF = LE(S,A), where S is a string or character vector,
%   returns a logical array the same size as A, containing logical 1 (true)
%   where the elements of A are less than or equal to the category S.  S
%   must be the name of one of the categories in A.
%
%   Undefined elements are not comparable to any other categorical values,
%   including other undefined elements.  LE returns logical 0 (false) where
%   elements of A or B are undefined.
%
%   See also EQ, NE, GE, GT, LT.

%   Copyright 2006-2016 The MathWorks, Inc.

[acodes,bcodes] = reconcileCategories(a,b,true);

% Undefined elements cannot be less than or equal to anything.
if isscalar(acodes) % faster scalar case
    if acodes > 0
        t = (acodes <= bcodes);
    else
        t = false(size(bcodes));
    end
else
    t = (acodes <= bcodes) & (acodes ~= 0);
end
