function [sorted,i] = sort(unsorted,varargin)
%SORT Sort durations in ascending or descending order.
%   B = SORT(A) sorts durations in ascending order.
%   The sorted output B is an array of durations with the same size as A:
%   - For vectors, SORT(A) sorts the elements of A in ascending order.
%   - For matrices, SORT(A) sorts each column of A in ascending order.
%   - For N-D arrays, SORT(A) sorts along the first non-singleton dimension.
%
%   B = SORT(A,DIM) also specifies a dimension DIM to sort along.
%
%   B = SORT(A,DIRECTION) and B = SORT(A,DIM,DIRECTION) also specify the
%   sort direction. DIRECTION must be:
%       'ascend'  - (default) Sorts in ascending order.
%       'descend' - Sorts in descending order.
%
%   B = SORT(A,...,'MissingPlacement',M) also specifies where to place the
%   missing elements (NaN) of A. M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements (NaN) first.
%       'last'  - Places missing elements (NaN) last.
%
%   [B,I] = SORT(A,...) also returns a sort index I which specifies how the
%   elements of A were rearranged to obtain the sorted output B:
%   - If A is a vector, then B = A(I).  
%   - If A is an m-by-n matrix and DIM = 1, then
%       for j = 1:n, B(:,j) = A(I(:,j),j); end
%   The sort odering is stable. Namely, when more than one element has the
%   same value, the order of the equal elements is preserved in the sorted
%   output B and the indices I relating to equal elements are ascending.
%
%   Example:
%
%     % Create an array of durations with random integers.  Sort the array
%     % and return the sorted version and sorting index.
%       dur = hours(randi(4,6,1))
%       [B,I] = sort(dur)
%
%   See also ISSORTED, SORTROWS, MIN, MAX, MEAN, MEDIAN, UNIQUE.

%   Copyright 2014-2016 The MathWorks, Inc.

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:sort:InvalidAbsRealType',class(unsorted)));
    end
end
sorted = unsorted;
if nargout < 2
    sorted.millis = sort(unsorted.millis,varargin{:});
else
    [sorted.millis,i] = sort(unsorted.millis,varargin{:});
end
