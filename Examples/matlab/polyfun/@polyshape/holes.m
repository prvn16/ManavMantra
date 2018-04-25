function PG = holes(pshape)
% HOLES Convert all hole boundaries of a polyshape to an array of polyshapes
%
% PG = HOLES(pshape) returns an array of polyshape objects containing the
% hole boundaries of the input polyshape. The input polyshape must be a
% scalar.
%
% See also regions, rmholes, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkScalar(pshape);

R0 = holes(pshape.Underlying);
n = size(R0,1);
if (n == 0)
    PG = polyshape.empty(0, 1);
else
    for i=n:-1:1
        PG(i, 1) = polyshape();
        PG(i, 1).Underlying = R0(i);
        PG(i, 1).SimplifyState = pshape.SimplifyState;
    end
end
end
