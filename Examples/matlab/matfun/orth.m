function Q = orth(A)
%ORTH   Orthogonalization.
%   Q = ORTH(A) is an orthonormal basis for the range of A.
%   That is, Q'*Q = I, the columns of Q span the same space as 
%   the columns of A, and the number of columns of Q is the 
%   rank of A.
%
%   Class support for input A:
%      float: double, single
%
%   See also SVD, RANK, NULL.

%   Copyright 1984-2015 The MathWorks, Inc. 

[Q,S] = svd(A,'econ'); %S is always square.
s = diag(S);
tol = max(size(A)) * eps(max(s));
r = sum(s > tol);
Q(:, r+1:end) = [];

