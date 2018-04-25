function B = krylov(A, x, j, classname)
%KRYLOV Krylov matrix.
%   GALLERY('KRYLOV',A,X,J) is the Krylov matrix
%   [X, A*X, A^2*X, ..., A^(J-1)*X], where A is an N-by-N matrix and
%   X is an N-vector. The defaults are X = ONES(N,1), and J = N.
%
%   GALLERY('KRYLOV',N) is the same as GALLERY('KRYLOV',RANDN(N)).

%   Reference:
%   G. H. Golub and C. F. Van Loan, Matrix Computations, third edition,
%   Johns Hopkins University Press, Baltimore, Maryland, 1996, Sec. 7.4.5.
%
%   Nicholas J. Higham
%   Copyright 1984-2013 The MathWorks, Inc.

n = length(A);

if n == 1   % Handle special case A = scalar.
    n = A;
    A = randn(n,classname);
end

if isempty(j)
    j = n;
end
if isempty(x)
    x = ones(n,1,classname);
end

B = zeros(n,j,classname);
x = x(:);
for i=1:j
    B(:,i) = x;
    x = A*x;
end
