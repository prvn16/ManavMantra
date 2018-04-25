function vertexData = transformNormalizedToWorld(hDataSpace, belowMatrix, normData) 
%transformNormalizedToWorld  Convert coordinates from normalized to world vertices
%
%  transformNormalizedToWorld(hDataspace, belowTransform, normData) 
%  converts the vector of normalized coordinates normData to coordinates in
%  world primitive space.  The viewerData coordinates should have a size of
%  (3xN).
%
%  See also transformWorldToNormalized, getSpatialTransforms.

%  Copyright 2017 The MathWorks, Inc.

[~, totalMatrix] = combineTransforms([], eye(4), hDataSpace, belowMatrix);
w = ones(1,size(normData,2));
data = totalMatrix\[normData; w];
vertexData = data(1:3,:);
