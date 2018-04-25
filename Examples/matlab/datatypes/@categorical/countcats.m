function c = countcats(a,dim)
%COUNTCATS Count occurrences of categories in a categorical array's elements.
%   C = COUNTCATS(A), for a categorical vector A, returns a vector C containing
%   the number of elements in A whose value is equal to each of A's categories.
%   C has one element for each category in A.
%
%   For matrices, COUNTCATS(A) is a matrix of counts.  Each column of C contains
%   counts for a column of A.  For N-D arrays, COUNTCATS(A) operates along the
%   first non-singleton dimension.
%  
%   C = COUNTCATS(A,DIM) operates along the dimension DIM.
%
%   See also ISCATEGORY, ISMEMBER, SUMMARY.

%   Copyright 2013 The MathWorks, Inc. 

if nargin < 2
    c = histc(a.codes,1:length(a.categoryNames));
else
    c = histc(a.codes,1:length(a.categoryNames),dim);
end

