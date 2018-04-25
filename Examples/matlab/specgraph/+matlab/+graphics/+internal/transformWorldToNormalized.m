function normData = transformWorldToNormalized(hDataSpace, belowMatrix, vertexData) 
%transformWorldToNormalized  Convert coordinates from world to normalized vertices
%
%  transformWorldToNormalized(hDataspace, belowTransform, vertexData) 
%  converts the vector of world coordinates normData to coordinates in
%  normalized coordinate space.  The viewerData coordinates should have a
%  size of (3xN).
%
%  See also transformNormalizedToWorld, getSpatialTransforms.

%  Copyright 2017 The MathWorks, Inc.

[~, totalMatrix] = combineTransforms([], eye(4), hDataSpace, belowMatrix);
w = ones(1,size(vertexData,2));
data = totalMatrix*[vertexData; w];
normData = data(1:3,:);