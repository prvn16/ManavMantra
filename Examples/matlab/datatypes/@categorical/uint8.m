function b = uint8(a)
%UINT8 Convert categorical array to a UINT8 array.
%   B = UINT8(A) converts the categorical array A to a UINT8 array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.  If A contains more
%   than INTMAX('uint8') categories, the category indices saturate to
%   INTMAX('uint8') when cast to UINT8.
%
%   See also DOUBLE, INT8.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = uint8(a.codes);
