function b = uint64(a)
%UINT64 Convert categorical array to a UINT64 array.
%   B = UINT64(A) converts the categorical array A to a UINT64 array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also DOUBLE, INT64.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = uint64(a.codes);
