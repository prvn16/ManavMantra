function Z = viaEig(X,Y)
%   This is an internal implementation of mpower using EIG.

%   Copyright 2014-2015 The MathWorks, Inc.
if  isscalar(Y)
    % If y is a not a real integer-valued scalar, use eigenvalues
    % X and y should never be sparse.
    try
        [V,d] = eig(X,'vector');
        Z = (V.*(d.^Y).')/V;
    catch err
        if (strcmp(err.identifier,'MATLAB:eig:matrixWithNaNInf'))
            Z = NaN(size(X),superiorfloat(X,Y));
        else
            rethrow(err);
        end
    end
else
    % If x is a scalar and Y is a matrix, use eigenvalues.
    % x and Y should never be sparse.
    try
        [V,d] = eig(Y,'vector');
        Z = (V.*(X.^d).')/V;
    catch err
        if (strcmp(err.identifier,'MATLAB:eig:matrixWithNaNInf'))
            Z = NaN(size(Y),superiorfloat(X,Y));
        else
            rethrow(err);
        end
    end
end

