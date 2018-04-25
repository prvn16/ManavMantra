function [b,idx] = sortrows(a,vars,sortMode,varargin)
%SORTROWS Sort rows of a timetable.
%   B = SORTROWS(A) returns a copy of the timetable A, with the rows sorted
%   in ascending order by time.
%
%   B = SORTROWS(A,VARS) sorts the rows in A by the variables specified by
%   VARS. VARS must be a positive integer, a vector of positive integers, a
%   variable name, a cell array containing one or more variable names, or a
%   logical vector. VARS can also include the name of the row dimension, i.e.
%   A.Properties.DimensionNames{1}, to sort by time as well as by data
%   variables. By default, the row dimension name is 'Time'.
%
%   The rows in B are sorted first by the first variable, next by the second
%   variable, and so on.  Each variable in A must be a valid input to SORT, or,
%   if the variable has multiple columns, to the MATLAB SORTROWS function or to
%   its own SORTROWS method.
%
%   VARS can also contain a mix of positive and negative integers.  If an
%   element of VARS is positive, the corresponding variable in A will be
%   sorted in ascending order; if an element of VARS is negative, the
%   corresponding variable in A will be sorted in descending order.  These
%   signs are ignored if you provide the MODE input described below.
%
%   B = SORTROWS(A,VARS,DIRECTION) also specifies the sort direction(s):
%       'ascend'  - (default) Sorts in ascending order.
%       'descend' - Sorts in descending order.
%   SORTROWS sorts A in ascending or descending order according to all
%   variables specified by VARS. You can also use a different direction for
%   each variable by specifying multiple 'ascend' and 'descend' directions,
%   for example, SORTROWS(X,[2 3],{'ascend' 'descend'}).
%   Specify VARS as 1:SIZE(A,2) to sort using all variables.
%
%   B = SORTROWS(A,VARS,DIRECTION,'MissingPlacement',M) specifies where to
%   place the missing elements (NaN/NaT/<undefined>/<missing>). M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements first.
%       'last'  - Places missing elements last.
%
%   B = SORTROWS(A,VARS,DIRECTION,...,'ComparisonMethod',C) specifies how
%   to sort complex numbers. The comparison method C must be:
%       'auto' - (default) Sorts real numbers according to 'real', and
%                complex numbers according to 'abs'.
%       'real' - Sorts according to REAL(A). Elements with equal real parts
%                are then sorted by IMAG(A).
%       'abs'  - Sorts according to ABS(A). Elements with equal magnitudes
%                are then sorted by ANGLE(A).
%
%   [B,I] = SORTROWS(A,...) also returns an index vector I which describes
%   the order of the sorted rows, namely, B = A(I,:).
%
%   See also ISSORTEDROWS, UNIQUE.

%   Copyright 2016 The MathWorks, Inc.

if nargin < 2
    vars = a.metaDim.labels(1);
end

if nargin < 3
    [b,idx] = sortrows@tabular(a,vars);
else
    [b,idx] = sortrows@tabular(a,vars,sortMode,varargin{:});
end
