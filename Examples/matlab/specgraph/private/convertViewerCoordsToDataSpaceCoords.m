function dataspaceData = convertViewerCoordsToDataSpaceCoords(h, viewerData, returnEndpoints)

% Converts a pair of viewer coordinates (in pixels) to a vector (3-tuple)
% of camera coordinates to in the given Axes. This vertex in camera space
% is a member of a subspace which will project onto the specified viewer
% point. This function is the inverse of convertDataSpaceCoordsToViewerCoords.

%  Copyright 2011-2013 The MathWorks, Inc.

if isa(h, 'matlab.graphics.Graphics')
    [hCamera, aboveMatrix, hDataSpace, belowMatrix] =  matlab.graphics.internal.getSpatialTransforms(h);
else
    error(message('MATLAB:specgraph:private:convertviewercoordstodataspacecoords:InvalidAxes'));
end

if nargin < 3
    returnEndpoints = false;
end

x = [viewerData 0; viewerData 1].';
vertexData = matlab.graphics.internal.transformViewerToWorld(hCamera, aboveMatrix, hDataSpace, belowMatrix, x);
% dsPoints = matlab.graphics.internal.transformWorldToData(hDataSpace, belowMatrix, vertexData);

isXLog = false;
isYLog = false;
isZLog = false;
% In log scale, we need to clip the VertexData to 0-1
if isa(hDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
    isXLog = strcmp(hDataSpace.XScale,'log');
    isYLog = strcmp(hDataSpace.YScale,'log');
    isZLog = strcmp(hDataSpace.ZScale,'log');
    if isXLog || isYLog || isZLog
        vertexData = matlab.graphics.internal.clipLimitsToUnitCube(vertexData);
    end
end

% % Convert the vertex coordinates to data space coordinates. Note that if
% % the dataspace uses the fast-path (isLinear() returns true), the following
% % will be a no-op
[~, ~, hDataSpace, belowMatrix] = matlab.graphics.internal.getSpatialTransforms(h);   
iter = matlab.graphics.axis.dataspace.IndexPointsIterator( ...
            'Vertices', vertexData.');
dsPoints = hDataSpace.UntransformPoints(belowMatrix,iter);
v1 = dsPoints(:,1);
v2 = dsPoints(:,2);

% Find the intersections of the line connecting the two points with the box
% defined by the axes limits to obtain the same result as the axes 
% CurrentPoint.
intersects = [];
xLims = hDataSpace.XLim;
yLims = hDataSpace.YLim;
zLims = hDataSpace.ZLim;

% X Planes
lowerX = localFindFaceIntersect(v1,v2,1,xLims(1));
if ~isempty(lowerX) && lowerX(2)>=yLims(1) && lowerX(2)<=yLims(2) && ...
        lowerX(3)>=zLims(1) && lowerX(3)<=zLims(2)
    intersects = [intersects,lowerX];
end
upperX = localFindFaceIntersect(v1,v2,1,xLims(2));
if ~isempty(upperX) && upperX(2)>=yLims(1) && upperX(2)<=yLims(2) && ...
        upperX(3)>=zLims(1) &&  upperX(3)<=zLims(2)
    intersects = [intersects,upperX];
end

% Y Planes
lowerY = localFindFaceIntersect(v1,v2,2,yLims(1));
if ~isempty(lowerY) && lowerY(1)>=xLims(1) && lowerY(1)<=xLims(2) && ...
        lowerY(3)>=zLims(1) && lowerY(3)<=zLims(2)
    intersects = [intersects,lowerY];
end
upperY = localFindFaceIntersect(v1,v2,2,yLims(2));
if ~isempty(upperY) && upperY(1)>=xLims(1) && upperY(1)<=xLims(2) && ....
        upperY(3)>=zLims(1) && upperY(3)<=zLims(2)
    intersects = [intersects,upperY];
end   

% Z Planes
lowerZ = localFindFaceIntersect(v1,v2,3,zLims(1));
if ~isempty(lowerZ) && lowerZ(1)>=xLims(1) && lowerZ(1)<=xLims(2) && ...
        lowerZ(2)>=yLims(1) && lowerZ(2)<=yLims(2)
    intersects = [intersects,lowerZ];
end
upperZ = localFindFaceIntersect(v1,v2,3,zLims(2));
if ~isempty(upperZ) && upperZ(1)>=xLims(1) && upperZ (1)<=xLims(2) && ...
        upperZ (2)>=yLims(1) && upperZ(2)<=yLims(2)
    intersects = [intersects,upperZ];
end

if size(intersects,2)<=1
    if returnEndpoints
        dataspaceData = [v1,v2];
    else
        dataspaceData = v1;
    end
else
    if returnEndpoints
        dataspaceData = intersects;
    elseif isXLog || isYLog || isZLog
        dataspaceData = findrealmean(intersects, isXLog, isYLog, isZLog);
    else
        dataspaceData = (intersects(:,1)+intersects(:,2))/2;
    end
end

function mean_vec = findrealmean(mat, isXLog, isYLog, isZLog)

orig_mat = mat;
mat(1,:) = convertLogToLinear(isXLog, mat(1,:));
mat(2,:) = convertLogToLinear(isYLog, mat(2,:));
mat(3,:) = convertLogToLinear(isZLog, mat(3,:));

mean_vec = mean(mat,2);

mean_vec(1) = convertLinearToLog(isXLog, orig_mat(1,:), mean_vec(1));
mean_vec(2) = convertLinearToLog(isYLog, orig_mat(2,:), mean_vec(2));
mean_vec(3) = convertLinearToLog(isZLog, orig_mat(3,:), mean_vec(3));


function linearData = convertLogToLinear(isLog, data)
linearData = data;
if isLog
    if any(data<0) % negative-value log case (-10^n)
        linearData = -log10(abs(data));
    else
        linearData = log10(data);
    end
end


function logData = convertLinearToLog(isLog, origData, data)
logData = data;
if isLog
    if any(origData < 0)  % negative log case
        logData = -real(10.^abs(data));
    else
        logData = 10.^data;
    end
end


function v = localFindFaceIntersect(v1,v2,planeIndex,pos)

% Find the intersection of the x,y,z planes at the locations specified by
% pos (e.g. the plane "x == pos"). The planeIndex identifies the plane as
% follows: x - planeIndex==1,y - planeIndex==2,z - planeIndex==3. v1 and v2
% are 2 3-tuple column vectors that define a line.

% If the line is parallel to the plane then return empty if the line is not
% coincident with the plane and the first point on the line otherwise.
if abs(v1(planeIndex)-v2(planeIndex))<eps
    if v1(planeIndex)==pos
        v = v1;
    else
        v = [];
    end
    return
end

lambda = (pos-v1(planeIndex))/(v2(planeIndex)-v1(planeIndex));
v = v1+lambda*(v2-v1);
