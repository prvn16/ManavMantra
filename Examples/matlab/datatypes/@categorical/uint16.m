function b = uint16(a)
%UINT16 Convert categorical array to an UINT16 array.
%   B = UINT16(A) converts the categorical array A to a UINT16 array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also DOUBLE, INT16.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = uint16(a.codes);
