function x = fi_m_radix2fft_withscaling_typed(x, w, T)
%FI_M_RADIX2FFT_WITHSCALING  Radix-2 FFT example with scaling at each stage.
%   Y = FI_M_RADIX2FFT_WITHSCALING_TYPED(X, W, T) computes the radix-2 FFT of
%   input vector X with twiddle-factors W with scaling by 1/2 at each stage.
%   Input X is assumed to be complex.
%
%   The length of vector X must be an exact power of two.
%   Twiddle-factors W are computed via
%      W = fidemo.fi_radix2twiddles(N)
%   where N = length(X).
%
%   T is a types table to cast variables to a particular type, while keeping
%   the body of the algorithm unchanged.
%
%   This version of the algorithm has no scaling before the stages.
%
%   See also FI_RADIX2FFT_DEMO.

%   Reference:
%     Charles Van Loan, Computational Frameworks for the Fast Fourier
%     Transform, SIAM, Philadelphia, 1992, Algorithm 1.6.2, p. 45.
%
%   Copyright 2004-2015 The MathWorks, Inc.
%
%#codegen

    n = length(x);  t = log2(n);
    x = fidemo.fi_bitreverse(x,n);

    % Generate index variables as integer constants so they are not computed in
    % the loop.
    LL = cast(2.^(1:t),'like',T.n);
    rr = cast(n./LL,'like',T.n);
    LL2 = cast(LL./2,'like',T.n);
    for q=1:t
        L = LL(q); r = rr(q); L2 = LL2(q);
        for k=0:(r-1)
            for j=0:(L2-1)
                temp          = w(L2-1+j+1) * x(k*L+j+L2+1);
                x(k*L+j+L2+1) = bitsra(x(k*L+j+1) - temp, 1);
                x(k*L+j+1)    = bitsra(x(k*L+j+1) + temp, 1);
            end
        end
    end
end
