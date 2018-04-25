function b = int8(a)
%INT8 Convert categorical array to an INT8 array.
%   B = INT8(A) converts the categorical array A to an INT8 array.  Each element
%   of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.  If A contains more
%   than INTMAX('int8') categories, the category indices saturate to INTMAX('int8')
%   when cast to INT8.
%
%   See also DOUBLE, UINT8.

%   Copyright 2006-2013 The MathWorks, Inc. 


b = int8(a.codes);
