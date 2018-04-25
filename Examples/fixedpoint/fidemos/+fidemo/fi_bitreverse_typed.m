function x = fi_bitreverse_typed(x,n0,T)
%FI_BITREVERSE_TYPED  Bit-reverse the input.
%   X = FI_BITREVERSE_TYPED(x,n,T) bit-reverse the input sequence X, where
%   N=length(X).
%
%   T is a types table to cast variables to a particular type, while keeping
%   the body of the algorithm unchanged.
%
%   See also FI_RADIX2FFT_DEMO.

%   Copyright 2004-2015 The MathWorks, Inc.
%
%#codegen
n = cast(n0,'like',T.n);
nv2 = bitsra(n,1);
j = cast(1,'like',T.n);
for i=1:(n-1)
  if i<j
    temp = x(j);
    x(j) = x(i);
    x(i) = temp;
  end
  k = nv2;
  while k<j
    j(:) = j-k;
    k = bitsra(k,1);
  end
  j(:) = j+k;
end
