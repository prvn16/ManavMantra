function C = chebvand(m, p, classname)
%CHEBVAND Vandermonde-like matrix for the Chebyshev polynomials.
%   C = GALLERY('CHEBVAND',P), where P is a vector, produces the
%   (primal) Chebyshev Vandermonde matrix based on the points P:
%      C(i,j) = T_{i-1}(P(j)), where T_{i-1} is the Chebyshev
%      polynomial of degree i-1.
%   GALLERY('CHEBVAND',M,P) is a rectangular version of
%   GALLERY('CHEBVAND',P) with M rows.
%   Special case: If P is a scalar, then P equally spaced points on
%      [0,1] are used.

%   Reference:
%   N. J. Higham, Stability analysis of algorithms for solving confluent
%   Vandermonde-like systems, SIAM J. Matrix Anal. Appl., 11 (1990),
%   pp. 23-41.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(p), p = m; square = 1; else square = 0; end
n = length(p);

%  Handle scalar p.
if n == 1
   n = p;
   p = linspace(zeros(classname),1,n);
end

if square == 1, m = n; end

p = p(:).';                    % Ensure p is a row vector.
C = ones(m,n,classname);
if m == 1, return, end
C(2,:) = p;
%      Use Chebyshev polynomial recurrence.
for i=3:m
    C(i,:) = 2.*p.*C(i-1,:) - C(i-2,:);
end
