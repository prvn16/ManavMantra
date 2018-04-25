function t = issorted(a,varargin)
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
%   elements (<undefined>) should be placed:
%       'auto'  - (default) Missing elements placed last for ascending sort
%                 and first for descending sort.
%       'first' - Missing elements (<undefined>) placed first.
%       'last'  - Missing elements (<undefined>) placed last.
%
%   See also SORT, ISSORTEDROWS, SORTROWS, UNIQUE.

%   Copyright 2006-2017 The MathWorks, Inc. 

% Set the code value for undefined elements to NaN after changing to double
acodes = a.codes;
dcodes = double(acodes);
dcodes(acodes==categorical.undefCode) = NaN;

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:sort:InvalidAbsRealType',class(a)));
    end
end

t = issorted(dcodes,varargin{:});

