function x = fi_m_radix2fft_skip_w0(x, w)
%FI_M_RADIX2FFT_SKIP_W0  Radix-2 FFT example, skip multiplies by 1.
%   Y = FI_M_RADIX2FFT_SKIP_W0(X, W) computes the radix-2 FFT of
%   input vector X with twiddle-factors W with scaling by 1/2 at each
%   stage, and multiplication by the twiddle factor W^0 = exp(2*pi*0) =
%   1 is skipped.
%
%   The length of vector X must be an exact power of two.
%   Twiddle-factors W are computed via
%      W = fidemo.fi_radix2twiddles(N)
%   where N = length(X).
%
%   See also FI_RADIX2FFT_DEMO.

%   Reference:
%     Charles Van Loan, Computational Frameworks for the Fast Fourier
%     Transform, SIAM, Philadelphia, 1992, Algorithm 1.6.2, p. 45.
% 
%   Thomas A. Bryan
%   Copyright 2004-2011 The MathWorks, Inc.
%     
n = length(x);  t = log2(n);
x = fidemo.fi_bitreverse(x,n);
for q=1:t
  L = 2^q; r = n/L; L2 = L/2;
  for k=0:(r-1)
     % Skip multiply by w^0=1
    temp        = x(k*L+L2+1);
    x(k*L+L2+1) = bitsra(x(k*L+1) - temp, 1);
    x(k*L+1)    = bitsra(x(k*L+1) + temp, 1);
    for j=1:(L2-1)
      temp          = w(L2-1+j+1) * x(k*L+j+L2+1);
      x(k*L+j+L2+1) = bitsra(x(k*L+j+1) - temp, 1);
      x(k*L+j+1)    = bitsra(x(k*L+j+1) + temp, 1);
    end
  end
end




