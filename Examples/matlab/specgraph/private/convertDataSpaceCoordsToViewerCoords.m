function pixelLocations = convertDataSpaceCoordsToViewerCoords(hCamera, aboveMatrix, hDataSpace, belowMatrix, dataspaceData)
%convertDataSpaceCoordsToViewerCoords  Convert coordinates from camera to viewer
%
%  convertDataSpaceCoordsToViewerCoords(hCamera, aboveTransform, hDataspace, belowTransform, dataspaceData)
%  converts the vector of camera coordinates dataspaceData to pixel
%  coordinates in the viewer.
%
%  convertDataSpaceCoordsToViewerCoords(hAxes, dataspaceData) uses the
%  camera and dataspace from the specified axes and assumes that there is
%  no additional model transform between the dataspace and the location
%  where the dataspaceData is used.
%
%  convertDataSpaceCoordsToViewerCoords(hObj, dataspaceData) uses the
%  camera and dataspace that contain the specified object and calculates
%  the model transform between the dataspace and the object.
%
%  convertDataSpaceCoordsToViewerCoords(..., dataIterator) accepts an
%  iterator for the data instead of an array.  dataIterator must be an
%  instance of a PointsIterator.
%
%  See also convertVertexCoordsToViewerCoords, convertViewerCoordsToDataSpaceCoords.

%  Copyright 2011-2013 The MathWorks, Inc.

narginchk(2,5);

if nargin==2
    if isa(hCamera, 'matlab.graphics.Graphics')
        dataspaceData = aboveMatrix;
        [hCamera, aboveMatrix, hDataSpace, belowMatrix] =  matlab.graphics.internal.getSpatialTransforms(hCamera);
    else
        error(message('MATLAB:specgraph:private:convertdataspacecoordstoviewercoords:InvalidAxes'));
    end
end

if ~isempty(hCamera) && ~isa(hCamera,'matlab.graphics.axis.camera.Camera')
    error(message('MATLAB:specgraph:private:convertvertexcoordstoviewercoords:InvalidCamera'));
end

if ~isempty(hDataSpace) && ~isa(hDataSpace,'matlab.graphics.axis.dataspace.DataSpace')
    error(message('MATLAB:specgraph:private:convertdataspacecoordstoviewercoords:InvalidDataSpace'));
end

vertexData = matlab.graphics.internal.transformDataToWorld(hDataSpace, belowMatrix, dataspaceData);
pixelLocations = matlab.graphics.internal.transformWorldToViewer(hCamera, aboveMatrix, hDataSpace, belowMatrix, vertexData);
