function PG = convhull(pshape)
% CONVHULL Find the convex hull of a polyshape
%
% PG = CONVHULL(pshape) returns the convex hull of the input polyshape. The
% output PG is a polyshape object, or an array of polyshapes that is the
% same size as the input.
%
% See also convexHull, boundingbox, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

%---code below this line---
n = polyshape.checkArray(pshape);
PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        PG(i) = polyshape();
        continue;
    end
    [x, y] = pshape(i).boundary();
    F = isfinite(x);
    xf = x(F);
    yf = y(F);
    [K, V] = convhull(xf, yf);
    H = [xf(K), yf(K)];
    state = warning;
    warning('off', 'MATLAB:polyshape:repairedBySimplify');
    PG(i) = polyshape(H);
    warning(state);
end
