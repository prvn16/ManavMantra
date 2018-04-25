function vertexData = transformViewerToWorld(hCamera, aboveMatrix, hDataSpace, belowMatrix, pixelLocations)
%transformViewerToWorld  Convert coordinates from viewer to world vertices
%
%  transformViewerToWorld(hCamera, aboveTransform, hDataspace, belowTransform, viewerData) 
%  converts the vector of viewer coordinates viewerData to coordinates in
%  world primitive space.  The viewerData coordinates should have a size of
%  (2xN) or (3xN).  If only 2 rows are provided then they define a ray in
%  world primitive space and in this case the actual point chosen will
%  have an arbitrary z value in the viewer space. 
%
%  See also transformWorldToData, getSpatialTransforms.

%  Copyright 2013-2016 The MathWorks, Inc.

[vp, totalMatrix] = combineTransforms(hCamera, aboveMatrix, hDataSpace, belowMatrix);

% Convert from viewer pixels to normalized camera coordinates
pixelLocations(1,:) = (pixelLocations(1,:) - vp(1))./vp(3);
pixelLocations(2,:) = (pixelLocations(2,:) - vp(2))./vp(4);

pixelLocations = (2.*pixelLocations) - 1;

% Invert the transformation: y = totalMatrix*x; y(1:3) = y(1:3)/y(4); y = y(1:3);
M = totalMatrix(1:3,1:3);
Phi1 = totalMatrix(1:3,4);
Phi2 = totalMatrix(4,1:3);
Phi3 = totalMatrix(4,4);

numVerts = size(pixelLocations, 2);

if size(pixelLocations,1)==2
    % Input is 2D locations.  In this case we will assume the 3rd
    % dimension is in the center of the normalized viewer space, i.e. z=0;
    vertexData = zeros(3, numVerts);
    vertexData(1:2,:) = pixelLocations;
else
    % Input is 3D transformed locations
    vertexData = pixelLocations;
end

if ~all(Phi2==0)
    % General case:
    for n = 1:numVerts
        x = vertexData(:,n);
        Phi = x*Phi2-M;
        vertexData(:, n) = Phi\(Phi1-Phi3*x);
    end
else
    % Faster code for the common case where Phi2 is zero:
    vertexData = -M\(Phi1-Phi3*vertexData);
end
