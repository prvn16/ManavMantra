function A = gearmat(n, i, j, classname)
%GEARMAT Gear matrix.
%   A = GALLERY('GEARMAT',N,I,J) is the N-by-N matrix with ones on
%   the sub- and super-diagonals, SIGN(I) in the (1,ABS(I)) position,
%   SIGN(J) in the (N,N+1-ABS(J)) position, and zeros everywhere else.
%   Defaults: I = N, J = -N.
%
%   Properties:
%   All eigenvalues are of the form 2*COS(a) and the eigenvectors
%     are of the form [SIN(w+a), SIN(w+2a), ..., SIN(w+Na)].
%     (The values of a and w are given in the reference below.)
%   A can have double and triple eigenvalues and can be defective.
%   GALLERY('GEARMAT',N) is singular.

%   Reference:
%   C. W. Gear, A simple set of test matrices for eigenvalue programs,
%   Math.  Comp., 23 (1969), pp. 119-125.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(j), j = -n; end
if isempty(i), i = n; end

if ~(i~=0 && abs(i)<=n && j~=0 && abs(j)<=n)
     error(message('MATLAB:gearmat:InvalidIandJ'))
end

A = diag(ones(n-1,1,classname),-1) + diag(ones(n-1,1,classname),1);
A(1, abs(i)) = sign(i);
A(n, n+1-abs(j)) = sign(j);
