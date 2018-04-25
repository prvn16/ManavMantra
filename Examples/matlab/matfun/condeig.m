function [X, D, s] = condeig(A)
%CONDEIG Condition number with respect to eigenvalues.
%   CONDEIG(A) is a vector of condition numbers for the eigenvalues
%   of A. These condition numbers are the reciprocals of the cosines 
%   of the angles between the left and right eigenvectors.
%       [V,D,s] = CONDEIG(A) is equivalent to:
%       [V,D] = EIG(A); s = CONDEIG(A);
%
%   Large condition numbers imply that A is near a matrix with
%   multiple eigenvalues.
%
%   Class support for input A:
%      float: double, single
%
%   See also COND.

%   Note:
%   CONDEIG returns the reciprocals of the Wilkinson s(lambda) numbers.
%
%   Reference:
%   [1] G.H. Golub and C.F. Van Loan, Matrix Computations, Second
%       Edition, Johns Hopkins University Press, Baltimore, Maryland,
%       1989, sec. 7.2.2.
%
%   Copyright 1984-2013 The MathWorks, Inc. 
[X, D, Y] = eig(A);
n = size(A,1);
s = zeros(n,1, class(A));
for i=1:n
    s(i) = norm(Y(:,i)) * norm(X(:,i)) / abs( Y(:,i)'*X(:,i) );
end

if nargout < 2
    X = s; 
end
