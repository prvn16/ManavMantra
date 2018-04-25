function PG = regions(pshape)
% REGIONS Split all regions of a polyshape into a vector of polyshapes
%
% PG = REGIONS(pshape) returns a vector of polyshapes whose elements are
% single region of the input polyshape. pshape must be a scalar polyshape.
%
% See also numboundaries, holes, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkScalar(pshape);

PG = polyshape.empty();
R0 = regions(pshape.Underlying);
n = size(R0, 1);
if (n == 0)
    PG = polyshape.empty(0, 1);
else
    for i=n:-1:1
        PG(i,1) = polyshape();
        PG(i,1).Underlying = R0(i);
        PG(i, 1).SimplifyState = pshape.SimplifyState;
    end
end
