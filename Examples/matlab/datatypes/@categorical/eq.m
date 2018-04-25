function t = eq(a,b)
%EQ Equality for categorical arrays.
%   TF = EQ(A,B) returns a logical array the same size as the categorical
%   arrays A and B, containing logical 1 (true) where the corresponding
%   elements of A and B are equal, and logical 0 (false) otherwise.  Either
%   A or B may also be a string scalar or character vector.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the test is performed by comparing the
%   category names of each pair of elements.
%
%   TF = EQ(A,S) or TF = EQ(S,A), where S is a string or character vector,
%   returns a logical array the same size as A, containing logical 1 (true)
%   where the corresponding elements of A are equal to S.
%
%   Undefined elements are not comparable to any other categorical values,
%   including other undefined elements.  EQ returns logical 0 (false) where
%   elements of A or B are undefined.
%
%   See also NE.

%   Copyright 2006-2016 The MathWorks, Inc.

[acodes,bcodes] = reconcileCategories(a,b,false);

% Undefined elements cannot be equal to anything.
if isscalar(acodes) % faster scalar case
    if acodes > 0
        t = (acodes == bcodes);
    else
        t = false(size(bcodes));
    end
elseif isscalar(bcodes) % faster scalar case
    if bcodes > 0
        t = (acodes == bcodes);
    else
        t = false(size(acodes));
    end
else
    t = (acodes == bcodes) & (acodes ~= 0);
end

