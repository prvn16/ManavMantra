%BITGET Get bit.
%   C = BITGET(A,BIT) returns the value of the bit at position BIT in A, 
%   where A is a signed or unsigned integer array. BIT must be between 1 
%   (least significant bit) and the number of bits in the integer 
%   class of A e.g., 32 for UINT32s or INT32s (most significant bit). If A 
%   is a double array, then all elements must be non-negative integers 
%   less than or equal to intmax('uint64'), and BIT must be between 
%   1 and 64.
%
%   C = BITGET(A,BIT,ASSUMEDTYPE) assumes A is of type ASSUMEDTYPE. If A is
%   a double array, ASSUMEDTYPE can be 'int8', 'uint8', 'int16', 'uint16', 
%   'int32', 'uint32', 'int64', or 'uint64' (the default). For example, 
%   BITGET(A,BIT,'int8') is equivalent to double(BITGET(int8(A),BIT)). All 
%   elements in A must have integer values within the range of ASSUMEDTYPE. 
%   If A is of an integer type, then ASSUMEDTYPE must be this type.
%
%   Example:
%      Prove that INTMAX sets all the bits to 1:
%
%      a = intmax('uint8')
%      if all(bitget(a,1:8)), disp('All the bits have value 1.'), end
%
%   See also BITSET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2012 The MathWorks, Inc.
