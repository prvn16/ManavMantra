function I = subsindex(A)
% SUBSINDEX Subscript index for a fi object.
%    I = SUBSINDEX(A) is called for the syntax 'X(A)' when A is a fi object
%    and X is one of the built-in types (most commonly 'double') or a fi
%    object. SUBSINDEX returns the double-precision floating point
%    real-world value of A converted to zero-based integer index.
%
%    SUBSINDEX is invoked separately on all the subscripts in an expression
%    such as X(A,B).
%
%    Examples:
%       % Use a fi object to index into another fi object
%       a = fi(2, 0, 3, 0)
%       x = fi(10:-1:1)
%       y = x(a)
%
%       % Use two fi objects to index into a double array 
%       a = fi(2, 1, 8, 4)
%       b = fi([1 0 1], 'DataType', 'Boolean')
%       x = reshape(1:9, 3, 3)
%       y = x(a, b)
%
%    See also SUBSINDEX, EMBEDDED.FI/SUBSASGN

%   Copyright 1999-2012 The MathWorks, Inc.

if isboolean(A)
    I = logical(A);
    I = find(I)-1;
else
    I = double(A)-1;
end
