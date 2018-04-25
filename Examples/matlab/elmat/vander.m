function A = vander(v)
%VANDER Vandermonde matrix.
%   A = vander(V), for a vector of length n, returns the n-by-n
%   Vandermonde matrix A. The columns of A are powers of the vector V,
%   such that the j-th column is A(:,j) = V(:).^(n-j).
%
%   Class support for input V:
%      float: double, single

%   Copyright 1984-2016 The MathWorks, Inc.

v = v(:);
n = length(v);
if n == 0
    A = reshape(v, n, n);
else
    A = repmat(v, 1, n);
    A(:, n) = 1;
    A = cumprod(A, 2, 'reverse');
end
