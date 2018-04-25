%IFFT Inverse discrete Fourier transform.
%   IFFT(X) is the inverse discrete Fourier transform of X.
%
%   IFFT(X,N) is the N-point inverse transform.
%
%   IFFT(X,[],DIM) or IFFT(X,N,DIM) is the inverse discrete Fourier
%   transform of X across the dimension DIM.
%
%   IFFT(..., 'symmetric') causes IFFT to treat X as conjugate symmetric
%   along the active dimension.  This option is useful when X is not exactly
%   conjugate symmetric merely because of round-off error.  See the
%   reference page for the specific mathematical definition of this
%   symmetry.
%
%   IFFT(..., 'nonsymmetric') causes IFFT to make no assumptions about the
%   symmetry of X.
%
%   See also FFT, FFT2, FFTN, FFTSHIFT, FFTW, IFFT2, IFFTN.

%   Copyright 1984-2005 The MathWorks, Inc.

