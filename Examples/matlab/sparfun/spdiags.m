function [res1,res2] = spdiags(arg1,arg2,arg3,arg4)
%SPDIAGS Sparse matrix formed from diagonals.
%   SPDIAGS, which generalizes the function "diag", deals with three
%   matrices, in various combinations, as both input and output.
%
%   [B,d] = SPDIAGS(A) extracts all nonzero diagonals from the m-by-n
%   matrix A.  B is a min(m,n)-by-p matrix whose columns are the p
%   nonzero diagonals of A.  d is a vector of length p whose integer
%   components specify the diagonals in A.
%
%   B = SPDIAGS(A,d) extracts the diagonals specified by d.
%   A = SPDIAGS(B,d,A) replaces the diagonals of A specified by d with
%       the columns of B.  The output is sparse.
%   A = SPDIAGS(B,d,m,n) creates an m-by-n sparse matrix from the
%       columns of B and places them along the diagonals specified by d.
%
%   Roughly, A, B and d are related by
%       for k = 1:p
%           B(:,k) = diag(A,d(k))
%       end
%
%   Example: These commands generate a sparse tridiagonal representation
%   of the classic second difference operator on n points.
%       e = ones(n,1);
%       A = spdiags([e -2*e e], -1:1, n, n)
%
%   Some elements of B, corresponding to positions "outside" of A, are
%   not actually used.  They are not referenced when B is an input and
%   are set to zero when B is an output.  If a column of B is longer than
%   the diagonal it's representing, elements of super-diagonals of A
%   correspond to the lower part of the column of B, while elements of
%   sub-diagonals of A correspond to the upper part of the column of B.
%
%   Example: This uses the top of the first column of B for the second
%   sub-diagonal and the bottom of the third column of B for the first
%   super-diagonal.
%       B = repmat((1:n)',1,3);
%       S = spdiags(B,[-2 0 1],n,n);
%
%   See also DIAG, SPEYE.

%   Rob Schreiber
%   Copyright 1984-2016 The MathWorks, Inc.


if nargin <= 2
    % Extract diagonals
    A = arg1;
    if nargin == 1
        % Find all nonzero diagonals
        [i,j] = find(A);
        % Compute d = unique(d) without extra function call
        d = sort(j-i);
        d = d(diff([-inf; d(:)])~=0);
        d = d(:);
    else
        % Diagonals are specified
        d = arg2(:);
    end
    [m,n] = size(A);
    p = length(d);
    B = zeros(min(m,n),p,class(A));
    for k = 1:p
        if m >= n
            i = max(1,1+d(k)):min(n,m+d(k));
        else
            i = max(1,1-d(k)):min(m,n-d(k));
        end
        B(i,k) = diagk(A,d(k));
    end
    res1 = B;
    res2 = d;
end

if nargin >= 3
    B = arg1;
    d = arg2(:);
    p = length(d);
    if nargin == 3 % Replace specified diagonals
        A = arg3;
    else           % Create new matrix with specified diagonals
        A = sparse(arg3, arg4);
    end
    [m,n] = size(A);
    
    % Check size of matrix B (should be min(m,n)-by-p)
    % For backwards compatibility, only error if the code would
    % previously have errored out in the indexing expression.
    maxIndexRows = max(max(1,1-d), min(m,n-d)) + (m>=n)*d;
    maxIndexRows(max(1,1-d) > min(m,n-d)) = 0;
    if any(maxIndexRows > size(B, 1)) || p > size(B, 2)
       if nargin == 3
           error(message('MATLAB:spdiags:InvalidSizeBThreeInput'));
       else
           error(message('MATLAB:spdiags:InvalidSizeBFourInput'));
       end
    end
    
    % Compute indices and values of sparse matrix with given diagonals
    
    % Compute lengths of diagonals:
    len = max(0, min(m, n-d) - max(1, 1-d) + 1);
    len = [0; cumsum(len)];
    
    a = zeros(len(p+1), 3);
    for k = 1:p
        % Append new d(k)-th diagonal to compact form
        i = (max(1,1-d(k)):min(m,n-d(k)))';
        a((len(k)+1):len(k+1),:) = [i i+d(k) B(i+(m>=n)*d(k),k)];
    end
    
    % Remove diagonal elements in old matrix if necessary
    if nnz(A) ~= 0
        % Process A in compact form
        [i,j,aold] = find(A);
        aold = [i(:) j(:) aold(:)]; % need (:) if A is row vector
        
        % Delete current d(k)-th diagonal, k=1,...,p
        i = any((aold(:, 2) - aold(:, 1)) == d', 2);
        aold(i, :) = [];
        
        % Combine new diagonals and non-diagonal entries of original matrix
        a = [a; aold];
    end
    
    res1 = sparse(a(:,1),a(:,2),a(:,3),m,n);
    if islogical(A) || islogical(B)
        res1 = (res1~=0);
    end
end


function D = diagk(X,k)
% DIAGK  K-th matrix diagonal.
% DIAGK(X,k) is the k-th diagonal of X, even if X is a vector.
if ~isvector(X)
    D = diag(X,k);
    D = D(:);  %Ensure column vector is returned for empty X.
else
    if ~isempty(X) && 0 <= k && 1+k <= size(X,2)
        D = X(1+k);
    elseif ~isempty(X) && k < 0 && 1-k <= size(X,1)
        D = X(1-k);
    else
        D = zeros(0,1,'like',X);
    end
end