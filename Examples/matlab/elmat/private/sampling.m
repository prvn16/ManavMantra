function A = sampling(x,classname)
%SAMPLING   Nonsymmetric matrix with integer, ill conditioned eigenvalues.
%   A = SAMPLING(X), where X is an N-vector, is the N-by-N matrix with
%   A(i,j) = X(i)/(X(i)-X(j)) for i ~= j and
%   A(j,j) the sum of the off-diagonal elements in column j.
%   A has eigenvalues 0:N-1.  For the eigenvalues 0 and N-1
%   corresponding eigenvectors are X and ONES(N,1), respectively.
%   The eigenvalues are ill conditioned.
%   A has the property that A(i,j) + A(j,i) = 1 for i ~= j.
%   Explicit formulas are available for the left eigenvectors of A.
%   For scalar N, SAMPLING(N) is the same as SAMPLING(1:N).
%   A special case of this matrix arises in sampling theory.

%   Reference:
%   L. Bondesson and I. Traat, A Nonsymmetric Matrix with Integer
%   Eigenvalues, Linear and Multilinear Algebra, 55(3)(2007), pp. 239-247.
%
%   Copyright 1984-2017 The MathWorks, Inc.
%

n = length(x);

%  Handle scalar x.
if n == 1
   n = x;
   x = 1:cast(n,classname);
end

x = x(:);                    % Ensure x is a column vector.
A = x ./ (x - x.');
A(1:n+1:n^2) = 0;
A = A + diag(sum(A));
