function [c, d, e] = dorr(n, theta, classname)
%DORR Dorr matrix (sparse).
%   [C,D,E] = GALLERY('DORR',N,THETA) returns the vectors defining a row
%   diagonally dominant, tridiagonal N-by-N matrix that is ill-conditioned
%   for small values of THETA >= 0. THETA defaults to 0.01.
%
%   A = GALLERY('DORR',N,THETA) returns the (sparse) Dorr matrix itself.
%   This is the same as
%       [C,D,E] = GALLERY('DORR',N,THETA);
%       A = GALLERY('TRIDIAG',C,D,E);
%
%   The columns of INV(C) vary greatly in norm.
%   The amount of diagonal dominance, ignoring rounding errors, is:
%        GALLERY('COMPAR',C)*ONES(N,1) = THETA*(N+1)^2 * [1 0 0 ... 0 1]'.

%   Reference:
%   F. W. Dorr, An example of ill-conditioning in the numerical
%   solution of singular perturbation problems, Math. Comp.,
%   25 (1971), pp. 271-283.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(theta), theta = 0.01; cast(theta,classname); end

c = zeros(n,1,classname); e = c; d = c;
% All length n for convenience.  Make c, e of length n-1 later.

h = 1/(n+1);
m = floor( (n+1)/2 );
term = theta/h^2;

i = (1:m)';
    c(i) = -term*ones(m,1,classname);
    e(i) = c(i) - (0.5-i*h)/h;
    d(i) = -(c(i) + e(i));

i = (m+1:n)';
    e(i) = -term*ones(n-m,1,classname);
    c(i) = e(i) + (0.5-i*h)/h;
    d(i) = -(c(i) + e(i));

c = c(2:n);
e = e(1:n-1);

if nargout <= 1
   c = tridiag(c, d, e, [], classname);
end
