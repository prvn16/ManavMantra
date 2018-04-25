function Y = polyvalm(p,X)
%POLYVALM Evaluate polynomial with matrix argument.
%   Y = POLYVALM(P,X), when P is a vector of length N+1 whose elements
%   are the coefficients of a polynomial, is the value of the
%   polynomial evaluated with matrix argument X.  X must be a 
%   square matrix. 
%
%       Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)*I
%
%   Class support for inputs p, X:
%      float: double, single
%
%   See also POLYVAL, POLYFIT.

%   Copyright 1984-2007 The MathWorks, Inc.

% Polynomial evaluation p(x) using Horner's method.

% Check input is a vector
if ~(isvector(p) || isempty(p))
    error(message('MATLAB:polyvalm:InvalidP'));
end

np = length(p);
[m,n] = size(X);
if m ~= n
    error(message('MATLAB:polyvalm:NonSquareMatrix'))
end

if np == 1    %Quick return if possible.
    Y = diag(p(1) * ones(m,1,superiorfloat(p,X))); 
    return
end    

Y = zeros(m,superiorfloat(p,X));
for i = 1:np
    Y = X * Y + diag(p(i) * ones(m,1));
end
