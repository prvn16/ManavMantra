function [X, Y] = centroid(pshape, I)
% CENTROID Find the centroid of a polyshape
%
% [X, Y] = centroid(pshape) returns the centroid of a polyshape. If pshape 
% is an array of polyshapes, then centroid returns the x- and y-coordinates
% of the centroid of each polyshape element.
%
% [X, Y] = centroid(pshape, I) returns the centroid of the area enclosed by
% the I-th boundary. This syntax is only supported when pshape is a scalar 
% polyshape.
%
% See also area, perimeter, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkConsistency(pshape, nargin);

if (nargin == 1)
    n = polyshape.checkArray(pshape);
    np = numel(pshape);
    pm = zeros(np, 2);
    for i=1:np
        if pshape(i).isEmptyShape()
            pm(i, :) = [NaN NaN];
        else
            pm(i, :) = pshape(i).Underlying.centroid();
        end
    end
    X = pm(:, 1);
    Y = pm(:, 2);
    X = reshape(X, n);
    Y = reshape(Y, n);
else
    polyshape.checkScalar(pshape);
    polyshape.checkEmpty(pshape);
    II = polyshape.checkIndex(pshape, I);
    ni = length(II);
    pm = zeros(ni, 2);
    for i=1:ni
        pm(i, :) = pshape.Underlying.centroid(II(i));
    end
    X = pm(:, 1);
    Y = pm(:, 2);
end

end
