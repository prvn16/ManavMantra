function b = int32(a)
%INT32 Convert categorical array to an INT32 array.
%   B = INT32(A) converts the categorical array A to an INT32 array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also DOUBLE, UINT32.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = int32(a.codes);
