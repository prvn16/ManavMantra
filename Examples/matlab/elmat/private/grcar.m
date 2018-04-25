function G = grcar(n, k, classname)
%GRCAR  Grcar matrix.
%   GALLERY('GRCAR',N,K) is an N-by-N Toeplitz matrix with -1s on
%   the subdiagonal, 1s on the diagonal, and K superdiagonals of 1s.
%   The default is K = 3.  The eigenvalues are sensitive.

%  References:
%    [1] J. F. Grcar, Operator coefficient methods for linear equations,
%    Report SAND89-8691, Sandia National Laboratories, Albuquerque,
%    New Mexico, 1989 (Appendix 2).
%    [2] N. M. Nachtigal, L. Reichel and L. N. Trefethen, A hybrid GMRES
%    algorithm for nonsymmetric linear systems, SIAM J. Matrix Anal.
%    Appl., 13 (1992), pp. 796-825.
%
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(k), k = 3; end

G = tril(triu(ones(n,classname)), k) - diag(ones(n-1,1,classname), -1);
