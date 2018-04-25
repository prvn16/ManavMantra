function p = primes(n)
%PRIMES Generate list of prime numbers.
%   PRIMES(N) is a row vector of the prime numbers less than or 
%   equal to N.  A prime number is one that has no factors other
%   than 1 and itself.
%
%   Class support for input N:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also FACTOR, ISPRIME.

%   Copyright 1984-2013 The MathWorks, Inc. 

if ~isscalar(n) 
  error(message('MATLAB:primes:InputNotScalar'));
elseif ~isreal(n)
  error(message('MATLAB:primes:ComplexInput'));
end
if n < 2
  p = zeros(1,0,class(n)); 
  return
elseif isfloat(n) && n > flintmax(class(n))
  warning(message('MATLAB:primes:NGreaterThanFlintmax'));
  n = flintmax(class(n));  
end
n = floor(n);
p = true(1,double(ceil(n/2)));
q = length(p);
if (isa(n,'uint64') || isa(n,'int64')) && n > flintmax
  ub = 2.^(nextpow2(n)/2);  %avoid casting large (u)int64 to double
else
  ub = sqrt(double(n));
end
for k = 3:2:ub
  if p((k+1)/2)
     p(((k*k+1)/2):k:q) = false;
  end
end
p = cast(find(p)*2-1,class(n));
p(1) = 2;

