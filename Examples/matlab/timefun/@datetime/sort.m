function [sorted,ind] = sort(this,varargin)
%SORT Sort datetimes in ascending or descending order.
%   B = SORT(A) sorts in ascending order.
%   The sorted output B is an array of datetimes with the same size as A:
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
%   missing elements (NaT) of A. M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements (NaT) first.
%       'last'  - Places missing elements (NaT) last.
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
%      % Create array of datetimes
%      dts = {'2012-12-22';'2063-04-05';'1992-01-12'}
%      A = datetime(dts,'Format','yyyy-MM-dd')
%      
%      % Sort datetimes.
%      [B,I] = sort(A)
%
%   See also ISSORTED, SORTROWS, MIN, MAX, MEAN, MEDIAN, UNIQUE.

%   Copyright 2014-2016 The MathWorks, Inc.

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:sort:InvalidAbsRealType',class(this)));
    end
end
% Lexicographic sort of complex data
if nargout < 2
    newdata = sort(this.data,varargin{:},'ComparisonMethod','real');
else
    [newdata,ind] = sort(this.data,varargin{:},'ComparisonMethod','real');
end
sorted = this;
sorted.data = newdata;