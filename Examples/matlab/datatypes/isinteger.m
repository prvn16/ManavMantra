%ISINTEGER True for arrays of integer data type.
%   ISINTEGER(A) returns true if A is an array of integer data type and false
%   otherwise.
%
%   The 8 integer data types in MATLAB are int8, uint8, int16, uint16,
%   int32, uint32, int64 and uint64.
%
%   Example:
%      isinteger(int8(3))
%      returns true because int8 is a valid integer data type but
%      isinteger (3)
%      returns false since the constant 3 is actually a double as is shown by
%      class(3)
%
%   See also ISA, ISNUMERIC, ISFLOAT.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

