function faceIndex = nearestFace(point, verts, faces)
%nearestFace Find the index of the nearest face
%
%  faceIndex = nearestFace(point, data, faces) returns the index of the row
%  in the faces array that contains the provided point, assuming that the
%  data vertices are linked as faces.
%
%  The hit face is found by projecting a ray parallel to the z axis and
%  through the given point.  If no face is hit then the faceIndex will be
%  empty.

%  Copyright 2014 The MathWorks, Inc.

% Find which faces we intersect
faceIndex = matlab.graphics.chart.interaction.dataannotatable.picking.intersectedFaces(point, verts, faces);

if numel(faceIndex)>1
    % Find the closest intersected face out of the set of hit ones
    nearestFaceIndex = matlab.graphics.chart.interaction.dataannotatable.picking.nearestFaceIntersection(point, verts, faces(faceIndex,:));
    faceIndex = faceIndex(nearestFaceIndex);
    
elseif isempty(faceIndex)
    % Return a 0x0 empty, not the empty list that intersectedFaces gave us
    faceIndex = [];
end
