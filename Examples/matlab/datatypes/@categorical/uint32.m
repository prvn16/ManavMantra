function b = uint32(a)
%UINT32 Convert categorical array to an UINT32 array.
%   B = UINT32(A) converts the categorical array A to a UINT32 array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also DOUBLE, INT32.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = uint32(a.codes);
