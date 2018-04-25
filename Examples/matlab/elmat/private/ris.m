function A = ris(n,classname)
%RIS Ris matrix (symmetric Hankel).
%   A = GALLERY('RIS',N) is a symmetric N-by-N Hankel matrix with
%   elements A(i,j) = 0.5/(N-i-j+1.5).
%   The eigenvalues of A cluster around PI/2 and -PI/2.
%   This matrix was invented by F. N. Ris.

%   Reference:
%   J. C. Nash, Compact Numerical Methods for Computers: Linear Algebra
%   and Function Minimisation, second edition, Adam Hilger, Bristol,
%   1990 (Appendix 1).
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

p= -2*(1:n) + (n+1.5);
A = gallery('cauchy',p,classname);
