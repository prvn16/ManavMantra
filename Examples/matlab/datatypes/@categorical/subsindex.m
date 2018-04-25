function i = subsindex(a)
%SUBSINDEX Subscript index for a categorical array.
%   I = SUBSINDEX(A) is called for the syntax 'X(A)' when A is a categorical
%   array and X is one of the built-in types (most commonly 'double'). SUBSINDEX
%   returns the category indices of A converted to zero-based integer indices by
%   subtracting 1.
%
%   SUBSINDEX is invoked separately on all the subscripts in an expression
%   such as X(A,B).
%  
%   See also CATEGORICAL/CATEGORICAL, DOUBLE.

%   Copyright 2008-2013 The MathWorks, Inc.

i = double(a.codes) - 1;
