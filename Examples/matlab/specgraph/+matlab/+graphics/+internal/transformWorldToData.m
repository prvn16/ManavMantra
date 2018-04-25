function data = transformWorldToData(hDataSpace, belowMatrix, vertexData)
%transformWorldToData Convert coordinates from world primitive to data space
%
%  transformWorldToData(hDataspace, belowTransform, vertexdata) converts
%  the array of vertex coordinates that are used for world objects to data
%  coordinates.  The input data should be an array of size (3xN).
%
%  See also transformViewerToWorld, getSpatialTransforms.

%  Copyright 2013 The MathWorks, Inc.

if ~isempty(hDataSpace)
    iter = matlab.graphics.axis.dataspace.IndexPointsIterator( ...
        'Vertices', vertexData.');
    data = hDataSpace.UntransformPoints(belowMatrix,iter);
else
    data = vertexData;
end
