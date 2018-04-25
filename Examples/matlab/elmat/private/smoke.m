function A = smoke(n, k, classname)
%SMOKE  Complex matrix with a "smoke ring" pseudospectrum.
%   GALLERY('SMOKE',N) is an N-by-N matrix with 1s on the
%   superdiagonal, 1 in the (N,1) position, and powers of roots of
%   unity along the diagonal.
%
%   GALLERY('SMOKE',N,1) is the same except for a zero (N,1) element.
%
%   The eigenvalues of GALLERY('SMOKE',N,1) are the N'th roots of
%   unity; those of GALLERY('SMOKE',N) are the N'th roots of unity
%   times 2^(1/N).

%   Reference:
%   L. Reichel and L.N. Trefethen, Eigenvalues and
%   pseudo-eigenvalues of Toeplitz matrices, Linear Algebra
%   and Appl., 162-164:153-185, 1992.
%
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(k), k = 0; end

w = cast( exp(2*pi*i/n), classname);
A = diag( [w.^(1:n-1) 1] ) + diag(ones(n-1,1,classname),1);
if k == 0, A(n,1) = 1; end
