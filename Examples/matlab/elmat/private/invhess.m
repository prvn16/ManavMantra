function A = invhess(x, y, classname)
%INVHESS Inverse of an upper Hessenberg matrix.
%   GALLERY('INVHESS',X,Y), where X is an N-vector and Y an
%   N-1 vector, is the matrix whose lower triangle agrees with
%   that of ONES(N,1)*X' and whose strict upper triangle agrees
%   with that of [1 Y]*ONES(1,N).
%
%   The matrix is nonsingular if X(1) ~= 0 and X(i+1) ~= Y(i)
%   for all i, and its inverse is an upper Hessenberg matrix.
%   Y defaults to -X(1:N-1).
%
%   If N is a scalar, GALLERY('INVHESS',N) is the same
%   as GALLERY('INVHESS',1:N).

%   References:
%   [1] F. N. Valvi and V. S. Geroyannis, Analytic inverses and
%       determinants for a class of matrices, IMA Journal of Numerical
%       Analysis, 7 (1987), pp. 123-128.
%   [2] W.-L. Cao and W. J. Stewart, A note on inverses of
%       Hessenberg-like matrices, Linear Algebra and Appl., 76 (1986),
%       pp. 233-240.
%   [3] Y. Ikebe, On inverses of Hessenberg matrices, Linear Algebra
%       and Appl., 24 (1979), pp. 93-97.
%   [4] P. Rozsa, On the inverse of band matrices, Integral Equations
%       and Operator Theory, 10 (1987), pp. 82-95.
%
%   Copyright 1984-2005 The MathWorks, Inc.

n = length(x);
%  Handle scalar x.
if n == 1
   n = x;
   x = cast(1:n,classname);
end
x = x(:);

if isempty(y), y = -x; end
y = y(:);

A = x(:,ones(1,n))';
for j=2:n
    A(1:j-1,j) = y(1:j-1);
end
