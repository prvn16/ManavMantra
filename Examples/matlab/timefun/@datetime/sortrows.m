function [sorted,ind] = sortrows(this,varargin)
%SORTROWS Sort rows of a matrix of datetimes.
%   B = SORTROWS(A) sorts the rows of the 2-D matrix of datetimes A in
%   ascending order. B is a matrix of datetimes with the same size as A.
%   
%   B = SORTROWS(A,COL) sorts the matrix according to the columns specified
%   by the vector COL.  If an element of COL is positive, the corresponding
%   column in A is sorted in ascending order; if an element of COL is
%   negative, the corresponding column in A is sorted in descending order.
%   For example, SORTROWS(A,[2 -3]) first sorts the rows in ascending order
%   according to column 2; then, rows with equal entries in column 2 get
%   sorted in descending order according to column 3.
%
%   B = SORTROWS(A,DIRECTION) and B = SORTROWS(A,COL,DIRECTION) also
%   specify the sort direction(s). DIRECTION must be:
%       'ascend'  - (default) Sorts in ascending order.
%       'descend' - Sorts in descending order.
%   You can also use a different direction for each column by specifying
%   DIRECTION as a collection of 'ascend' and 'descend' directions. For
%   example, SORTROWS(X,[2 3],{'ascend' 'descend'}) first sorts rows in
%   ascending order according to column 2; then, rows with equal entries in
%   column 2 get sorted in descending order according to column 3.
%
%   B = SORTROWS(A,...,'MissingPlacement',M) also specifies where to place
%   the missing elements (NaT) of A. M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements (NaT) first.
%       'last'  - Places missing elements (NaT) last.
%
%   [B,I] = SORTROWS(A,...) also returns an index vector I which describes
%   the order of the sorted rows, namely, B = A(I,:).
%
%   See also ISSORTEDROWS, SORT, UNIQUE.

%   Copyright 2014-2016 The MathWorks, Inc.

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:sortrows:InvalidAbsRealType',class(this)));
    end
end
% Lexicographic sort of complex data
if nargout < 2
    newdata = sortrows(this.data,varargin{:},'ComparisonMethod','real');
else
    [newdata,ind] = sortrows(this.data,varargin{:},'ComparisonMethod','real');
end
sorted = this;
sorted.data = newdata;