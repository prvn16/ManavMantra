function Z = null(A,how)
%NULL   Null space.
%   Z = NULL(A) is an orthonormal basis for the null space of A obtained
%   from the singular value decomposition.  That is,  A*Z has negligible
%   elements, size(Z,2) is the nullity of A, and Z'*Z = I.
%
%   Z = NULL(A,'r') is a "rational" basis for the null space obtained
%   from the reduced row echelon form.  A*Z is zero, size(Z,2) is an
%   estimate for the nullity of A, and, if A is a small matrix with 
%   integer elements, the elements of R are ratios of small integers.  
%
%   The orthonormal basis is preferable numerically, while the rational
%   basis may be preferable pedagogically.
%
%   Example:
%
%       A =
%
%           1     2     3
%           1     2     3
%           1     2     3
%
%       Z = null(A); 
%
%       Computing the 1-norm of the matrix A*Z will be 
%       within a small tolerance
%
%       norm(A*Z,1)< 1e-12
%       ans =
%      
%          1
%
%       null(A,'r') = 
%
%          -2    -3
%           1     0
%           0     1
%
%   Class support for input A:
%      float: double, single
%
%   See also SVD, ORTH, RANK, RREF.

%   Copyright 1984-2017 The MathWorks, Inc.

[m,n] = size(A);
if nargin > 1 && (isequal(how,'r') || isequal(how,"r"))

    % Rational basis  
    [R,pivcol] = rref(A);
    r = length(pivcol);
    nopiv = 1:n;
    nopiv(pivcol) = [];
    Z = zeros(n,n-r,class(A));
    if n > r
        Z(nopiv,:) = eye(n-r,n-r,class(A));
        if r > 0
            Z(pivcol,:) = -R(1:r,nopiv);
        end
    end

else

    % Orthonormal basis 
    [~,S,V] = svd(A,0);
    if isempty(A)
        Z = V;
    else
        if m == 1
            s = S(1);
        else
            s = diag(S);  
        end
        tol = max(m,n) * eps(max(s));
        r = sum(s > tol);
        Z = V(:,r+1:n);
    end

end
