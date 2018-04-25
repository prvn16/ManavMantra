function n = factorial(n)
%FACTORIAL Factorial function.
%   FACTORIAL(N) for scalar N, is the product of all the integers from 1 to N,
%   i.e. prod(1:N). When N is an N-D matrix, FACTORIAL(N) is the factorial for
%   each element of N.  Since double precision numbers only have about
%   15 digits, the answer is only accurate for N <= 21. For larger N,
%   the answer will have the correct order of magnitude, and is accurate for 
%   the first 15 digits.
%
%   Class support for input N:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also PROD.

%   Copyright 1998-2012 The MathWorks, Inc.

N = n(:);
if ~isreal(n) || any(fix(N) ~= N) || any(N < 0)
    error(message('MATLAB:factorial:NNegativeInt'))
end
if isa(n,'double')
    thres = 171;
elseif isa(n, 'single')
    thres = 35;
elseif isinteger(n)
    thres = 21;
else
    error(message('MATLAB:factorial:unsupportedType'));
end
N = min(N,thres);
m = max(1, max(N));
Fa = cumprod([1 1 2:m]);
n(:) = Fa(N+1);
