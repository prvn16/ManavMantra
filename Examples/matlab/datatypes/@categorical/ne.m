function t = ne(a,b)
%NE Not equal for categorical arrays.
%   TF = NE(A,B) returns a logical array the same size as the categorical
%   arrays A and B, containing logical 1 (true) where the corresponding
%   elements of A and B are not equal, and logical 0 (false) otherwise.
%   Either A or B may also be a string scalar or character vector.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the test is performed by comparing the
%   category names of each pair of elements.
%
%   TF = NE(A,S) or TF = NE(S,A), where S is a string or character vector,
%   returns a logical array the same size as A, containing logical 1 (true)
%   where the corresponding elements of A are not equal to S.
%
%   Undefined elements are not comparable to any other categorical values,
%   including other undefined elements.  EQ returns logical 1 (true) where
%   elements of A or B are undefined.
%
%   See also EQ.

%   Copyright 2006-2016 The MathWorks, Inc.

[acodes,bcodes] = reconcileCategories(a,b,false);

% Undefined elements are not equal to everything.
if isscalar(acodes) % faster scalar case
    if acodes > 0
        t = (acodes ~= bcodes);
    else
        t = true(size(bcodes));
    end
elseif isscalar(bcodes) % faster scalar case
    if bcodes > 0
        t = (acodes ~= bcodes);
    else
        t = true(size(acodes));
    end
else
    t = (acodes ~= bcodes) | (acodes == 0) | (bcodes == 0);
end
