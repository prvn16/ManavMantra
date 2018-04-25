function A = area(pshape, I)
% AREA Find the area of a polyshape
%
% A = AREA(pshape) returns the area of a polyshape. The area is the sum
% of the area of each solid region of pshape. 
%
% A = AREA(pshape, I) returns the area of the I-th boundary of pshape. This 
% syntax is only supported when pshape is a scalar polyshape object.
%
% See also perimeter, centroid, sortboundaries, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkConsistency(pshape, nargin);

if (nargin == 1)
    n = polyshape.checkArray(pshape);
    A = zeros(n);
    for i=1:numel(pshape)
        if ~pshape(i).isEmptyShape()
            A(i) = pshape(i).Underlying.area();
        end
    end
else
    polyshape.checkScalar(pshape);
    polyshape.checkEmpty(pshape);
    II = polyshape.checkIndex(pshape, I);
    A = zeros(length(II), 1);
    for i=1:length(II)
        A(i) = pshape.Underlying.area(II(i));
    end    
end
end
