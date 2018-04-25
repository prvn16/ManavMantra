function tf = issortedrows(a,vars,sortMode,varargin)
%ISSORTEDROWS TRUE for a sorted timetable.
%   TF = ISSORTEDROWS(A) returns TRUE if the rows of timetable A are sorted
%   in ascending order by time, namely, returns TRUE if A and SORTROWS(A)
%   are identical.
%
%   TF = ISSORTEDROWS(A,VARS) checks if the rows of timetable A are sorted
%   by the variables specified by VARS. VARS is a positive integer, a
%   vector of positive integers, a variable name, a cell array containing
%   one or more variable names, or a logical vector. VARS can also include
%   the name of the row dimension, i.e. A.Properties.DimensionNames{1}, to
%   check if A is sorted by time as well as by data variables. By default,
%   the row dimension name is 'Time'.
%
%   VARS can also contain a mix of positive and negative integers.  If an
%   element of VARS is positive, the corresponding variable in A will be
%   sorted in ascending order; if an element of VARS is negative, the
%   corresponding variable in A will be sorted in descending order.  These
%   signs are ignored if you provide the MODE input described below.
%
%   TF = ISSORTEDROWS(A,VARS,DIRECTION) checks if the rows are sorted
%   according to the direction(s) specified by MODE:
%       'ascend'          - (default) Checks if data is in ascending order.
%       'descend'         - Checks if data is in descending order.
%       'monotonic'       - Checks if data is in either ascending or
%                           descending order.
%       'strictascend'    - Checks if data is in ascending order and does
%                           not contain duplicate or missing elements.
%       'strictdescend'   - Checks if data is in descending order and does
%                           not contain duplicate or missing elements.
%       'strictmonotonic' - Checks if data is in either ascending or
%                           descending order and does not contain duplicate
%                           or missing elements.
%   You can also use a different direction for each variable specified by
%   VARS, for example, ISSORTEDROWS(A,[2 3],{'ascend' 'descend'}).
%
%   TF = ISSORTEDROWS(A,VARS,DIRECTION,'MissingPlacement',M) specifies
%   where missing elements (NaN/NaT/<undefined>/<missing>) should be placed:
%       'auto'  - (default) Missing elements placed last for ascending sort
%                 and first for descending sort.
%       'first' - Missing elements placed first.
%       'last'  - Missing elements placed last.
%
%   TF = ISSORTEDROWS(A,VARS,DIRECTION,...,'ComparisonMethod',C) specifies
%   how complex numbers are sorted. The comparison method C must be:
%       'auto' - (default) Checks if real numbers are sorted according to
%                'real', and complex numbers according to 'abs'.
%       'real' - Checks if data is sorted according to REAL(A). For
%                elements with equal real parts, it also checks IMAG(A).
%       'abs'  - Checks if data is sorted according to ABS(A). For elements
%                with equal magnitudes, it also checks ANGLE(A).
%
%   See also SORTROWS, UNIQUE.

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin < 2
    vars = a.metaDim.labels(1);
end

if nargin < 3
    tf = issortedrows@tabular(a,vars);
else
    tf = issortedrows@tabular(a,vars,sortMode,varargin{:});
end
