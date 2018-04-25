%ISEQUALN True if arrays are numerically equal, treating NaNs as equal.
%   Numeric data types and structure field order
%   do not have to match.
%   NaNs are considered equal to each other.
%
%   ISEQUALN(A,B) is 1 if the two arrays are the same size
%   and contain the same values, and 0 otherwise.
%
%   ISEQUALN(A,B,C,...) is 1 if all the input arguments are
%   numerically equal.
%
%   ISEQUALN recursively compares the contents of cell
%   arrays and structures.  If all the elements of a cell array or
%   structure are numerically equal, ISEQUALN will return 1.
%
%   See also ISEQUAL, EQ.

%   Copyright 2011 The MathWorks, Inc.
%   Built-in function.

