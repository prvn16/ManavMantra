function [PG, shapeId, vertexId] = union(subject, varargin)
% UNION Find the union of two polyshapes
%
% PG = UNION(pshape1, pshape2) returns the union of two polyshapes. pshape1
% and pshape2 must have compatible array sizes.
%
% PG = UNION(P) returns the union of all polyshape objects in the vector of
% polyshapes P. PG contains the combined regions of all elements of P.
% 
% [PG, shapeId, vertexId] = UNION(pshape1, pshape2) returns the vertex
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
% [PG, shapeId, vertexId] = UNION(P) returns the vertex mapping between
% the vertices in PG and the vertices in the polyshapes vector P.
%
% See also subtract, xor, intersect, polyshape

% Copyright 2016-2018 The MathWorks, Inc.

narginchk(1, 2);
nargoutchk(0, 3);
ns = polyshape.checkArray(subject);
if nargin==1
    [PG, shapeId, vertexId] = booleanVec(subject, @unionvec);
else
    clip = varargin{1};
    if (~isa(clip, 'polyshape'))
        error(message('MATLAB:polyshape:scalarPolyshapeError'));
    end
    nc = polyshape.checkArray(clip);

    if ~(isscalar(subject) && isscalar(clip)) && nargout > 1
        error(message('MATLAB:polyshape:noVertexMapping'));
    end
    [PG, shapeId, vertexId] = booleanFun(subject, clip, @union);
end
