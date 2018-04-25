function NV = numsides(pshape, I)
% NUMSIDES Find the number of sides in a polyshape
%
% N = NUMSIDES(pshape) returns the total number of sides in a polyshape.
%
% N = NUMSIDES(pshape, I) returns the number of sides of the boundary
% indexed by I. I can be a scalar index or a vector of boundary indices.
% This syntax is only supported when pshape is a scalar polyshape object.
%
% See also area, boundary, polyshape

% Copyright 2017 The MathWorks, Inc.

polyshape.checkConsistency(pshape, nargin);

if (nargin == 1)
    %does not error if polyshape is empty
    %does not warn if polyshape is not simplified
    n = polyshape.checkArray(pshape);
    NV = zeros(n);
    for i=1:numel(pshape)
        NV(i) = pshape(i).Underlying.numvertices();
    end
else
    polyshape.checkScalar(pshape);
    polyshape.checkEmpty(pshape);
    II = polyshape.checkIndex(pshape, I);
    n = length(II);
    NV = zeros(n, 1);
    for i=1:n
        NV(i) = pshape.Underlying.numvertices(II(i));
    end
end

end
