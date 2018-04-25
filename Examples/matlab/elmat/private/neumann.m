function [A, T] = neumann(n,classname)
%NEUMANN Singular matrix from the discrete Neumann problem (sparse).
%   C = GALLERY('NEUMANN',N) takes N = M^2, a perfect square or a
%   two-element vector N and returns C, a singular, row
%   diagonally dominant matrix resulting from discretizing the
%   Neumann problem with the usual five point operator on a regular
%   mesh. C is sparse and has a one-dimensional null space with
%   null vector ONES(N,1).

%   Reference:
%   R. J. Plemmons, Regular splittings and the discrete Neumann problem,
%   Numer. Math., 25 (1976), pp. 153-161.
%
%   Nicholas J. Higham
%   Copyright 1984-2009 The MathWorks, Inc.

if length(n) == 1
   m = sqrt(n);
   if round(m) ~= m
     error(message('MATLAB:newmann:NNotPerfectSquare'))
   end
   n(1) = m; n(2) = m;
end

T = tridiag(n(1), -1, 2, -1, classname);
T(1,2) = -2;
T(n(1),n(1)-1) = -2;

A = kron(T, speye(n(2))) + kron(speye(n(2)), T);
