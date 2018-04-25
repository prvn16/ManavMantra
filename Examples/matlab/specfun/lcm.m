function c = lcm(a,b)
%LCM    Least common multiple.
%   LCM(A,B) is the least common multiple of corresponding elements of
%   A and B.  The arrays A and B must contain positive integers
%   and must be the same size (or either can be scalar).
%
%   Class support for inputs A,B:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also GCD.

%   Copyright 1984-2012 The MathWorks, Inc. 

if any(round(a(:)) ~= a(:) | round(b(:)) ~= b(:) | a(:) < 1 | b(:) < 1)
    error(message('MATLAB:lcm:InputNotPosInt'));
end
c = a.*(b./gcd(a,b));
