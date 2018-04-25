function b = single(a)
%SINGLE Convert categorical array to SINGLE array.
%   B = SINGLE(A) converts the categorical array A to a SINGLE array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value NaN in B.
%
%   See also DOUBLE.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = single(a.codes);
b(b == 0) = NaN;
