function faceIndex = nearestFace(obj, hContext, point, pointPixel, faces, varargin)
%nearestFace Find the index of the nearest face
%
%  nearestFace(obj, hContext, point, pointPixel, faces, data) returns the
%  index of the face in the faces array that is hit by the ray passing
%  though the provided point and parallel to the Z axis of the screen. The
%  data array should be of size (Nx2) or (Nx3) and the point should be a
%  two or three-element position in the picking reference frame. If the
%  target point is a data location, the pointPixel input should be false,
%  if the target is a pixel the pointPixel input should be true.  If a face
%  is not hit by the ray then the output will be an empty matrix.
% 
%  nearestFace(obj, hContext, point, pointPixel, faces, xdata, ydata, zdata)
%  performs the same operation on separate X, Y, and (optional) Z data
%  vectors.

%  Copyright 2013-2014 The MathWorks, Inc.

faceIndex = [];

% Convert target to picking space
point = obj.targetPointToPickSpace(hContext, point, pointPixel);

% Filter out non-visible data
valid = obj.isValidInPickSpace(hContext, varargin{:});

if any(valid) && all(isfinite(point))
    [faces, validFaces] = createValidFaces(faces, valid);
    
    % Transform data into 3D picking locations
    pickLocations = obj.convertToPickSpace(hContext, varargin, valid, true);
    
    validFaceIndex = matlab.graphics.chart.interaction.dataannotatable.picking.nearestFace(point, pickLocations, faces);
    
    if ~all(validFaces)
        if ~isempty(validFaceIndex)
            validFaceInd = find(validFaces, validFaceIndex);
            faceIndex = validFaceInd(validFaceIndex);
        end
    else
        faceIndex = validFaceIndex;
    end
end
