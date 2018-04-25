function C = chebspec(n, k, classname)
%CHEBSPEC Chebyshev spectral differentiation matrix.
%   C = GALLERY('CHEBSPEC',N,K) is a Chebyshev spectral
%      differentiation matrix of order N.
%   For K = 0 ("no boundary conditions", the default), C is nilpotent,
%      with C^N = 0 and it has the null vector ONES(N,1).
%      C is similar to a Jordan block of size N with eigenvalue zero.
%   For K = 1, C is nonsingular and well conditioned, and its
%      eigenvalues have negative real parts.
%   For both K, the computed eigenvector matrix X from EIG is
%      ill-conditioned (MESH(REAL(X)) is interesting).

%   References:
%   [1] C. Canuto, M. Y. Hussaini, A. Quarteroni and T. A. Zang,
%       Spectral Methods in Fluid Dynamics, Springer-Verlag, Berlin,
%       1988, p. 69.
%   [2] L. N. Trefethen and M. R. Trummer, An instability phenomenon in
%       spectral methods, SIAM J. Numer. Anal., 24 (1987), pp. 1008-1023.
%   [3] D. Funaro, Computing the inverse of the Chebyshev collocation
%       derivative, SIAM J. Sci. Stat. Comput., 9 (1988), pp. 1050-1057.
%
%   Nicholas J. Higham
%   Copyright 1984-2015 The MathWorks, Inc.

if isempty(k)
    k = 0; 
end

% k = 1 case obtained from k = 0 case with one bigger n.
if k == 1
    n = n + 1; 
end

n = n-1;
C = zeros(n+1,classname);

x = cos( (0:n)' * (pi/n) );
d = ones(n+1,1,classname); d(1) = 2; d(n+1) = 2;

% eye(size(C)) on next line avoids div by zero.
C = (d * (ones(n+1,1,classname)./d)') ./ ...
    (x - x' + eye(size(C),classname));

%  Now fix diagonal and signs.
C(1,1) = (2*n^2+1)/6;
for i=2:n+1
    if rem(i,2) == 0
       C(:,i) = -C(:,i);
       C(i,:) = -C(i,:);
    end
    if i < n+1
       C(i,i) = -x(i)/(2*(1-x(i)^2));
    else
       C(n+1,n+1) = -C(1,1);
    end
end

if k == 1
   C = C(2:n+1,2:n+1);
end
