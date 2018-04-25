function T = tridiag(n, x, y, z, classname)
%TRIDIAG Tridiagonal matrix (sparse).
%   GALLERY('TRIDIAG',X,Y,Z) is the (sparse) tridiagonal matrix with
%   subdiagonal X, diagonal Y, and superdiagonal Z.
%   X and Z are vectors of dimension one less than Y.
%
%   GALLERY('TRIDIAG',N,C,D,E), where C, D, and E are all scalars,
%   yields the Toeplitz tridiagonal matrix of order N with subdiagonal
%   elements C, diagonal elements D, and superdiagonal elements E. This
%   matrix has eigenvalues: D + 2*SQRT(C*E)*COS(k*PI/(N+1)), k=1:N.
%
%   GALLERY('TRIDIAG',N) is the same as GALLERY('TRIDIAG',N,-1,2,-1),
%   which is a symmetric positive definite M-matrix (the negative of the
%   second difference matrix).

%   References:
%   [1] J. Todd, Basic Numerical Mathematics, Vol 2: Numerical Algebra,
%       Birkhauser, Basel, and Academic Press, New York, 1977, p. 155.
%   [2] D. E. Rutherford, Some continuant determinants arising in
%       physics and chemistry---II, Proc. Royal Soc. Edin., 63,
%       A (1952), pp. 232-241.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(x), x = -1; y = 2; z = -1; end
if isempty(z), z = y; y = x; x = n; end

x = x(:); y = y(:); z = z(:);   % Force column vectors.

if max( [ size(x) size(y) size(z) ] ) == 1
   x = x*ones(n-1,1,classname);
   z = z*ones(n-1,1,classname);
   y = y*ones(n,1,classname);
else
   nx = size(x,1);
   ny = size(y,1);
   nz = size(z,1);
   if (ny - nx - 1) || (ny - nz -1)
      error(message('MATLAB:tridiag:InvalidVectorArgDim'))
   end
end

% T = diag(x, -1) + diag(y) + diag(z, 1);  % For non-sparse matrix.
n = length(y);
T = spdiags([ [x;0] y [0;z] ], -1:1, n, n);
