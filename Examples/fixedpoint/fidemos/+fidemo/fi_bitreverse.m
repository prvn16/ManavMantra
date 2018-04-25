function x = fi_bitreverse(x,n0)
%FI_BITREVERSE  Bit-reverse the input.
%   X = FI_BITREVERSE(x,n) bit-reverse the input sequence X, where N=length(X).
%
%   See also FI_RADIX2FFT_DEMO.

%   Copyright 2004-2011 The MathWorks, Inc.
%   
%#codegen
n = int32(n0);
nv2 = bitsra(n,1);
j = int32(1);
for i=1:(n-1)
  if i<j
    temp = x(j);
    x(j) = x(i);
    x(i) = temp;
  end
  k = nv2;
  while k<j
    j = j-k;
    k = bitsra(k,1);
  end
  j = j+k;
end
