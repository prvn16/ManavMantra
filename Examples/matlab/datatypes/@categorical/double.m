function b = double(a)
%DOUBLE Convert categorical array to DOUBLE array.
%   B = DOUBLE(A) converts the categorical array A to a DOUBLE array.  Each
%   element of B contains the category index for the corresponding element of A.
%
%   Undefined elements of A are assigned the value NaN in B.
%
%   See also SINGLE.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = double(a.codes);
b(b == 0) = NaN;
