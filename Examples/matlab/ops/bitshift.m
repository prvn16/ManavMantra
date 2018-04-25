%BITSHIFT Bit-wise shift.
%   C = BITSHIFT(A,K) returns the value of A shifted to the left by K bits, 
%   where A is a signed or unsigned integer array. Shifting by K bits
%   is the same as multiplication by 2^K. Negative values of K are allowed 
%   and this corresponds to shifting to the right, or dividing by 2^ABS(K) 
%   and rounding to the nearest integer towards negative infinity. If the 
%   shift causes C to overflow the number of bits in the integer class of A, 
%   then the overflowing bits are dropped.
%
%   If A is a double array, then all elements must be non-negative integers
%   less than or equal to intmax('uint64'), and BITSHIFT 
%   drops any bits overflowing 64 bits.
%
%   BITSHIFT returns the result of arithmetic shifts.
%      * When K is positive, 0-valued bits are shifted in on the right.
%      * When K is negative, and A is non-negative, 0-valued bits 
%        are shifted in on the left.
%      * When K is negative, and A is negative, 1-valued bits are
%        shifted in on the left.
%   Note that if A is signed, the signed bit is always preserved if K is
%   negative, and not preserved if K is positive.
%
%   C = BITSHIFT(A,K,ASSUMEDTYPE) assumes A is of type ASSUMEDTYPE. If A
%   is a double array, then ASSUMEDTYPE can be 'int8', 'uint8', 'int16', 
%   'uint16', 'int32', 'uint32', 'int64', or 'uint64' (the default). For
%   example, BITSHIFT(A,K,'int8') is equivalent to 
%   double(BITSHIFT(int8(A),K)). All elements in A must have integer values 
%   within the range of ASSUMEDTYPE. If A is of an integer type, then 
%   ASSUMEDTYPE must be this type.
%
%   Example:
%      Repeatedly shift the bits of an unsigned 16 bit value to the left
%      until all the nonzero bits overflow. Track the progress in binary.
%
%      a = intmax('uint16');
%      fprintf('Initial uint16 value %5d is %016s in binary\n', ...
%         a,dec2bin(a))
%      for i = 1:16
%         a = bitshift(a,1);
%         fprintf('Shifted uint16 value %5d is %016s in binary\n',...
%            a,dec2bin(a))
%      end
%
%   See also BITAND, BITOR, BITXOR, BITCMP, BITSET, BITGET, INTMAX.

%   Copyright 1984-2014 The MathWorks, Inc.
