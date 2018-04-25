function f = factor(n)
%FACTOR Prime factors.
%   FACTOR(N) returns a vector containing the prime factors of N.
%
%   This function uses the simple sieve approach. It may require large
%   memory allocation if the number given is too big. Technically it is
%   possible to improve this algorithm, allocating less memory for most
%   cases and resulting in a faster execution time. However, it will still
%   have problems in the worst case.
% 
%   Class support for input N:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also PRIMES, ISPRIME.

%   Copyright 1984-2014 The MathWorks, Inc. 

if ~isscalar(n)
    error(message('MATLAB:factor:NonScalarInput'));
end
if ~isreal(n) || (n < 0) || (floor(n) ~= n) 
  error(message('MATLAB:factor:InputNotPosInt')); 
end
if (isfloat(n) && n > flintmax(class(n)))
    error(message('MATLAB:factor:InputOutOfRange'));
end

if n < 4
   f = floor(n); 
   return
else
   f = [];
end

if (isa(n,'uint64') || isa(n,'int64')) && n > flintmax
    p = primes(2.^(nextpow2(n)/2));
else
    p = primes(cast(sqrt(double(n)),class(n)));
end
while n>1,
  d = find(rem(n,p)==0);
  if isempty(d)
    f = [f n];
    break; 
  end
  p = p(d);
  f = [f p];
  n = n/prod(p);
end

f = sort(f);
