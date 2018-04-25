function P = toeppen(n, a, b, c, d, e, classname)
%TOEPPEN Pentadiagonal Toeplitz matrix (sparse).
%   P = GALLERY('TOEPPEN',N,A,B,C,D,E) takes integer N and
%   scalar A,B,C,D,E. P is the N-by-N sparse pentadiagonal Toeplitz
%   matrix with the diagonals: P(3,1)=A, P(2,1)=B, P(1,1)=C, P(1,2)=D,
%   P(1,3)=E.
%
%   Default: (A,B,C,D,E) = (1,-10,0,10,1) (a matrix of Rutishauser).
%   This matrix has eigenvalues lying approximately on the line segment
%   2*cos(2*t) + 20*i*sin(t).

%   The pseudospectra of the following matrices are interesting:
%   GALLERY('TOEPPEN',32,0,1,0,0,1/4)  - `triangle'
%   GALLERY('TOEPPEN',32,0,1/2,0,0,1)  - `propeller'
%   GALLERY('TOEPPEN',32,0,1/2,1,1,1)  - `fish'
%
%   References:
%   [1] R. M. Beam and R. F. Warming, The asymptotic spectra of banded
%   Toeplitz and quasi-Toeplitz matrices, SIAM J. Sci. Comput. 14 (4),
%   1993, pp. 971-1006.
%   [2] H. Rutishauser, On test matrices, Programmation en Mathematiques
%   Numeriques, Editions Centre Nat. Recherche Sci., Paris, 165, 1966,
%   pp. 349-365.
%
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(a), a = 1;   end
if isempty(b), b = -10; end
if isempty(c), c = 0;   end
if isempty(d), d = 10;  end
if isempty(e), e = 1;   end

one = ones(n,1,classname);
P = spdiags([ a*one b*one c*one d*one e*one ], -2:2, n, n);
