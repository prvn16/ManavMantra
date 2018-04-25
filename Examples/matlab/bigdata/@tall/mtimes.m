function Z = mtimes(X,Y)
%*  Matrix multiply.
%   Z = X*Y
%
%   If both X and Y are tall arrays, one of them must be a scalar.
%
%   See also: mtimes, tall.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,2);

allowedTypes = {'numeric', 'char', 'logical', ... % 'categorical' is not supported for MTIMES
                'duration', 'calendarDuration'};
X = tall.validateType(X, mfilename, allowedTypes, 1);
Y = tall.validateType(Y, mfilename, allowedTypes, 2);

adapX = matlab.bigdata.internal.adaptors.getAdaptor(X);
adapY = matlab.bigdata.internal.adaptors.getAdaptor(Y);

% If either input is scalar, immediately divert to TIMES
if adapX.isKnownScalar() || adapY.isKnownScalar()
    Z = times(X,Y);
    return;
end

if istall(X)
    if istall(Y)
        % If both are tall, we require one of them to be scalar. Verify
        % that and call TIMES.
        [X,Y] = iVerifyAtLeastOneScalar(X,Y,"MATLAB:bigdata:array:MtimesBothTall");
        Z = times(X,Y);
        return;
    end
    
    % Here, we know Y is not scalar. If it is a matrix, then X must also be a
    % matrix.
    if ismatrix(Y)
        X = tall.validateMatrix(X, 'MATLAB:mtimes:inputsMustBe2D');
        if size(Y, 1) ~= 1
            X = tall.validateNotScalar(X, 'MATLAB:bigdata:array:MtimesTallXScalar');
        end
        X = tall.validateNumColumns(X, size(Y, 1), 'MATLAB:innerdim');
        
        % Since Y isn't tall and isn't scalar, broadcast it and process slice-wise
        Yb = matlab.bigdata.internal.broadcast(Y);
        Z = slicefun(@mtimes, X, Yb);
        
        adaptor = multiplicationOutputAdaptor(X, Y);
        
        % In this case, we can perform the normal MTIMES propagation rules.
        % tall size matches X, size(Z) == [size(X,1), size(Y,2)].
        adaptor = copyTallSize(adaptor, X.Adaptor);
        Z.Adaptor = setSmallSizes(adaptor, size(Y, 2));
    else
        % Y is not a matrix, so either X is a scalar, or it's an error.
        X = tall.validateScalar(X, 'MATLAB:mtimes:inputsMustBe2D');
        Z = times(X,Y);
        Z.Adaptor = setKnownSize(Z.Adaptor, size(Y));
    end
else
    % For Y tall, X has to be scalar unless Y is. If we know that either is
    % scalar we don't get here, so we must check lazily instead.
    [X,Y] = iVerifyAtLeastOneScalar(X,Y,"MATLAB:bigdata:array:MtimesXNotScalar");
    Z = times(X,Y);
end

end


function [X,Y] = iVerifyAtLeastOneScalar(X,Y,errId)
% Check that at least one of X, Y is scalar. If the sizes are both known
% this is immediate, otherwise lazy. We won't get here if we already know
% one is scalar, so we're really checking whether we know they aren't!
adapX = matlab.bigdata.internal.adaptors.getAdaptor(X);
adapY = matlab.bigdata.internal.adaptors.getAdaptor(Y);
if adapX.isKnownNotScalar() && adapY.isKnownNotScalar()
    error(message(errId));
end
    isXscalar = iIsScalar(X);
    isYscalar = iIsScalar(Y);
    % We need to attach the check operation to one of the inputs, but it
    % doesn't really matter which, so long as it is tall.
    if istall(X)
        X = elementfun(@iErrorIfNeitherScalar, X, isXscalar, isYscalar, errId);
    else
        Y = elementfun(@iErrorIfNeitherScalar, Y, isXscalar, isYscalar, errId);
    end
end


function tf = iIsScalar(X)
% Return a scalar logical indicating if the input is scalar. Result is a
% tall scalar if X is tall, or logical if in memory.
if istall(X)
    tf = clientfun(@(x) isequal([1 1], x), size(X));
else
    tf = isscalar(X);
end
end

function X = iErrorIfNeitherScalar(X,isXscalar,isYscalar,errId)
% Helper to error if neither input is scalar. The arrays themselves just
% pass-through.
if ~isXscalar && ~isYscalar
    error(message(errId));
end
end
