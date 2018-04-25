%REINTERPRETCAST Convert fixed-point or integer data types without changing underlying data
%   C = REINTERPRETCAST(A, T) converts the input (integer or fi object) A
%   to the data type specified by numerictype object T, without changing
%   the underlying data. The result is returned in fi object C.
%
%   The data type of the input A must be fixed point or integer. T must be
%   a numerictype object with a fully specified fixed-point data type.  The
%   word length of inputs A and T must be the same.
%
%   The REINTERPRETCAST function differs from the MATLAB TYPECAST and CAST
%   functions, in that it only operates on fi and integer types, and it
%   does not allow the word length of the input to change.
%
%   EXAMPLE:
%     %% Convert from signed 8,7 to unsigned 8,0.
%     a = fi([-1 pi/4], true, 8, 7)
%     %   returns [-1.0000    0.7891] s8,7
%     
%     T = numerictype(false, 8, 0);
%     b = reinterpretcast(a, T)
%     %   returns [128   101] u8,0
%     
%     % Their binary representations are identical
%     binary_rep = [bin(a);bin(b)]
%     %    returns 10000000   01100101
%     %            10000000   01100101
%
%   See also FI, NUMERICTYPE, TYPECAST, CAST.

%   Copyright 2008-2012 The MathWorks, Inc.


