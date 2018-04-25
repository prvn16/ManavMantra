function [U,T] = rsf2csf(U,T)
%RSF2CSF Real block diagonal form to complex diagonal form.
%   [U,T] = RSF2CSF(U,T) transforms the outputs of SCHUR(X) (where X
%   is real) from Real Schur Form to Complex Schur Form.  The Real
%   Schur Form has the real eigenvalues on the diagonal and the
%   complex eigenvalues in 2-by-2 blocks on the diagonal.  The Complex
%   Schur Form is upper triangular with the eigenvalues of X on the
%   diagonal.
%   
%   Arguments U and T represent the unitary and Schur forms of a 
%   matrix A, such that A = U*T*U' and U'*U = eye(size(A)).
%
%   Class support for inputs U,T:
%      float: double, single
%
%   See also SCHUR.

%   Copyright 1984-2007 The MathWorks, Inc. 

% Find complex unitary similarities to zero subdiagonal elements.
n = size(T,2);
for m = n:-1:2
   % We are honouring the deflation from SCHUR. It may not work correctly if
   % the input is not an output of SCHUR.
   if T(m,m-1) ~= 0
      k = m-1:m;
      mu = eig(T(k,k)) - T(m,m);
      r = hypot(mu(1), T(m,m-1));
      c = mu(1)/r;  s = T(m,m-1)/r;
      G = [c' s; -s c];
      T(k,m-1:n) = G*T(k,m-1:n);
      T(1:m,k) = T(1:m,k)*G';
      U(:,k) = U(:,k)*G';
      T(m,m-1) = 0;
   end
end
