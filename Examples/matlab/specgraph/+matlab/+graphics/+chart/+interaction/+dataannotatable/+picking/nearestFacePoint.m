function [vertIndex, faceIndex, intPoint] = nearestFacePoint(point, verts, faces)
%nearestFacePoint Find the index of the nearest point
%
%  [vertIndex, faceIndex] = nearestFacePoint(point, data, faces) returns
%  the index of the point in the data array that is closest to the provided
%  point, assuming that the data vertices are linked as faces.  The index
%  of the hit face, if there is one, is also returned.  
%
%  The hit face is first found by projecting a ray parallel to the z axis
%  and through the given point, and then the closest data point on that
%  face is returned.  If no face is hit then the faceIndex will be empty
%  and the vertIndex will simply be the nearest point.
%
%  [vertIndex, faceIndex, inPoint] = nearestFacePoint(...) also returns the
%  intersection point on the hit face.  The intersection point will be
%  empty if no face is hit.

%  Copyright 2013-2014 The MathWorks, Inc.

% Find which faces we intersect
faceIndex = matlab.graphics.chart.interaction.dataannotatable.picking.intersectedFaces(point, verts, faces);

intPoint = [];
vertIndex = [];
if isempty(faceIndex)
    % Return a 0x0 empty, not the empty list that intersectedFaces gave us
    faceIndex = [];
    
    % If we did not intersect a face then simply choose the closest vertex
    % that is in any face.  We ignore vertices that are not used in a face.
    
    usedVertList = local_getUsedVerts(faces);
    usedVert = false(1, size(verts, 2));
    usedVert(usedVertList(:)) = true;
    if all(usedVert)
        % All vertices are in a face
        vertIndex = matlab.graphics.chart.interaction.dataannotatable.picking.nearestPoint(point, verts);
        
    elseif any(usedVert)
        % Some vertices are used, some are not
        vertIndex = matlab.graphics.chart.interaction.dataannotatable.picking.nearestPoint(point, verts(:, usedVert));
        usedMap = find(usedVert, vertIndex);
        vertIndex = usedMap(vertIndex);
    end
    
else
    % Find the closest intersected face.  We need to do this even if there
    % is only one hit face because we want the intersection point as an
    % output.
    [nearestFaceIndex, intPoint] = matlab.graphics.chart.interaction.dataannotatable.picking.nearestFaceIntersection(point, verts, faces(faceIndex,:));
    faceIndex = faceIndex(nearestFaceIndex);
    
    % Find the closest vertex in the valid intersected face indices
    candidateFace = faces(faceIndex,:);
    
    % Trim down to non-NaN vertex indices
    firstNaN = find(isnan(candidateFace), 1);
    if ~isempty(firstNaN)
        candidateFace = candidateFace(1:firstNaN-1);
    end
    
    vertIndex = matlab.graphics.chart.interaction.dataannotatable.picking.nearestPoint(point(1:2), verts(1:2,candidateFace));
    vertIndex = candidateFace(vertIndex);
end


function used = local_getUsedVerts(faces)
% Nans in the faces matrix occur and are valid; they are used when there
% are faces with different numbers of vertices.  However they can be mixed
% in with with non-NaNs in ways that cause those non-NaNs to no longer be
% part of any face.

facenans = isnan(faces);
if any(facenans(:))
    % We need to ignore any face indices that follow a NaN in a row.  To do
    % this we will loop over the columns and propogate any NaNs into the
    % next column
    for n = 1:size(faces, 2)-1
        faces(facenans(:,n),n+1) = NaN;
        facenans(facenans(:,n),n+1) = true;
    end

    used = faces(~facenans); 
else
    used = faces(:);
end