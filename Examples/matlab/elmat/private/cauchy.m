function C = cauchy(x, y, classname)
%CAUCHY Cauchy matrix.
%   C = GALLERY('CAUCHY',X,Y), where X and Y are N-vectors, is the
%   N-by-N matrix with C(i,j) = 1/(X(i)+Y(j)). By default, Y = X.
%   For scalar N, GALLERY('CAUCHY',N) is the same as
%   GALLERY('CAUCHY',1:N).
%
%   Explicit formulas are known for the elements of INV(C) and DET(C).
%   DET(C) is nonzero if X and Y both have distinct elements.
%   C is totally positive if 0 < X(1) < ... < X(N) and
%                            0 < Y(1) < ... < Y(N).
%   Under these latter conditions on X, C = GALLERY('CAUCHY',X) is
%   symmetric positive definite, and C.^r is symmetric positive
%   semidefinite for all nonnegative r.

%   References:
%   [1] R. Bhatia, Infinitely divisible matrices, Amer. Math. Monthly,
%       (2005), to appear. (For the "C.^r" property.)
%   [2] D. E. Knuth, The Art of Computer Programming, Volume 1,
%       Fundamental Algorithms, third edition, Addison-Wesley, Reading,
%       Massachusetts, 1997.
%   [3] E. E. Tyrtyshnikov, Cauchy-Toeplitz matrices and some applications,
%       Linear Algebra and Appl., 149 (1991), pp. 1-18.
%   [4] O. Taussky and M. Marcus, Eigenvalues of finite matrices, in
%       Survey of Numerical Analysis, J. Todd, ed., McGraw-Hill, New York,
%       1962, pp. 279-313. (The totally positive property is on p. 295.)
%
%   Nicholas J. Higham
%   Copyright 1984-2015 The MathWorks, Inc.

n = length(x);
%  Handle scalar x.
if n == 1
   n = x;
   x = 1:n;
end

if isempty(y), y = x; end

x = x(:); y = y(:);   % Ensure x and y are column vectors.
if length(x) ~= length(y)
   error(message('MATLAB:cauchy:ParamLengthMismatch'))
end

C = cast(1,classname) ./ (x + y.');
