function A = kms(n, rho, classname)
%KMS Kac-Murdock-Szego Toeplitz matrix.
%  A = GALLERY('KMS', N, RHO) is the N-by-N Kac-Murdock-Szego
%  Toeplitz matrix such that
%     A(i,j) = RHO^(ABS(i-j)), for real RHO.
%  For complex RHO, the same formula holds except that elements
%  below the diagonal are conjugated. RHO defaults to 0.5.
%
%  Properties:
%    A has an LDL' factorization with
%      L = INV(GALLERY('TRIW',N,-RHO,1))', and
%      D(i,i) = (1-ABS(RHO)^2)*EYE(N),
%    except D(1,1) = 1.
%    A is positive definite if and only if 0 < ABS(RHO) < 1.
%    INV(A) is tridiagonal.

%   Reference:
%   W. F. Trench, Numerical solution of the eigenvalue problem
%   for Hermitian Toeplitz matrices, SIAM J. Matrix Analysis
%   and Appl., 10 (1989), pp. 135-146.
%
%   Nicholas J. Higham
%   Copyright 1984-2015 The MathWorks, Inc.

if isempty(rho)
   rho = 0.5; 
end

a = (1:cast(n,classname));

A = abs(a.' - a);
A = rho .^ A;
if imag(rho)
   A = conj(tril(A,-1)) + triu(A);
end
