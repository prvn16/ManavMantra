function A = randjorth(p,q,c,symm,method,classname)
%RANDJORTH  Random J-orthogonal matrix.
%   A = GALLERY('RANDJORTH',N) produces a random N-by-N J-orthogonal
%   matrix A, where J = BLKDIAG(EYE(CEIL(N/2)),-EYE(FLOOR(N/2))) and
%   COND(A) is SQRT(1/EPS).
%   J-orthogonality means that A'*J*A = J, and such matrices are sometimes
%   called hyperbolic or pseudo-orthogonal.
%
%   A = GALLERY('RANDJORTH',P,Q), where P > 0 and Q > 0 produces a random
%   (P+Q)-by-(P+Q) J-orthogonal matrix A, where J = BLKDIAG(EYE(P),-EYE(Q))
%   and COND(A) is SQRT(1/EPS).
%
%   A = GALLERY('RANDJORTH',P,Q,C) specifies COND(A) as C.
%
%   A = GALLERY('RANDJORTH',P,Q,C,SYMM) enforces symmetry if SYMM is
%   nonzero. A symmetric positive definite matrix is produced.
%
%   A = GALLERY('RANDJORTH',P,Q,C,SYMM,METHOD) calls QR to perform the
%   underlying orthogonal transformations if METHOD is nonzero. A call to
%   QR is used, which is much faster than the default method for large
%   dimensions.

%   Reference:
%   N. J. Higham, J-orthogonal matrices: Properties and generation,
%   SIAM Rev., 45(3) (2003), pp. 504-519.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(q), q = floor(p/2); p = p-q; end
if isempty(c), c = sqrt(1/eps(classname)); end
if isempty(symm), symm = 0; end
if isempty(method), method = 0; end

if p == 0 || q == 0
  error(message('MATLAB:randjorth:PorQNotPos'))
end

% This function requires q >= p, so...
if p > q
   % diag(eye(q),-eye(p))-orthogonal matrix.
   A = randjorth(q,p,c,symm,method,classname);
   A = A( [q+1:p+q 1:q], :); % Permute to produce J-orthogonal matrix.
   A = A(:, [q+1:p+q 1:q]);
   return
end

if c >= 1
   c(1) = (1+c)/(2*sqrt(c));
   c(2:p) = 1 + (c(1)-1)*rand(p-1,1);
elseif p ~= 1
   error(message('MATLAB:randjorth:InvalidC'))
end

s = sqrt(c.^2-1);

A = blkdiag([diag(c) -diag(s); -diag(s) diag(c)], eye(q-p,classname));

if symm
   U = blkdiag( qmult(p,method,classname), qmult(q,method,classname) );
   A = U*A*U';
   A = (A + A')/2;       % Ensure matrix is symmetric.
   return
end

A = left_mult(A);  % Left multiplications by orthogonal matrices.
A = left_mult(A'); % Right multiplications by orthogonal matrices.

   function A = left_mult(A)
   %LEFT_MULT   Left multiplications by random orthogonal matrices.
   A(1:p,:) = qmult(A(1:p,:), method, classname);
   A(p+1:p+q,:) = qmult(A(p+1:p+q,:), method, classname);
   end

end
