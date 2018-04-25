%ISSORTEDROWS   Check if matrix rows are sorted
%   TF = ISSORTEDROWS(A) returns TRUE if the rows of matrix A are sorted in
%   ascending order as a group, namely, returns TRUE if A and SORTROWS(A)
%   are identical. A must be a 2-D matrix.
%
%   TF = ISSORTEDROWS(A,COL) checks if the rows are sorted according to the
%   columns specified by the vector COL.  If an element of COL is positive,
%   SORTROWS checks if the corresponding column in A is sorted in ascending
%   order; if an element of COL is negative, it checks if the corresponding
%   column in A is sorted in descending order. For example,
%   ISSORTEDROWS(A,[2 -3]) first checks if the rows are sorted in ascending
%   order according to column 2; then, checks if rows with equal entries in
%   column 2 are sorted in descending order according to column 3.
%
%   TF = ISSORTEDROWS(A,DIRECTION) and TF = ISSORTEDROWS(A,COL,DIRECTION)
%   check if the rows are sorted according to the specified direction:
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
%   You can also use a different direction for each column specified by
%   COL, for example, ISSORTEDROWS(A,[2 3],{'ascend' 'descend'}).
%
%   TF = ISSORTEDROWS(A,...,'MissingPlacement',M) also specifies where
%   missing elements (NaN/NaT/<undefined>/<missing>) should be placed:
%       'auto'  - (default) Missing elements placed last for ascending sort
%                 and first for descending sort.
%       'first' - Missing elements placed first.
%       'last'  - Missing elements placed last.
%
%   TF = ISSORTEDROWS(A,...,'ComparisonMethod',C) specifies how complex
%   numbers are sorted. The comparison method C must be:
%       'auto' - (default) Checks if real numbers are sorted according to
%                'real', and complex numbers according to 'abs'.
%       'real' - Checks if data is sorted according to REAL(A). For
%                elements with equal real parts, it also checks IMAG(A).
%       'abs'  - Checks if data is sorted according to ABS(A). For elements
%                with equal magnitudes, it also checks ANGLE(A).
%
%   Examples:
%     % Check if rows are sorted in ascending order
%       A = magic(5)
%       issortedrows(A)
%     % Check if rows are sorted in ascending order according to column 3
%       A = magic(5)
%       issortedrows(A,3)
%     % Check if rows are sorted in descending order
%       A = eye(4)
%       issortedrows(A,'descend')
%
%   See also SORTROWS, ISSORTED, SORT, UNIQUE.

%   Copyright 2016-2017 The MathWorks, Inc.
%   Built-in function.