function H = randhess(x,classname)
%RANDHESS Random, orthogonal upper Hessenberg matrix.
%   H = GALLERY('RANDHESS',N) returns an N-by-N real, random,
%   orthogonal upper Hessenberg matrix.
%
%   H = GALLERY('RANDHESS',X), where X is an arbitrary real N-element
%   vector (N > 1), constructs H non-randomly using the elements of X
%   as parameters.
%
%   In both cases, H is constructed via a product of N-1 Givens rotations.

%   Note:
%   See [1] for representing an N-by-N (complex) unitary Hessenberg
%   matrix with positive subdiagonal elements in terms of 2N-1 real
%   parameters (the Schur parametrization). This implementation handles
%   the real case only and is intended simply as a convenient way to
%   generate random or non-random orthogonal Hessenberg matrices.
%
%   Reference:
%   [1] W. B. Gragg, The QR algorithm for unitary Hessenberg matrices,
%       J. Comp. Appl. Math., 16 (1986), pp. 1-8.
%
%   Nicholas J. Higham
%   Copyright 1984-2010 The MathWorks, Inc.

if ~isreal(x)
  error(message('MATLAB:randhess:ComplexParam'))
end

n = length(x);

if n == 1
%  Handle scalar x.
   n = x;
   x = cast(rand(n-1,1)*2*pi,classname);
   H = eye(n,classname);
   H(n,n) = mysign(randn);
else
   H = eye(n,classname);
   H(n,n) = mysign(x(n));
end

for i=n:-1:2
    % Apply Givens rotation through angle x(i-1).
    theta = x(i-1);
    c = cos(theta);
    s = sin(theta);
    H([i-1 i],:) = [c s; -s c] * H([i-1 i],:);
end
