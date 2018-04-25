%POW2   Efficient fixed-point multiplication by a power of 2
%   B = POW2(A, K) returns the value of A shifted by K bits where K is an
%   integer and A and B are fi objects. The output B always has the same 
%   word length and fraction length as the input A. Note that, in fixed-point
%   arithmetic, shifting by K bits is equivalent to, and more efficient
%   than, computing B = A*(2^K).
%   If K is a non-integer, the pow2 function will round it to floor before
%   performing the calculation.
%   The scaling of A must be equivalent to binary point-only scaling; in
%   other words, it must have a power of 2 slope and a bias of 0.
%   A can be real or complex. If A is complex, pow2 operates on both the
%   real and complex portions of A.
%   The pow2 function obeys the RoundingMethod and OverflowAction associated with A.
%   If obeying the RoundingMethod property associated with A is not important, 
%   try using the 'bitshift' function.
%   The pow2 function does not support fi objects of data type Boolean.
%   The function also does not support the syntax B = pow2(A) when A is a
%   FI object.
%
%   Examples: 
%     In the first two examples, a is a real-valued fi object.
%     In the first example, K is a positive integer.
%     The pow2 function shifts the bits of a 3 places to the left,
%     effectively multiplying a by (2^3).
%     
%     a = fi(pi,1,16,8);
%     a_real = data(a)
%     % returns 3.1406, the real-world value of a
%     a_binary = bin(a)
%     % returns '0000001100100100', the binary representation of a
%     b = pow2(a,3);
%     b_real = data(b)
%     % returns 25.1250, the real-world value of b
%     b_binary = bin(b)
%     % returns '0001100100100000', the binary representation of b
%
%     In the second example, K is a negative integer; a is the same
%     fi object used in the first example.
%     The pow2 function shifts the bits of a 4 places to the right,
%     effectively multiplying a by (2^-4).
%
%     c = pow2(a,-4);
%     c_real = data(c)
%     % returns 0.1953, the real-world value of c
%     c_binary = bin(c)
%     % returns '0000000000110010', the binary representation of c
%
%     In the third example, a is a complex fi object.
%
%     format long g
%     a = fi(57 - 2i, 1, 16, 8);
%     data(a)
%     % returns 57 - 2i, the real-world value of a
%     d = pow2(a,2);
%     data(d)
%     % returns 127.99609375 - 8i, the real-world value of d
%
%   See also EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITSLL, EMBEDDED.FI/BITSRA,
%   EMBEDDED.FI/BITSRL

%   Copyright 1999-2012 The MathWorks, Inc.
