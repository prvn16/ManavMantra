function [c,mv] = normAm(A,m)
%NORMAM   Estimate of 1-norm of power of matrix.
%   NORMAM(A,M) estimates norm(A^m,1). If A has nonnegative elements 
%   the estimate is exact.
%   [C, MV] = NORMAM(A,M) returns the estimate C and the number MV of
%   matrix-vector products computed involving A or A^*.

%   Reference: 
%   A. H. Al-Mohy and N. J. Higham, A New Scaling and Squaring Algorithm 
%      for the Matrix Exponential, SIAM J. Matrix Anal. Appl. 31(3):
%      970-989, 2009.
%
%   Awad H. Al-Mohy and Nicholas J. Higham
%   Copyright 2014-2017 The MathWorks, Inc.

n = size(A,1);
if n < 50 % Compute matrix power explicitly
    mv = 0;
    c = norm(A^m,1);
elseif isreal(A) && all(A(:) >= 0)
    % For positive matrices only.
    e = ones(n,1,class(A));
    for j=1:m
        e = A'*e;
    end
    c = norm(e,inf);
    mv = m;
else
    [c,~,~,it] = normest1(@afun_power);
    mv = it(2)*2*m; % Since t = 2.
end
% End of normAm

    function Z = afun_power(flag,X)
        %afun_power  Function to evaluate matrix products needed by normest1.
        if isequal(flag,'dim')
            Z = n;
        elseif isequal(flag,'real')
            Z = isreal(A);
        else
            if isequal(flag,'notransp')
                for i = 1:m
                    X = A*X;
                end
            elseif isequal(flag,'transp')
                for i = 1:m
                    X = A'*X;
                end
            end
            Z = X;
        end
    end
end