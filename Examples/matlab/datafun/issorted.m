%ISSORTED   Check if data is sorted.
%   TF = ISSORTED(A) returns TRUE if the elements of A are sorted in
%   ascending order, namely, returns TRUE if A and SORT(A) are identical:
%   - For vectors, ISSORTED(A) returns TRUE if A is a sorted vector.
%   - For matrices, ISSORTED(A) returns TRUE if each column of A is sorted.
%   - For N-D arrays, ISSORTED(A) returns TRUE if A is sorted along its
%     first non-singleton dimension.
%
%   TF = ISSORTED(A,DIM) checks if A is sorted along the dimension DIM.
%
%   TF = ISSORTED(A,DIRECTION) and TF = ISSORTED(A,DIM,DIRECTION) check if
%   A is sorted according to the specified direction. DIRECTION must be:
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
%
%   TF = ISSORTED(A,...,'MissingPlacement',M) also specifies where missing
%   elements (NaN/NaT/<undefined>/<missing>) should be placed:
%       'auto'  - (default) Missing elements placed last for ascending sort
%                 and first for descending sort.
%       'first' - Missing elements placed first.
%       'last'  - Missing elements placed last.
%
%   TF = ISSORTED(A,...,'ComparisonMethod',C) specifies how complex numbers
%   are sorted. The comparison method C must be:
%       'auto' - (default) Checks if real numbers are sorted according to
%                'real', and complex numbers according to 'abs'.
%       'real' - Checks if data is sorted according to REAL(A). For
%                elements with equal real parts, it also checks IMAG(A).
%       'abs'  - Checks if data is sorted according to ABS(A). For elements
%                with equal magnitudes, it also checks ANGLE(A).
%
%   Examples:
%     % Check if a vector is sorted in ascending order
%       issorted([1 2 2 2 4])
%     % Check if all columns are sorted in strictly descending order
%       A = [3 7 5; 0 4 2]
%       issorted(A,'strictdescend')
%     % Check if two vectors are strictly monotonic
%       issorted([1 2 4 8 9],'strictmonotonic')
%       issorted([9 7 2 1 0],'strictmonotonic')
%
%   See also SORT, ISSORTEDROWS, SORTROWS, UNIQUE.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.