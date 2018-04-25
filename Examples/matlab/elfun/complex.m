%   COMPLEX Create complex array.
%   C = COMPLEX(A,B) returns the complex result A + Bi, where A and B are
%   identically sized real N-D arrays, matrices, or scalars of the same data type.
%   Note: In the event that B is all zeros, C is complex with all zero imaginary
%   part, unlike the result of the addition A+0i, which returns a 
%   strictly real result.
%
%   C = COMPLEX(A) for real A returns the complex result C with real part A
%   and all zero imaginary part. Even though its imaginary part is all zero,
%   C is complex and so isreal(C) returns false. If A is complex, C is identical
%   to A.
%
%   The complex function provides a useful substitute for expressions such as
%   A+1i*B or A+1j*B in cases when A and B are not single or double, or when
%   B is all zero.
%
%   See also  I, J, IMAG, CONJ, ANGLE, ABS, REAL, ISREAL.

%   Copyright 1984-2013 The MathWorks, Inc.
%   Built-in function.

