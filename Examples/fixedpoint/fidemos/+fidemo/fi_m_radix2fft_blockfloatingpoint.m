function [x,nshifts] = fi_m_radix2fft_blockfloatingpoint(x, w)
%FI_M_RADIX2FFT_BLOCKFLOATINGPOINT  Radix-2 FFT example with block floating-point.
%   Y = FI_M_RADIX2FFT_BLOCKFLOATINGPOINT(X, W) computes the radix-2 FFT of
%   input vector X with twiddle-factors W with block floating-point.
%
%   The length of vector X must be an exact power of two.
%   Twiddle-factors W are computed via
%      W =fidemo.fi_radix2twiddles(N)
%   where N = length(X).
%
%   See also FI_RADIX2FFT_DEMO

%   References:
%
%     Algorithm:
%     Charles Van Loan, Computational Frameworks for the Fast Fourier
%     Transform, SIAM, Philadelphia, 1992, Algorithm 1.6.2, p. 45.
%
%     Scaling:
%     Alan V. Oppenheim and Ronald W. Schafer, Discrete-Time Signal
%     Processing, Prentice Hall, 1989, ISBN 0-13-216292-X, p. 637.  
%     (Or 2nd edition, 1999, p. 667.)
% 
%   Copyright 2004-2011 The MathWorks, Inc.
%     

% In block floating-point, you have to keep an entire stage around in
% extended precision.

n = length(x);  t = log2(n);
x = bitreverse(x,n);
nshifts = 0;
if isfloat(x)
  upperbnd = realmax(class(x));
  lowerbnd = -upperbnd;
  y = x;
else
  [lowerbnd, upperbnd] = range(x);
  y = fi(x, true, 2*x.WordLength, x.FractionLength, 'fimath',x.fimath);
end

for q=1:t
  L = 2^q; r = n/L; L2 = L/2;
  for k=0:(r-1)
    for j=0:(L2-1)
      temp          = w(L2-1+j+1) * y(k*L+j+L2+1);
      y(k*L+j+L2+1) = y(k*L+j+1)  - temp;
      y(k*L+j+1)    = y(k*L+j+1)  + temp;
    end
  end
  if any(real(y)<lowerbnd) || any(real(y)>upperbnd) || ...
     any(imag(y)<lowerbnd) || any(imag(y)>upperbnd)
    y = bitsra(y,1);
    nshifts = nshifts+1;
  end
end
% Overwrite original data
x(:) = y;


function x = bitreverse(x,n) 
% Increment the bit reversed counter and sort the input sequence.
nv2 = n/2;
j=1;
for i=1:(n-1)
  if i<j
    temp = x(j);
    x(j) = x(i);
    x(i) = temp;
  end
  k = nv2;
  while k<j 
    j = j-k;
    k = k/2;
  end
  j = j+k;
end
