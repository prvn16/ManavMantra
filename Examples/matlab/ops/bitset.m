%BITSET Set bit.
%   C = BITSET(A,BIT) sets bit position BIT in A to 1 (on), where A is a 
%   signed or unsigned integer array. BIT must be between 1 (least 
%   significant bit) and the number of bits in the integer class of A, 
%   e.g., 32 for UINT32s or INT32s (most significant bit). If A is a double
%   array, then all elements must be non-negative integers less than or 
%   equal to intmax('uint64'), and BIT must be between 1 and 64.
%
%   C = BITSET(A,BIT,V) sets the bit at position BIT according to V.
%   Zero values of V sets the bit to 0 (off), and non-zero values of
%   V sets the bit to 1 (on).
%
%   C = BITSET(A,BIT,ASSUMEDTYPE) or C = BITSET(A,BIT,V,ASSUMEDTYPE) assumes
%   A is of type ASSUMEDTYPE. If A is a double array, then ASSUMEDTYPE can 
%   be 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', or
%   'uint64' (the default). For example, BITSET(A,BIT,'int8') is equivalent 
%   to double(BITSET(int8(A),BIT)). All elements in A must have integer 
%   values within the range of ASSUMEDTYPE. If A is of an integer type, then
%   ASSUMEDTYPE must be this type.
%
%   Example:
%      Repeatedly subtract powers of 2 from the largest UINT32 value:
%
%      a = intmax('uint32')
%      for i = 1:32, a = bitset(a,32-i+1,0), end
%
%   See also BITGET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2017 The MathWorks, Inc.
