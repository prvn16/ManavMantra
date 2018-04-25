function vertexData = transformDataToWorld(hDataSpace, belowMatrix, data)
%transformDataToWorld Convert coordinates from data to world primitive space
%
%  transformDataToWorld(hDataspace, belowTransform, data) converts the
%  array of data coordinates, data, to vertex coordinates that are used for
%  world objects.  The input data should be an array of size (2xN) or
%  (3xN).
%
%  transformDataToWorld(hDataspace, belowTransform, dataIterator) accepts
%  an iterator for the data instead of an array.  dataIterator must be an
%  instance of a PointsIterator.
%
%  See also transformWorldToViewer, getSpatialTransforms.

%  Copyright 2011-2013 The MathWorks, Inc.

% Convert the dataspace coordinates to vertex coordinates. Note that if
% the dataspace uses the fast-path (isLinear() returns true), the following
% will be a no-op
if isa(data, 'matlab.graphics.axis.dataspace.PointsIterator')
    iter = data;
else
    iter = matlab.graphics.axis.dataspace.IndexPointsIterator( ...
        'Vertices', data.');
end

% If there is a dataspace, call the transform method.
if ~isempty(hDataSpace)
    vertexData = double(hDataSpace.TransformPoints(belowMatrix,iter));
else
    % Directly copy data into vertex array
    vertexData = iter.NextPoints(iter.GetNumPoints).';
end
