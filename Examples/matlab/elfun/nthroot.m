function y = nthroot(x, n)
%NTHROOT Real n-th root of real numbers.
%
%   NTHROOT(X, N) returns the real Nth root of the elements of X.
%   Both X and N must be real, and if X is negative, N must be an odd integer.
%
%   Class support for inputs X, N:
%      float: double, single
%
%   See also POWER.

%   Thanks to Peter J. Acklam
%   Copyright 1984-2016 The MathWorks, Inc.

if ~isreal(x) || ~isreal(n)
   error(message('MATLAB:nthroot:ComplexInput'));
end

if ~isscalar(x) && ~isscalar(n) && ~isequal(size(x),size(n))
   error(message('MATLAB:nthroot:NonmatchDim'));
end

if isscalar(x) && ~isscalar(n)
    x = repmat(x,size(n));
end

if any((x(:) < 0) & (n(:) ~= fix(n(:)) | rem(n(:),2)==0))
   error(message('MATLAB:nthroot:NegXNotOddIntegerN'));
end

y = (sign(x) + (x==0)) .* (abs(x).^(1./n));

% Correct numerical errors (since, e.g., 64^(1/3) is not exactly 4)
% by one iteration of Newton's method
m = x ~= 0 & (abs(x) < (1/eps(class(y)))) & isfinite(n); 
if isscalar(n)
    y(m) = y(m) - (y(m).^n - x(m)) ./ (n .* y(m).^(n-1));
else
    y(m) = y(m) - (y(m).^n(m) - x(m)) ./ (n(m) .* y(m).^(n(m)-1));
end

