function PG = simplify(pshape)
% SIMPLIFY Fix degeneracies and intersections in a polyshape
%
% PG = SIMPLIFY(pshape) simplifies the input polyshape by resolving all
% boundary intersections and improper nesting, removing duplicate vertices
% and degeneracies.
%
% See also polyshape, issimplified, intersect, addboundary

% Copyright 2016-2017 The MathWorks, Inc.

n = polyshape.checkArray(pshape);
PG = pshape;
np = numel(pshape);
for i=1:np
    if pshape(i).SimplifyState == 1
        PG(i) = pshape(i);
    else
        if pshape(i).isEmptyShape
            PG(i) = polyshape();
        else
            PG(i).Underlying = simplify(pshape(i).Underlying);
            PG(i).SimplifyState = 1;
        end
    end
end
