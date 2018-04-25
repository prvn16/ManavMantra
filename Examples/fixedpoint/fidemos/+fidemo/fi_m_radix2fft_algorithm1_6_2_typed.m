function x = fi_m_radix2fft_algorithm1_6_2_typed(x, w, T)
%FI_M_RADIX2FFT_ORIGINAL_TYPED Radix-2 FFT example.
%   Y = FI_M_RADIX2FFT_ALGORITHM1_6_2_TYPED(X, W, T) computes the radix-2
%   FFT of input vector X with twiddle-factors W.  Input X is assumed to be
%   complex.
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
%   See also FI_RADIX2FFT_DEMO, FI_M_RADIX2FFT_WITHSCALING.
%
%   Reference:
%     Charles Van Loan, Computational Frameworks for the Fast Fourier
%     Transform, SIAM, Philadelphia, 1992, Algorithm 1.6.2, p. 45.
%
%   Copyright 2015 The MathWorks, Inc.
%
%#codegen

    n = length(x);
    t = log2(n);
    x = fidemo.fi_bitreverse_typed(x,n,T);
    LL = cast(2.^(1:t),'like',T.n);
    rr = cast(n./LL,'like',T.n);
    LL2 = cast(LL./2,'like',T.n);
    for q=1:t
        L = LL(q);
        r = rr(q);
        L2 = LL2(q);
        for k=0:(r-1)
            for j=0:(L2-1)
                temp          = w(L2-1+j+1) * x(k*L+j+L2+1);
                x(k*L+j+L2+1) = x(k*L+j+1)  - temp;
                x(k*L+j+1)    = x(k*L+j+1)  + temp;
            end
        end
    end
end
