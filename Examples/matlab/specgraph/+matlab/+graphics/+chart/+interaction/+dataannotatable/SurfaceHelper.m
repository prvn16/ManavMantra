classdef(Sealed = true) SurfaceHelper < handle
    % A helper class that provides implementations of DataAnnotatable
    % interface methods for Patch and Surface subclasses.
    
    %   Copyright 2010-2016 The MathWorks, Inc.
    
    methods(Access = private)
        % We will make the constructor private to prevent instantiation.
        function hObj = SurfaceHelper
        end
    end
    
    methods(Access = public, Static = true)
        function descriptors = getDataDescriptors(hObj, index, interpolationFactor)
            % Get the data descriptors for an object given the index and
            % interpolation factor.
            
            % We will use the reported position to make a determination.
            pos = matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getReportedPosition(hObj,index,interpolationFactor);
            pos = pos.getLocation(hObj);
            % The three data descriptors will correspond to X, Y and Z,
            % respectively.
            descriptors = matlab.graphics.chart.interaction.dataannotatable.internal.createPositionDescriptors(hObj,pos);
        end
        
        function index = getNearestIndex(hObj, index)
            % Return the nearest index to the requested input.
            
            % If the index is in range, we will return the index.
            % Otherwise, we will error.
            numPoints = numel(hObj.ZDataCache);
            
            % Constrain index to be in the range [1 numPoints]
            if numPoints>0
                index = max(1, min(index, numPoints));
            end
        end
        
        function index = getNearestPoint(hObj, position)
            % Returns the index representing the point on the surface nearest
            % to a 1x2 pixel position in the figure.
            
            index = localGetNearestVertex(hObj, position);
        end
        
        function [index, interpolationFactor] = getInterpolatedPoint(hObj, position)
            % Returns the index and interpolation factor representing the
            % point on the object nearest to a 1x2 pixel position in the
            % figure.
            [index, interpolationFactor] = localGetNearestVertex(hObj, position);
        end
        
        function [index, interpolationFactor] = incrementIndex(index, direction, ~, dataSize)
            % The index will be treated as an index into the ZData, which is a matrix.
            [currRow, currCol] = ind2sub(dataSize, index);
            retInd = index;
            try
                switch(direction)
                    case 'up'
                        % This should increment the row.
                        newRow = currRow + 1;
                        modVal = mod(newRow-1,dataSize(1))+1;
                        addVal = ~(modVal==newRow);
                        newRow = modVal;
                        % If we saturate the row, increment the column:
                        newCol = currCol + addVal;
                    case 'down'
                        % This should decrement the row
                        newRow = currRow-1;
                        % If we saturate the row, decrement the column:
                        addVal = ~(newRow>0);
                        newRow = newRow + dataSize(1)*addVal;
                        newCol = currCol - addVal;
                    case 'left'
                        % This should decrement the column
                        newCol = currCol-1;
                        % If we saturate the column, decrement the row:
                        addVal = ~(newCol>0);
                        newCol = newCol + dataSize(2)*addVal;
                        newRow = currRow - addVal;
                    case 'right'
                        % This should increment the column.
                        newCol = currCol + 1;
                        modVal = mod(newCol-1,dataSize(2))+1;
                        addVal = ~(modVal==newCol);
                        newCol = modVal;
                        % If we saturate the column, increment the row:
                        newRow = currRow + addVal;
                end
                retInd = sub2ind(dataSize, newRow, newCol);
            catch E %#ok<NASGU>
                % We will do nothing here as the index can not be incremented.
            end
            index = retInd;
            interpolationFactor = 0;
        end
        
        function pos = getDisplayAnchorPoint(hObj, index, interpolationFactor)
            % Returns the position that should be used to overlay views on
            % the object for the given index and interpolation factor.
            
            pos = [];
            
            xData = hObj.XDataCache;
            yData = hObj.YDataCache;
            zData = hObj.ZDataCache;

            if localCheckDataConsistency(xData, yData, zData)
                
                if localIsCurrentInterpolated(interpolationFactor)
                    pos = localCreatePlanePoint(xData, yData, zData, interpolationFactor);
                    
                elseif localIsOldInterpolated(interpolationFactor)
                    pos = matlab.graphics.shape.internal.util.SimplePoint(interpolationFactor.pout);
                    
                else
                    numPoints = numel(zData);
                    if index>0 && index<=numPoints
                        % The anchor is simply the data point at the current index.
                        xIndex = index;
                        yIndex = index;
                        dataSize = size(zData);
                        if ~isequal(size(xData),dataSize)
                            [~, xIndex] = ind2sub(dataSize, index);
                        end
                        if ~isequal(size(yData),dataSize)
                            [yIndex, ~] = ind2sub(dataSize, index);
                        end
                        
                        pos = matlab.graphics.shape.internal.util.SimplePoint(...
                            [double(xData(xIndex)) double(yData(yIndex)) double(zData(index))]);
                    end
                end
                
            end
            
            if isempty(pos)
                % Construction of default value is deferred to save time if
                % it isn't needed
                pos = matlab.graphics.shape.internal.util.SimplePoint([NaN NaN NaN]);
            end
        end
        
        function pos = getReportedPosition(hObj, index, interpolationFactor)
            % Returns the position that should be reported back to the user
            % for the given index and interpolation factor.
            
            % The reported position is simply the anchor point.
            pos = matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
        
        function index = getEnclosedPoints(hObj, polygon)
            xData = hObj.XDataCache;
            yData = hObj.YDataCache;
            zData = hObj.ZDataCache;
            dataSize = size(zData);
            
            if isscalar(xData)
                xData = repmat(xData, dataSize);
            elseif ~isequal(size(xData), dataSize)
                xData = repmat(xData(:).', dataSize(1), 1);
            end
            if isscalar(yData)
                yData = repmat(yData, dataSize);
            elseif ~isequal(size(yData), dataSize)
                yData = repmat(yData(:), 1, dataSize(2));
            end

            % Translate polygon into local container reference frame
            polygon = brushing.select.translateToContainer(hObj, polygon);
            
            % Treat data as scattered points and just look for the
            % closest
            utils = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            index = utils.enclosedPoints(hObj, polygon, xData(:), yData(:), zData(:));
        end
        
    end
end



function [index, interp] = localGetNearestVertex(hSurface, position)
% Find the nearest point index and provide an interpolation structure if a 
% face is hit.

pickUtils = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

xdata = hSurface.XDataCache;
ydata = hSurface.YDataCache;
zdata = hSurface.ZDataCache;

interp = [];
index = [];

if localCheckDataConsistency(xdata, ydata, zdata)
    if all(size(zdata)>1)
        % The data forms faces
        [f, verts] = surf2patch(xdata, ydata, zdata, 'triangles');

        if strcmp(hSurface.FaceColor,'none') && strcmp(hSurface.LineStyle,'none')
            % Only markers are visible - treat the data as a point cloud
            % with no interpolation allowed
            index = pickUtils.nearestPoint(hSurface, position, true, verts);

        else
            % The faces are visible, even if they are only really a mesh
            [index, faceIndex, intFactors] = pickUtils.nearestFacePoint(hSurface, position, true, f, verts);

            if nargout>1 && ~isempty(faceIndex)
                % Create the interpolation structure with the extra information
                % about which face we intersected and where on it we hit.
                
                % To provide save compatibility with older versions, we
                % need to compute and save the intersection point at this
                % time.  This point is no longer correct if the surface
                % changes, but it is used in older versions.
                intPoint = localCreateIntPoint(f, verts, faceIndex, intFactors);
                
                % surf2patch creates 2 triangles for each face quad.  They
                % are ordered as the first triangle for each quad followed
                % by the second triangle for each quad, so we need to test
                % whether the hit triangle is in the first or second half
                % of the triangle list.
                numQuads = size(f, 1)/2;
                if faceIndex <= numQuads
                    triIndex = 1;
                else
                    faceIndex = faceIndex - numQuads;
                    triIndex = 2;
                end
                
                % Convert face index to a 2D indexing scheme since this
                % will be more stable if data changes size
                [faceSub(1), faceSub(2)] = ind2sub(size(zdata)-1, faceIndex);
                
                % This structure includes the three fields that we need in
                % current code, plus two fields which are required for old
                % versions of MATLAB to work.  This ensures that the cursor
                % can be loaded into older versions without an error.
                allFaceVerts = verts([f(faceIndex,:) f(faceIndex+numQuads,end)], :).';
                interp = struct('FaceIndex', faceSub, ...
                    'TriIndex', triIndex, ...
                    'InterpFactors', intFactors, ...
                    'pout', intPoint, ...
                    'facevout', allFaceVerts );
            end
        end

    else
        % Scalar expand x,y values if necessary
        if numel(xdata)==1
            xdata = repmat(xdata, size(zdata));
        end
        if numel(ydata)==1
            ydata = repmat(ydata, size(zdata));
        end

        if strcmpi(hSurface.LineStyle,'none')
            % Only markers are visible - treat the data as a point cloud
            index = pickUtils.nearestPoint(hSurface, position, true, xdata, ydata, zdata);
        else
            % This is a surface with no faces.  Treat the data as a single line
            [index1, index2, t] = pickUtils.nearestSegment(hSurface, position, true, xdata, ydata, zdata);
            if t<=0.5
                index = index1;
            else
                index = index2;
            end
        end
    end
end

if isempty(index)
    % Default to picking the first point
    index = 1;
end

end


function ret = localCheckDataConsistency(X, Y, Z)
% Check that X/Y/Z sizes are consistent

xSize = size(X);
ySize = size(Y);
zSize = size(Z);

xOK = all(xSize==zSize) ...
    || (isvector(xSize) && numel(X)==zSize(2));

yOK = all(ySize==zSize) ...
    || (isvector(ySize) && numel(Y)==zSize(1));    

ret = xOK && yOK;
end


function intPoint = localCreateIntPoint(faces, verts, faceIndex, intFactors)
v = verts(faces(faceIndex,:), :);
vect1 = v(2,:)-v(1,:);
vect2 = v(3,:)-v(1,:);
intPoint = v(1,:) + intFactors(1)*vect1 + intFactors(2)*vect2;
end


function ret = localIsCurrentInterpolated(interpolationFactor)
% Test whether the interpolation factor value contains the fields required
% for the current interpolation, and has non-zero interp factors.
ret = isstruct(interpolationFactor) && ...
    all(isfield(interpolationFactor, {'FaceIndex', 'TriIndex', 'InterpFactors'})) && ...
    ~all(interpolationFactor.InterpFactors==0);
end


function pos = localCreatePlanePoint(xData, yData, zData, interpolationFactor)
% Parameterize the current point in terms of 3 points of the face. This
% parameterization is done at the point of picking: here we just find the
% correct current vertex values to apply it to.
pos = [];

[m, n]= size(zData);

r = interpolationFactor.FaceIndex(1);
c = interpolationFactor.FaceIndex(2);

if (r>0 && c>0 && r<m && c<n)
    % Find vertex indices for the right triangle in the right face.  These
    % vertices are defined by the way that the surface is triangulated in
    % surf2patch.  Although this is not the only correct way to perform the
    % triangulation, it matches what the majority of graphics cards will
    % do.
    if interpolationFactor.TriIndex==1
        vertInd = [r c; r c+1; r+1 c+1];
    else
        vertInd = [r c; r+1 c+1; r+1 c];
    end
    
    % Extract vertices from x, y, z data
    
    % Get Z value and initialize all the vertices to double arrays.  All
    % later indexing into these vectors will now cast to double.
    v1 = [0 0 double(zData(vertInd(1,1), vertInd(1,2)))];
    v2 = [0 0 double(zData(vertInd(2,1), vertInd(2,2)))];
    v3 = [0 0 double(zData(vertInd(3,1), vertInd(3,2)))];
    
    if isequal(size(xData), [m n])
        v1(1) = xData(vertInd(1,1), vertInd(1,2));
        v2(1) = xData(vertInd(2,1), vertInd(2,2));
        v3(1) = xData(vertInd(3,1), vertInd(3,2));
    else
        % Use column index only
        v1(1) = xData(vertInd(1,2));
        v2(1) = xData(vertInd(2,2));
        v3(1) = xData(vertInd(3,2));
    end
    
    if isequal(size(yData), [m n])
        v1(2) = yData(vertInd(1,1), vertInd(1,2));
        v2(2) = yData(vertInd(2,1), vertInd(2,2));
        v3(2) = yData(vertInd(3,1), vertInd(3,2));
    else
        % Use row index only
        v1(2) = yData(vertInd(1,1));
        v2(2) = yData(vertInd(2,1));
        v3(2) = yData(vertInd(3,1));
    end
    
    pos = matlab.graphics.shape.internal.util.PlanePoint(...
        v1, ...
        v2, interpolationFactor.InterpFactors(1), ...
        v3, interpolationFactor.InterpFactors(2));
end
end


function ret = localIsOldInterpolated(interpolationFactor)
% Test whether the interpolation factor value contains the old field that
% contains an already-interpolated position.
ret = isstruct(interpolationFactor) && ...
    isfield(interpolationFactor, 'pout') && ...
    ~isempty(interpolationFactor.pout);
end

