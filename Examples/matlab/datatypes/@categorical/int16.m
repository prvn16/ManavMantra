function b = int16(a)
%INT16 Convert categorical array to an INT16 array.
%   B = INT16(A) converts the categorical array A to an INT16 array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.  If A contains more
%   than INTMAX('int16') categories, the category indices saturate to INTMAX('int16')
%   when cast to INT16.
%
%   See also DOUBLE, UINT16.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = int16(a.codes);
