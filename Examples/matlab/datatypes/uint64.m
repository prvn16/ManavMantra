%UINT64 Convert to unsigned 64-bit integer.
%   I = UINT64(X) converts the elements of the array X into unsigned
%   64-bit integers. X can be any numeric object, such as a DOUBLE. 
%   DOUBLE and SINGLE values are rounded to the nearest UINT64 value 
%   on conversion. If X is already an unsigned 64-bit integer array, 
%   then UINT64 has no effect. 
%
%   The values of a UINT64 range from 0 to 18,446,744,073,709,551,615, 
%   (that is, from INTMIN('uint64') to INTMAX('uint64')). Values outside 
%   this range are mapped to INTMIN('uint64') or INTMAX('uint64').
%
%   Some arithmetic operations are defined for UINT64 on interaction with
%   other UINT64 arrays. For example, +, -, .*, ./, .\ and .^.
%   If at least one operand is scalar, *, /, \ and ^ are also defined.
%   UINT64 arrays may also interact with scalar DOUBLE variables, including
%   constants, and the result of the operation is UINT64.
%   UINT64 arrays saturate on overflow in arithmetic.
%
%   You can define your own methods for the UINT64 class (as you can for any
%   object) by placing the appropriately named method in an @uint64
%   directory within a directory on your path.    
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large UINT64 arrays is: 
%
%      I = zeros(100,100,'uint64')
%
%   which creates a 100x100 element UINT64 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = 17 * ones(5,6,'uint64')
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   INT8, INT16, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   Built-in function.
