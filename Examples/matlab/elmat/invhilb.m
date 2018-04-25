function H = invhilb(n,classname)
%INVHILB Inverse Hilbert matrix.
%   IH = INVHILB(N) is the inverse of the N-by-N matrix with elements
%   1/(i+j-1), which is a famous example of a badly conditioned matrix.
%   The result is exact for N less than or equal to 12.
%
%   IH = INVHILB(N,CLASSNAME) returns a matrix of class CLASSNAME, which
%   can be either 'single' or 'double' (the default).
%
%   Example:
%  
%   INVHILB(3) is
% 
%            9   -36    30
%          -36   192  -180
%           30  -180   180
%
%   See also HILB.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin < 2
    classname = 'double';
end
if isstring(classname) && isscalar(classname)
    classname = char(classname);
end
H = zeros(n,classname);
p = n;
for i = 1:n
    r = p*p;
    H(i,i) = r/(2*i-1);
    for j = i+1:n
        r = -((n-j+1)*r*(n+j-1))/(j-1)^2;
        H(i,j) = r/(i+j-1);
        H(j,i) = r/(i+j-1);
    end
    p = ((n-i)*p*(n+i))/(i^2);
end

