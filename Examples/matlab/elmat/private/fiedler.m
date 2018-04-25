function A = fiedler(c,classname)
%FIEDLER Fiedler matrix.
%   A = GALLERY('FIEDLER',C), where C is an N-vector, is the N-by-N
%   symmetric matrix with elements ABS(C(i)-C(j)).
%   For scalar N, GALLERY('FIEDLER',N) is the same as
%   GALLERY('FIEDLER',1:N).
%
%   A has a dominant positive eigenvalue and all the other eigenvalues
%   are negative. (Szego 1936)
%
%   Note: Explicit formulas for INV(A) and DET(A) are given in (Todd 1977)
%   and attributed to Fiedler. These indicate that INV(A) is
%   tridiagonal except for nonzero (1,n) and (n,1) elements.

%   References:
%   [1] G. Szego, Solution to problem 3705, Amer. Math. Monthly,
%     43 (1936), pp. 246-259.
%   [2] J. Todd, Basic Numerical Mathematics, Vol. 2: Numerical Algebra,
%     Birkhauser, Basel, and Academic Press, New York, 1977, p. 159.
%
%   Copyright 1984-2015 The MathWorks, Inc.

n = length(c);

%  Handle scalar c.
if n == 1
   n = c;
   c = 1:cast(n,classname);
end

c = c(:);                    % Ensure c is a column vector.
A = abs(c.' - c);
