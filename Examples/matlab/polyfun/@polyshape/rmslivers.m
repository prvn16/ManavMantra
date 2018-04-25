function PG = rmslivers(pshape, d)
% RMSLIVERS Remove slivers in a polyshape
%
% PG = RMSLIVERS(pshape, d) removes boundary outliers that cause slivers or 
% antennae in a polyshape region according to a tolerance d>0. d is 
% typically orders of magnitude smaller than the size of the bounding box
% of the polyshape.
%
% See also simplify, polybuffer, translate, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

n = polyshape.checkArray(pshape);
d = polyshape.checkScalarValue(d, 'MATLAB:polyshape:sliverTolError');
if d <= 0
    error(message('MATLAB:polyshape:sliverTolError'));
end

PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape
        continue;
    end
    PG(i).Underlying = cleanup(pshape(i).Underlying, d);
    PG(i).SimplifyState = -1;
end
