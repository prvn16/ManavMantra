function b = int64(a)
%INT64 Convert categorical array to an INT64 array.
%   B = INT64(A) converts the categorical array A to an INT64 array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also DOUBLE, UINT64.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = int64(a.codes);
