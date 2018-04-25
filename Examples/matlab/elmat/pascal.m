function P = pascal(n,k,classname)
%PASCAL Pascal matrix.
%   P = PASCAL(N) is the Pascal matrix of order N. P a symmetric positive
%   definite matrix with integer entries, made up from Pascal's triangle.
%   Its inverse has integer entries. PASCAL(N).^r is symmetric positive
%   semidefinite for all nonnegative r.
%
%   P = PASCAL(N,1) is the lower triangular Cholesky factor (up to signs of
%   columns) of the Pascal matrix. P is involutory, that is, it is its own
%   inverse.
%
%   P = PASCAL(N,2) is a rotated version of PASCAL(N,1), with sign flipped
%   if N is even. P is a cube root of the identity matrix.
%
%   P = PASCAL(...,CLASSNAME) returns a matrix of class CLASSNAME, which
%   can be either 'single' or 'double' (the default).
%
%   Example:
%
%   PASCAL(4) is
%
%          1     1     1     1
%          1     2     3     4
%          1     3     6    10
%          1     4    10    20

%   Reference:
%   N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%   Second edition, Society for Industrial and Applied Mathematics,
%   Philadelphia, 2002, Sec. 28.4.
%
%   Nicholas J. Higham
%   Copyright 1984-2017 The MathWorks, Inc.

if nargin == 2 && (ischar(k) || (isstring(k) && isscalar(k)))
    classname = k;
    k = 0;
elseif nargin < 3
    classname = 'double';
end
if isstring(classname) && isscalar(classname)
    classname = char(classname);
end
if nargin < 2 || isempty(k)
    k = 0;
end

P = diag((-1).^(0:cast(n,classname)-1));
P(:,1) = ones(n,1,classname);

% Generate PASCAL(N,1): the Pascal Cholesky factor (up to signs).
for j=2:n-1
    for i=j+1:n
        P(i,j) = P(i-1,j) - P(i-1,j-1);
    end
end

if k == 0
    P = P*P';
elseif k == 2
    P = rot90(P,3);
    if rem(n,2) == 0
        P = -P;
    end
elseif k ~= 1
    error(message('MATLAB:pascal:InvalidArg2'))
end
