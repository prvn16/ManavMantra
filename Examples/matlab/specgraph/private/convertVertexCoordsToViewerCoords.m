function pixelLocations = convertVertexCoordsToViewerCoords(hCamera, aboveMatrix, hDataSpace, belowMatrix, vertexData)
%convertVertexCoordsToViewerCoords  Convert coordinates from camera to viewer
%
%  convertVertexCoordsToViewerCoords(hCamera, aboveTransform, hDataspace, belowTransform, vertexData)
%  converts the vector of camera coordinates vertexData to pixel
%  coordinates in the viewer.  The camera coordinates in vertexData are
%  normally produced by the transform method of the dataspace.
%
%  convertVertexCoordsToViewerCoords(hAxes, vertexData) uses the camera and
%  dataspace from the specified axes and assumes that there is no
%  additional model transform between the dataspace and the location where
%  the vertexData is used.
%
%  convertVertexCoordsToViewerCoords(hPrim, vertexData) uses the camera and
%  dataspace that contain the specified object and calculates the model
%  transform between the dataspace and the object.

%  Copyright 2010-2013 The MathWorks, Inc.

narginchk(2,5);

if nargin==2
    if isa(hCamera, 'matlab.graphics.Graphics')
        vertexData = aboveMatrix;
        [hCamera, aboveMatrix, hDataSpace, belowMatrix] =  matlab.graphics.internal.getSpatialTransforms(hCamera);
    else
        error(message('MATLAB:specgraph:private:convertvertexcoordstoviewercoords:invalidaxes'));
    end
end

if ~isempty(hCamera) && ~isa(hCamera,'matlab.graphics.axis.camera.Camera')
    error(message('MATLAB:specgraph:private:convertvertexcoordstoviewercoords:InvalidCamera'));
end

if ~isempty(hDataSpace) && ~isa(hDataSpace,'matlab.graphics.axis.dataspace.DataSpace')
    error(message('MATLAB:specgraph:private:convertvertexcoordstoviewercoords:InvalidDataSpace'));
end

pixelLocations = matlab.graphics.internal.transformWorldToViewer(hCamera, aboveMatrix, hDataSpace, belowMatrix, vertexData);
