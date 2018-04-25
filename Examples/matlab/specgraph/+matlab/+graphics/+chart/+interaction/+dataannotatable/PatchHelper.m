classdef(Sealed = true) PatchHelper < handle
    % A helper class that provides implementations of DataAnnotatable
    % interface methods for Patch and Patch subclasses.
    
    %   Copyright 2010-2015 The MathWorks, Inc.
    
    methods(Access = private)
        % We will make the constructor private to prevent instantiation.
        function hObj = PatchHelper
        end
    end
    
    methods(Access = public, Static = true)
        function descriptors = getDataDescriptors(hObj, index, interpolationFactor)
            % Get the data descriptors for an object given the index and
            % interpolation factor.
            
            % We will use the reported position to make a determination.
            pos = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getReportedPosition(hObj,index,interpolationFactor);
            loc = pos.getLocation(hObj);
            % The three data descriptors will correspond to X, Y and Z,
            % respectively.
            descriptors = matlab.graphics.chart.interaction.dataannotatable.internal.createPositionDescriptors(hObj,loc);
        end
        
        function index = getNearestIndex(hObj, index)
            % Return the nearest index to the requested input.
            
            numPoints = numel(hObj.Faces);
            
            % Constrain index to be in the range [1 numPoints]
            if numPoints>0
                index = max(1, min(index, numPoints));
            end
        end
        
        function index = getNearestPoint(hObj, position)
            % Returns the index representing the point on the object
            % nearest to a 1x2 pixel position in the figure.
            
            index = localGetNearestVertex(hObj, position);
        end
        
        function [index, interpolationFactor] = getInterpolatedPoint(hObj, position)
            % Returns the index and interpolation factor representing the
            % point on the object nearest to a 1x2 pixel position in the
            % figure.
            [index, interpolationFactor] = localGetNearestVertex(hObj, position);
        end
        
        function [index, interpolationFactor] = incrementIndex(hObj, index, direction, ~)
            % Returns the "next" or "previous" index in response to arrow
            % key motion.
            % Moving the directions "up" and "right" will be equivalent, as
            % will "down" and "left". The former will always increment, and
            % the latter will decrement. The interpolation step will always be
            % ignored.
            
            % In patches, the index is taken as an index into the face
            % list.  moving the index up and down moves through the current
            % face then skips to the next face and so on
            
            switch(direction)
                case {'up', 'right'}
                    % This should increment.
                    if index ~= numel(hObj.Faces)
                        index = index + 1;
                    end 
                case {'down', 'left'}
                    % This should increment.
                    if index ~= 1
                        index = index - 1;
                    end
                otherwise
                    % Do nothing, and return the supplied value.
            end
            
            % Remove interpolation: it no longer makes sense if the user
            % has requested to go to the "next", we have to snap to a
            % vertex.
            interpolationFactor = 0;
        end
        
        function pos = getDisplayAnchorPoint(hObj, index, interpolationFactor)
            % Returns the position that should be used to overlay views on
            % the object for the given index and interpolation factor.
            
            pos = [];
            
            verts = hObj.Vertices;
            faces = hObj.Faces;

            if localIsCurrentInterpolated(interpolationFactor)
                % Only use interpolation if the faces are still triangles
                pos = localCreatePlanePoint(faces, verts, interpolationFactor);

            elseif localIsOldInterpolated(interpolationFactor)
                pos = matlab.graphics.shape.internal.util.SimplePoint(interpolationFactor.pout);
            end
            
            if isempty(pos)
                % Checking for empty pos here allows us ot pick up cases
                % where the interpolation failed (e.g. because the face
                % data changed so that a current face index is a NaN).  In
                % these cases we can then try to fall back to the nearest
                % vertex.
                
                % The anchor is simply the vertex at the current index.
                % The index indicates an item in the Faces list which in
                % turn maps to a vertex
                
                numPoints = numel(faces);
                if index>0 && index<=numPoints
                    % The index into faces is row-major, not the normal
                    % column-major that Matlab uses.  This ensures that the
                    % next index is the next vertex in that face
                    faces = faces.';
                    faceIndex = faces(index);
                    if ~isnan(faceIndex)
                        pos = verts(faceIndex,:);
                        if numel(pos)==2
                            pos(3) = 0;
                        end

                        pos = matlab.graphics.shape.internal.util.SimplePoint(pos);
                    end
                end
            end

            
            if isempty(pos)
                % Construction of default value is deferred to save time if
                % it isn't needed
                pos = matlab.graphics.shape.internal.util.SimplePoint([NaN NaN NaN]);
            end
        end
        
        function pos = getReportedPosition(hPatch, index, interpolationFactor)
            % Returns the position that should be reported back to the user
            % for the given index and interpolation factor.
            
            pos = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getDisplayAnchorPoint(hPatch,index,interpolationFactor);
            if isempty(hPatch.ZData)
                pos.Is2D = true;
            end
        end
    end
end


function [index, interp] = localGetNearestVertex(hPatch, position)
% Find the nearest point index and provide an interpolation structure if a 
% face is hit.

pickUtils = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

verts = hPatch.Vertices;
faces = hPatch.Faces;

interp = [];

if strcmp(hPatch.FaceColor,'none') ...
        && (strcmp(hPatch.LineStyle,'none') || strcmp(hPatch.EdgeColor, 'none'))
    
    index = localPointCloudNearest(pickUtils, hPatch, position);

else
    NeedInterp = (nargout>1);
    
    % The faces are visible, even if they are only really a mesh
    [vertIndex, faceIndex, interp] = localPickNearest(pickUtils, hPatch, position, faces, verts, NeedInterp);
    
    
    if ~isempty(faceIndex)
        % Map the vertex index into a row-major index in the selected face
        faceOffsetIndex = find(faces(faceIndex,:)==vertIndex, 1);
        index = (faceIndex-1)*size(faces,2) + faceOffsetIndex;
        
    elseif ~isempty(vertIndex)
        % Look in all available faces for this vertex and assume it is that
        % face.
        index = find((faces==vertIndex).', 1);
    else
        % There was no vertex selected due no valid face data.  This can
        % happen if all faces have a non-finite vertex.  Fall back on
        % treating the data as a point cloud.
        index = localPointCloudNearest(pickUtils, hPatch, position);
    end
    
    if NeedInterp && isempty(interp) ...
            && ~isempty(faceIndex) ...
            && size(verts,2)==2
        % The hit face is likely not a trivial triangle.  In general, in order to
        % place a datatip at a place that visually matches the surface, we
        % need to know the triangulation used to draw it, and we do not
        % know that.  However if the vertices are only two-dimensional then
        % we know that it will have been triangulated in the X-Y plane, and
        % even if we don't generate the same triangulation it won't matter
        % because there is no Z value to get wrong.
        
        thisFace = faces(faceIndex,:);
        
        % Trim down to non-NaN vertex indices
        firstNaN = find(isnan(thisFace), 1);
        if ~isempty(firstNaN)
            thisFace = thisFace(1:firstNaN-1);
        end
        
        if ~isempty(thisFace)
            % Perform a simple triangulation in the XY plane.
            faceVerts = verts(thisFace,:);
            numVerts = numel(thisFace);
            constraints = [1:numVerts; 2:numVerts 1].';
            
            ws = warning('off', 'MATLAB:delaunayTriangulation:ConsConsSplitWarnId');
            warnCleaner = onCleanup(@() warning(ws));
            tri = delaunayTriangulation(faceVerts(:,1:2), constraints);
            subFaces = tri.ConnectivityList(tri.isInterior(),:);
            
            if size(tri.Points, 1)==numVerts
                % The triangulation was successful and did not
                % introduce cuts that we cannot handle.
                [~, ~, interp] = localPickNearest(pickUtils, hPatch, position, subFaces, faceVerts, NeedInterp);
                
                % Override the triangle indices to point at the indices in
                % the full face
                interp.FaceTriIndices = subFaces(interp.FaceIndex,:);
                
                % Override the interpolated face to point at the right one
                interp.FaceIndex = faceIndex;
            end
        end
    end
end

if isempty(index)
    % Default to picking the first point
    index = 1;
end

end


function index = localPointCloudNearest(pickUtils, hPatch, position)
% Execute a hit test assuming that the patch contains a cloud of points -
% no faces or edges

verts = hPatch.Vertices;
faces = hPatch.Faces;

% Only markers are visible - treat the data as a point cloud
% with no interpolation allowed.  However we want to make sure that we
% only pick from the visible verts, i.e. ones that are used in a face

usedVertList = faces(~isnan(faces));
unusedVerts = true(size(verts,1),1);
unusedVerts(usedVertList(:)) = false;
if any(unusedVerts)
    verts(unusedVerts,:) = NaN;
end
vertIndex = pickUtils.nearestPoint(hPatch, position, true, verts);

% Map index into an appropriate face location
index = find((faces==vertIndex).', 1);
end


function [vertIndex, faceIndex, interp] = localPickNearest(pickUtils, hPatch, position, faces, verts, NeedInterp)
% Execute a hit test and convert the result into an interpolation structure
[vertIndex, faceIndex, intFactors] = pickUtils.nearestFacePoint(hPatch, position, true, faces, verts);

if NeedInterp && ~isempty(intFactors)
    intPoint = localCreateIntPoint(faces, verts, faceIndex, intFactors);
    
    interp = struct('FaceIndex', faceIndex, ...
        'FaceTriIndices', [1 2 3], ...
        'InterpFactors', intFactors, ...
        'pout', intPoint);
else
    interp = [];
end

end


function intPoint = localCreateIntPoint(faces, verts, faceIndex, intFactors)
v = verts(faces(faceIndex,:), :);
vect1 = v(2,:)-v(1,:);
vect2 = v(3,:)-v(1,:);
intPoint = v(1,:) + intFactors(1)*vect1 + intFactors(2)*vect2;

if numel(intPoint)==2
    intPoint(3) = 0;
end
end


function ret = localIsCurrentInterpolated(interpolationFactor)
% Test whether the interpolation factor value contains the fields required
% for the current interpolation, and has non-zero interp factors.
ret = isstruct(interpolationFactor) && ...
    all(isfield(interpolationFactor, {'FaceIndex', 'FaceTriIndices', 'InterpFactors'})) && ...
    ~all(interpolationFactor.InterpFactors==0);
end


function ret = localIsOldInterpolated(interpolationFactor)
% Test whether the interpolation factor value contains the old field that
% contains an already-interpolated position.
ret = isstruct(interpolationFactor) && ...
    isfield(interpolationFactor, 'pout') && ...
    ~isempty(interpolationFactor.pout);
end

function pos = localCreatePlanePoint(faces, verts, interpolationFactor)
% Parameterize the current point in terms of 3 points of
% the face. This parameterization is done at the point of
% picking: here we just find the correct current vertex
% values to apply it to.

pos = [];

faceIndex = interpolationFactor.FaceIndex;
vertsPerFace = size(faces,2);

if faceIndex>0 && faceIndex<=numel(faces) ...
        && all(interpolationFactor.FaceTriIndices<=vertsPerFace)
    
    thisFace = faces(faceIndex,:);
    triVerts = thisFace(interpolationFactor.FaceTriIndices);
    
    if ~any(isnan(triVerts))
        faceVerts = verts(triVerts,:);
        if size(faceVerts,2)==2
            faceVerts(:,3) = 0;
        end

        pos = matlab.graphics.shape.internal.util.PlanePoint(...
            faceVerts(1,:), ...
            faceVerts(2,:), interpolationFactor.InterpFactors(1), ...
            faceVerts(3,:), interpolationFactor.InterpFactors(2));
    end
end
end
