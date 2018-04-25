%ISEQUAL True if arrays are numerically equal.
%   ISEQUAL(A,B) returns logical 1 (TRUE) if arrays A and B are the same
%   size and contain the same values, and logical 0 (FALSE) otherwise.
%   
%   If A is defined and you set B = A, ISEQUAL(A,B) is not necessarily
%   true. If A or B contains a NaN element, ISEQUAL returns false because
%   NaNs are not equal to each other by definition.
%
%   ISEQUAL(A,B,C,...) returns logical 1 if all the input arguments are
%   numerically equal, and logical 0 otherwise.
%
%   When comparing numeric values, ISEQUAL does not consider the class 
%   of the values in determining whether they are equal. In other words, 
%   INT8(5) and SINGLE(5) are considered equal. This is also true when
%   comparing numeric values with certain nonnumeric values. Numeric 1 
%   is equal to logical 1. The number 65 is equal to the character 'A'.
%
%   When comparing handle objects, use EQ or the == operator to test
%   whether objects are the same handle. Use ISEQUAL to test if objects
%   have equal property values, even if those objects are different
%   handles.
%
%   ISEQUAL recursively compares the contents of cell arrays and
%   structures.  If all the elements of a cell array or structure are
%   numerically equal, ISEQUAL returns 1.
%
%   When comparing structures, the order in which the fields of the 
%   structures were created is not important. As long as the structures 
%   contain the same fields, with corresponding fields set to equal values,
%   isequal considers the structures to be equal.
%
%   See also ISEQUALN, EQ.

%   Copyright 1984-2010 The MathWorks, Inc.
%   Built-in function.

