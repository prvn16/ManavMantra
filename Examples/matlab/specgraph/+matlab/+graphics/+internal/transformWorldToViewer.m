function pixelLocations = transformWorldToViewer(hCamera, aboveMatrix, hDataSpace, belowMatrix, vertexData, output3D)
%transformWorldToViewer Convert coordinates from world primitive to viewer
%
%  transformWorldToViewer(hCamera, aboveTransform, hDataspace, belowTransform, vertexData)
%  converts the array of world coordinates vertexData to pixel coordinates
%  in the viewer.  The coordinates in vertexData are normally produced by
%  the transform method of the dataspace and should be of size (3xN).  The
%  output will be a (2xN) array of pixel locations.  Where the input data
%  does not have an output pixel (for example it is behind the camera), the
%  pixel values will be NaN.
%
%  transformWorldToViewer(..., include3D) allows requesting of pixel values
%  in a 3rd dimension, i.e. depth information.  Specifying a logical true
%  value will cause the output to be of size (3xN).
%
%  See also transformDataToWorld, getSpatialTransforms.

%  Copyright 2010-2014 The MathWorks, Inc.

if nargin<6
    output3D = false;
end

[vp, totalMatrix] = combineTransforms(hCamera, aboveMatrix, hDataSpace, belowMatrix);

% Convert vertex data into viewer data
[pixelLocations, w] = applyTransform(totalMatrix, vertexData, output3D);

% Scale the points
if ~isempty(w)
    pixelLocations(1,:) = pixelLocations(1,:)./w;
    pixelLocations(2,:) = pixelLocations(2,:)./w;
    if output3D
        pixelLocations(3,:) = pixelLocations(3,:)./w;   
    end
end

% Scale to the viewport.  The viewport pixel coordinates address the
% infinitely thin line at the bottom/left edge of each pixel, so a pixel
% value of vp(1) aligns with the left edge of the viewport and a pixel
% value of vp(1)+vp(3) aligns with the right edge of the final pixel in the
% viewport.
pixelLocations = (1 + pixelLocations)./2;
pixelLocations(1,:) = vp(1) + vp(3).*pixelLocations(1,:);
pixelLocations(2,:) = vp(2) + vp(4).*pixelLocations(2,:);



function [transPoints, w] = applyTransform(totalMatrix, vertexData, output3D)
% Perform totalMatrix * vertexData matrix multiplication.  This is
% optimized to avoid the need for a dummy row of input ones, to avoid
% calculation of the z data and to keep the 4th output row separated.  For
% larger amounts of data this avoids a lot of memory operation overhead.

if output3D
    numOutputDims = 3;
else
    numOutputDims = 2;
end

% Perform multiplication of 3x3 transform data, producing either 2 or 3
% rows of values, depending on whether z values are requested.
tform3x3 = totalMatrix(1:3,1:3);
if isequal(tform3x3, eye(3))
    transPoints = vertexData(1:numOutputDims,:); 
else
    transPoints = tform3x3(1:numOutputDims,:) * vertexData; 
end

% Add in translations
for n = 1:numOutputDims
    if totalMatrix(n,4)~=0
        transPoints(n,:) = transPoints(n,:) + totalMatrix(n,4);
    end
end

if all(totalMatrix(4,:)==[0 0 0 1])
    % This is a common case that will result in all w values being 1, in
    % which case they do not affect the output
    
    % Signal that w does not need to be applied
    w = []; 
else
    % Initialise w
    w = zeros(1, size(vertexData, 2));
    
    % Add in projective transform
    if totalMatrix(4,1)~=0
        w = w + totalMatrix(4,1) .* vertexData(1,:);
    end
    if totalMatrix(4,2)~=0
        w = w + totalMatrix(4,2) .* vertexData(2,:);
    end
    if totalMatrix(4,3)~=0
        w = w + totalMatrix(4,3) .* vertexData(3,:);
    end
    if totalMatrix(4,4)~=0
        w = w + totalMatrix(4,4);
    end
end
