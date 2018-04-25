%FFTN N-dimensional discrete Fourier Transform.
%   FFTN(X) returns the N-dimensional discrete Fourier transform
%   of the N-D array X.  If X is a vector, the output will have
%   the same orientation.
%
%   FFTN(X,SIZ) pads X so that its size vector is SIZ before
%   performing the transform.  If any element of SIZ is smaller
%   than the corresponding dimension of X, then X will be cropped
%   in that dimension.
%
%   See also FFT, FFT2, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

