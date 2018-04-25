function p = nextpow2(n)
%NEXTPOW2 Next higher power of 2.
%   NEXTPOW2(N) returns the first P such that 2.^P >= abs(N).  It is
%   often useful for finding the nearest power of two sequence
%   length for FFT operations.
%
%   Class support for input N:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also LOG2, POW2.

%   Copyright 1984-2012 The MathWorks, Inc. 

if ~isinteger(n)
  [f,p] = log2(abs(n));

  % Check for exact powers of 2.
  k = (f == 0.5);
  p(k) = p(k)-1;

  % Check for infinities and NaNs
  k = ~isfinite(f);
  p(k) = f(k);

else % integer case
  p = zeros(size(n),class(n));
  nabs = abs(n);
  x = bitshift(nabs,-1);
  while any(x(:))
    p = p + sign(x);
    x = bitshift(x,-1);
  end
  % Adjust for all non powers of 2
  p = p + max(0,sign(nabs - bitshift(ones(class(n)),p)));
end
