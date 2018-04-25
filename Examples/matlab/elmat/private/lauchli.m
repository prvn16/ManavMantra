function A = lauchli(n, mu, classname)
%LAUCHLI Lauchli matrix.
%   GALLERY('LAUCHLI',N, MU) is the (N+1)-by-N matrix
%   [ONES(1,N); MU*EYE(N)]. It is a well-known example in
%   least squares and other problems that indicates the dangers of
%   forming A'*A. MU defaults to SQRT(EPS).

%   Reference:
%   P. Lauchli, Jordan-Elimination und Ausgleichung nach
%   kleinsten Quadraten, Numer. Math, 3 (1961), pp. 226-240.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(mu), mu = sqrt(eps(classname)); end
A = [ones(1,n,classname);
     mu*eye(n,classname)];
