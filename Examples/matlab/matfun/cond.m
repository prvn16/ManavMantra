function c = cond(A, p)
%COND   Condition number with respect to inversion.
%   COND(X) returns the 2-norm condition number (the ratio of the
%   largest singular value of X to the smallest).  Large condition
%   numbers indicate a nearly singular matrix.
%
%   COND(X,P) returns the condition number of X in P-norm:
%
%      NORM(X,P) * NORM(INV(X),P). 
%
%   where P = 1, 2, inf, or 'fro'. 
%
%   Class support for input X:
%      float: double, single
%
%   See also RCOND, CONDEST, CONDEIG, NORM, NORMEST.

%   Copyright 1984-2017 The MathWorks, Inc. 

if nargin == 1
    p = 2;
end

if issparse(A)
    warning(message('MATLAB:cond:SparseNotSupported'))
    c = condest(A);
    return
end

if ~isequal(p,2) && ismatrix(A) && size(A,1) ~= size(A,2)
    error(message('MATLAB:cond:normMismatchSizeA'))
end

if isequal(p,2)
    s = svd(A);
    if any(s == 0)   % Handle singular matrix
        c = Inf(class(A));
    else
        c = max(s)./min(s);
        if isempty(c)
            c = zeros(class(A));
        end
    end
else
    % We'll let NORM pick up any invalid p argument.
    c = norm(A,p) * norm(inv(A),p);
end
