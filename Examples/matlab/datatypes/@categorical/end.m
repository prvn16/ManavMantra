function e = end(a,k,n)
%END Last index in an indexing expression for a categorical array.
%   END(A,K,N) is called for indexing expressions involving the categorical
%   array A when END is part of the K-th index out of N indices.  For example,
%   the expression A(end-1,:) calls A's END method with END(A,1,2).
%
%   See also SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

e = builtin('end',a.codes,k,n);
