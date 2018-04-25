function tf = issortedrows(this,varargin)
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
%                           not contain duplicates.
%       'strictdescend'   - Checks if data is in descending order and does
%                           not contain duplicates.
%       'strictmonotonic' - Checks if data is either ascending or
%                           descending, and does not contain duplicates.
%   You can also use a different direction for each column specified by
%   COL, for example, ISSORTEDROWS(A,[2 3],{'ascend' 'descend'}).
%
%   TF = ISSORTEDROWS(A,...,'MissingPlacement',M) also specifies where
%   missing elements (NaT) should be placed:
%       'auto'  - (default) Missing elements placed last for ascending sort
%                 and first for descending sort.
%       'first' - Missing elements (NaT) placed first.
%       'last'  - Missing elements (NaT) placed last.
%
%   See also SORTROWS, ISSORTED, SORT, UNIQUE.

%   Copyright 2016 The MathWorks, Inc.

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:sort:InvalidAbsRealType',class(this)));
    end
end
tf = issortedrows(this.data,varargin{:},'ComparisonMethod','real');
