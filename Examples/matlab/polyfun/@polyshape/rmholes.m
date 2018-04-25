function PG = rmholes(pshape)
% RMHOLES Remove all the holes in a polyshape
%
% PG = rmholes(pshape) removes all hole boundaries of a polyshape.
%
% See also addboundary, rmboundary, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

n = polyshape.checkArray(pshape);
PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        continue;
    end
    if pshape(i).NumHoles > 0
        PG(i).Underlying = rmholes(pshape(i).Underlying);
        PG(i).SimplifyState = -1;
    end
end
