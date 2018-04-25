function a = table2array(t,varargin)
%TABLE2ARRAY Convert table to a homogeneous array.
%   A = TABLE2ARRAY(T) converts the table T to an array A whose type depends on
%   the data in T.  All variables in T must have sizes and types that are
%   compatible for horizontal concatenation.
%
%   If T is an M-by-N table with variables that each have one column, then each
%   variable becomes one column in A.
%
%   Variables in T that have more than one column become multiple columns in A,
%   and A has L = SUM(TABLEFUN(@(V)SIZE(V,2),T) columns.  Variables in T may
%   have different numbers of columns.  Variables in T may be N-D, but all must
%   have the same size in dimensions higher than 2.  A is N-D in this case.
%
%   NOTE: TABLE2ARRAY horizontally concatenates the variables in T to create A.
%   If the variables in T are cell arrays, TABLE2ARRAY does not concatenate
%   their contents -- A is in this case a cell array, equivalent to
%   TABLE2CELL(T).  To create an array containing the contents of variables that
%   are all cell arrays, use CELL2MAT(TABLE2CELL(T)).
%
%   TABLE2ARRAY(T) is equivalent to T{:,:}.
%
%   See also ARRAY2TABLE, TABLE2CELL, TABLE2STRUCT, TABLE.

%   Copyright 2012 The MathWorks, Inc.

a = t{:,:};
