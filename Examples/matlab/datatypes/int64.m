%INT64 Convert to signed 64-bit integer.
%   I = INT64(X) converts the elements of array X into signed 64-bit
%   integers. X can be any numeric object (such as a DOUBLE). DOUBLE
%   and SINGLE values are rounded to the nearest INT64 value on 
%   conversion. If X is already a signed 64-bit integer array, then
%   INT64 has no effect. 
%
%   The values of an INT64 range from -9,223,372,036,854,775,808 to
%   9,223,372,036,854,775,807, (that is, from INTMIN('int64') to 
%   INTMAX('int64')). Values outside this range are mapped to INTMIN('int64') 
%   or INTMAX('int64').
%
%   Some arithmetic operations are defined for INT64 on interaction with
%   other INT64 arrays. For example, +, -, .*, ./, .\ and .^.
%   If at least one operand is scalar, *, /, \ and ^ are also defined.
%   INT64 arrays may also interact with scalar DOUBLE variables, including
%   constants, and the result of the operation is INT64.
%   INT64 arrays saturate on overflow in arithmetic.
%
%   You can define your own methods for the INT64 CLASS (as you can for any
%   object) by placing the appropriately named method in an @int64
%   directory within a directory on your path.
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large INT64 arrays is: 
%
%      I = zeros(100,100,'int64')
%
%   which creates a 100x100 element INT64 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = 17 * ones(5,6,'int64')
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   UINT64, INT8, INT16, INT32, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   Built-in function.
