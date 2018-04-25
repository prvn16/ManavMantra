function [PG, shapeId, vertexId] = subtract(subject, clip)
% SUBTRACT Find the difference of two polyshapes
%
% PG = SUBTRACT(pshape1, pshape2) returns the difference between two 
% polyshapes. PG is a polyshape object with the same regions as pshape1
% minus any area where pshape2 overlaps pshape1. pshape1 and pshap2 must
% have compatible array sizes.
% 
% [PG, shapeId, vertexId] = SUBTRACT(pshape1, pshape2) returns the vertex
% mapping between the vertices in PG and the vertices in the polyshapes
% pshape1 and pshape2. shapeId and vertexId are both column vectors with 
% the same number of rows as in the Vertices property of PG. If an element 
% of shapeId is 1, the corresponding vertex in PG is from pshape1. If an
% element of shapeId is 2, the corresponding vertex in PG is from pshape2.
% If an element of shapeId is 0, the corresponding vertex in PG is created 
% by the intersection of pshape1 and pshape2. vertexId contains the row 
% numbers in the Vertices properties for pshape1 or pshape2. An element 
% of vertexId is 0 when the corresponding vertex in PG is created by the 
% intersection. The vertex mapping output arguments are only supported when 
% pshape1 and pshape2 are scalars.
%
% See also union, xor, intersect, polyshape

% Copyright 2016-2018 The MathWorks, Inc.

narginchk(2, 2);
nargoutchk(0, 3);
ns = polyshape.checkArray(subject);
nc = polyshape.checkArray(clip);

if ~(isscalar(subject) && isscalar(clip)) && nargout > 1
    error(message('MATLAB:polyshape:noVertexMapping'));
end
[PG, shapeId, vertexId] = booleanFun(subject, clip, @diff);
