function vertexData = convertViewerCoordsToVertexCoords(h, viewerData)

% Converts a pair of viewer coordinates (in pixels) to a vector (3-tuple)
% of primitive coordinates to in the given Axes. This vertex in camera space
% is a member of a subspace which will project onto the specified viewer
% point. This function is the inverse of convertVertexCoordsToViewerCoords.

%  Copyright 2010-2013 The MathWorks, Inc.

if isa(h, 'matlab.graphics.Graphics')
    [hCamera, aboveMatrix, hDataSpace, belowMatrix] =  matlab.graphics.internal.getSpatialTransforms(h);   
else
    error(message('MATLAB:specgraph:private:convertviewercoordstovertexcoords:InvalidAxes'));
end

x = [viewerData 0; viewerData 1].';
vertexData = matlab.graphics.internal.transformViewerToWorld(hCamera, aboveMatrix, hDataSpace, belowMatrix, x);
