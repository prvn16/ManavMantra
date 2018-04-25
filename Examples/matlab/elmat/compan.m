function A = compan(c)
%COMPAN Companion matrix.
%   COMPAN(P) is a companion matrix of the polynomial with coefficients P.
%
%   Class support for input P:
%      float: double, single

%   Copyright 1984-2014 The MathWorks, Inc. 

if ~isvector(c)
    error(message('MATLAB:compan:NeedVectorInput'))
end
n = length(c);
A = zeros(n-1, 'like', full(c([])));
if n > 1
    A(1,:) = -c(2:end)./c(1);
    A(2:n:end) = 1;
end
