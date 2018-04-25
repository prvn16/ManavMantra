function C = clipdivide(A, B)
%CLIPDIVIDE Elementwise division with denominator clipping.
%   C = CLIPDIVIDE(A, B) modifies B so that no element is less than eps,
%   and then it performs element-wise division of A by the modified
%   version of B.  A and B must be real double arrays.

%   Copyright 1993-2003 The MathWorks, Inc.

B(B < eps) = eps;
C = A ./ B;
