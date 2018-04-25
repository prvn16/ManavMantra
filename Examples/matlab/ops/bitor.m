%BITOR  Bit-wise OR.
%   C = BITOR(A,B) returns the bitwise OR of arguments A and B, 
%   where A and B are signed or unsigned integer arrays. If A and B are
%   double arrays, then they must contain non-negative elements less than
%   or equal to intmax('uint64').
%
%   C = BITOR(A,B,ASSUMEDTYPE) assumes A and B are of type ASSUMEDTYPE.
%   If A and B are double arrays, then ASSUMEDTYPE can be 'int8', 'uint8',
%   'int16', 'uint16', 'int32', 'uint32', 'int64', or 'uint64' (the default).
%   For example, BITOR(A,B,'int32') is equivalent to 
%   double(BITOR(int32(A),int32(B))). All elements in A and B must have 
%   integer values within the range of ASSUMEDTYPE. If A or B is of an 
%   integer type, then ASSUMEDTYPE must be this type.
%
%   Example:
%      Create a truth table:
%      A = uint8([0 1; 0 1])
%      B = uint8([0 0; 1 1])
%      TT = bitor(A,B)
%
%   See also BITAND, BITXOR, BITSHIFT, BITCMP, BITSET, BITGET, INTMAX.

%   Copyright 1984-2012 The MathWorks, Inc.
