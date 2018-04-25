function [vertIndex, faceIndex, intFactors] = nearestFacePoint(obj, hContext, point, pointPixel, faces, varargin)
%nearestFacePoint Find the index of the nearest point
%
%  nearestFacePoint(obj, hContext, point, pointPixel, faces, data) returns
%  the index of the point in the 2D or 3D data array that is visually
%  closest to the provided point and is part of a face that the point is
%  within. The data array should be of size (Nx2) or (Nx3) and the point
%  should be a two or three-element position in the picking reference
%  frame. If the target point is a data location, the pointPixel input
%  should be false, if the target is a pixel the pointPixel input should be
%  true.
% 
%  nearestFacePoint(obj, hContext, point, pointPixel, faces, xdata, ydata, zdata)
%  performs the same operation on separate X, Y, and (optional) Z data
%  vectors.
%
%  [vert, face, interp] = nearestFacePoint(...) returns the closest vertex
%  index, the index of the face that was hit, and a two-element vector
%  containing the intersection point expressed in terms of the edge vectors
%  of the face.  If the three vertices of the face are v1, v2 and v3 then
%  the intersection point is given by interp(1)*(v2-v1) +
%  interp(2)*(v3-v1). If the faces have more than three vertices or if the
%  intersection is not within a face then this output will always be empty.

%  Copyright 2013-2014 The MathWorks, Inc.

vertIndex = [];
faceIndex = [];
intFactors = [];

% Convert target to picking space
point = obj.targetPointToPickSpace(hContext, point, pointPixel);

% Filter out non-visible data
valid = obj.isValidInPickSpace(hContext, varargin{:});

if any(valid) && all(isfinite(point))
    [faces, validFaces] = createValidFaces(faces, valid);
    
    % Transform data into 3D picking locations
    pickLocations = obj.convertToPickSpace(hContext, varargin, valid, true);
    
    [validVertIndex, validFaceIndex, intPoint] = matlab.graphics.chart.interaction.dataannotatable.picking.nearestFacePoint(point, pickLocations, faces);
    
    if ~all(valid)
        if ~isempty(validVertIndex)
            % Map back to data index
            validInd = find(valid, validVertIndex);
            vertIndex = validInd(validVertIndex);
        end
        
        if ~isempty(validFaceIndex)
            validFaceInd = find(validFaces, validFaceIndex);
            faceIndex = validFaceInd(validFaceIndex);
        end
    else
        vertIndex = validVertIndex;
        faceIndex = validFaceIndex;
    end
    
    if nargout>2 && ~isempty(intPoint) && size(faces,2)==3  
        % Project the intersection point onto the space defined by the
        % sides of the face.
        AnchorIndex = 1;
        FirstIndex = 2;
        SecondIndex = 3;
        
        % Take the adjacent vertices to form basis vectors for
        % plane
        FaceVerts = pickLocations(:, faces(validFaceIndex,:));
        
        Y = intPoint(:) - FaceVerts(:, AnchorIndex);
        X1 = FaceVerts(:, FirstIndex) - FaceVerts(:, AnchorIndex);
        X2 = FaceVerts(:, SecondIndex) - FaceVerts(:, AnchorIndex);
        intFactors = [X1 X2]\Y;
        
        intFactors = intFactors(:).';
    end
end
