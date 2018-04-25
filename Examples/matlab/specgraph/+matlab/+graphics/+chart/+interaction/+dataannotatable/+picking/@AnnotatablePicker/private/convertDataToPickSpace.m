function viewerLocations = convertDataToPickSpace(hContext, dataIterator, request3D)
%convertDataToPickSpace Covnert data to picking reference frame
%
%  convertDataToPickSpace(hContext, data) converts the given data into the
%  correct reference frame for picking.  The data input may be either an
%  array of 2D/3D data, or a points iterator.  The output will be a (2xN)
%  array of 2D locations.
%
%  convertDataToPickSpace(hContext, data, is3D) specifies whether the
%  output shoudl be 2D or 3D.  Setting is3D to true will cause a (3xN)
%  array of 3D locations to be returned.

%  Copyright 2013-2014 The MathWorks, Inc.

if nargin<3
    request3D = false;
end

[hCamera, Ma, hDS, Mb] = matlab.graphics.internal.getSpatialTransforms(hContext);
vertexData = matlab.graphics.internal.transformDataToWorld(hDS, Mb, dataIterator);
viewerLocations = matlab.graphics.internal.transformWorldToViewer(hCamera, Ma, hDS, Mb, vertexData, request3D);
