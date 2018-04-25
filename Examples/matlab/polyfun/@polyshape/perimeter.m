function PM = perimeter(pshape, I)
% PERIMETER Get the perimeter of a polyshape
%
% PM = PERIMETER(pshape) returns the perimeter of a polyshape, which is the 
% sum of lengths of the boundaries of the polyshape.
%
% PM = PERIMETER(pshape, I) returns the perimeters of the boundaries
% indexed by I. This syntax is only supported when pshape is a scalar
% polyshape.
%
% See also area, centroid, polybuffer, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkConsistency(pshape, nargin);

if (nargin == 1)
    n = polyshape.checkArray(pshape);
    PM = zeros(n);
    for i=1:numel(pshape)
        if ~pshape(i).isEmptyShape()
            PM(i) = pshape(i).Underlying.perimeter();
        end
    end
else
    polyshape.checkScalar(pshape);
    polyshape.checkEmpty(pshape);
    II = polyshape.checkIndex(pshape, I);
    PM = zeros(length(II), 1);
    for i=1:length(II)
        PM(i) = pshape.Underlying.perimeter(II(i));
    end    
end

end
