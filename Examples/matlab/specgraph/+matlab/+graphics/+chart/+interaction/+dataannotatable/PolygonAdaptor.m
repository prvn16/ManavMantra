classdef (Sealed)PolygonAdaptor < matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor
    % A helper class to support Data Cursors on Polygon objects.
    % The Polygon Datatip Model works with the effective manipulation of the
    % Polygon vertex Data.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(Access=private, Transient)
        PolygonDataListener;
    end
    
    methods
        function hObj = PolygonAdaptor(hPoly)
            hObj@matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor(hPoly);
        end
    end
    
    methods(Access=protected)
        function doSetAnnotationTarget(hObj, hTarget)
            % Enforce that the target is a polygon object
            if ~isa(hTarget,'matlab.graphics.primitive.Polygon')
                error(message('MATLAB:specgraph:chartMixin:dataannotatable:PolygonAdaptor:InvalidPolygon'));
            end
            
            % Add a listener to the Polygon Shape data to fire the DataChanged event
            hObj.PolygonDataListener = event.proplistener(hTarget, ...
                hTarget.findprop('Shape'),'PostSet',@(obj,evd)(hObj.sendDataChangedEvent));
        end
    end
    
    
    
    % Implementation of the DataAnnotatable interface methods.
    methods(Access='protected', Hidden=true)
        
        function [index, interpolationFactor] = doIncrementIndex(hObj, index, direction, interpolation_Factor)
            % Get next valid index in the data : skip NaNs and Infs based
            % on the direction of the movement (up,right,left dowm)
            
            % we dont change the interpolation factor here, just passing through
            poly = hObj.AnnotationTarget;
            interpolationFactor = interpolation_Factor;
            nextIndex = index;
            
            [xd, yd] = localGetVertexData(poly);
            indToAllow = isfinite(xd) & isfinite(yd);
            
            if strcmpi(direction,'up') || strcmpi(direction,'right')
                nextIndex = doGetNearestIndex(hObj, nextIndex + 1);
                
                % Since the boundary start point and boundary end point are
                % the same, we do not want to loop over the same point
                % twice. Hence, we skip the boundary end point.
                if isnan(poly.Shape.Vertices(nextIndex))
                    nextIndex = nextIndex+1;
                end
                
                if ~indToAllow(nextIndex)
                    nextIndex = nextIndex + find(indToAllow((nextIndex+1):end), 1, 'first');
                end
                
            elseif strcmpi(direction,'down') || strcmpi(direction,'left')
                nextIndex = doGetNearestIndex(hObj, nextIndex - 1);
                
                if isnan(poly.Shape.Vertices(nextIndex))
                    nextIndex = nextIndex - 1;
                end
                
                if ~indToAllow(nextIndex)
                    nextIndex = find(indToAllow(1:nextIndex), 1, 'last');
                end
            end
            
            if ~isempty(nextIndex)
                index = nextIndex;
            end
        end
        
        function varargout = doGetDataDescriptors(hObj, index, interpolationFactor)
            % Get the data descriptors for an object given the index and
            % interpolation factor.
            poly = hObj.AnnotationTarget;
            % We will use the reported position.
            if ~isnan(poly.Shape.Vertices(index))
                ReportedPos = doGetReportedPosition(hObj,index,interpolationFactor);
                pos = ReportedPos.getLocation(poly);
            else
                pos = matlab.graphics.shape.internal.util.SimplePoint([NaN NaN NaN]);
            end
            % The data descriptors will correspond to X, Y.
            varargout{1} = matlab.graphics.chart.interaction.dataannotatable.internal.createPositionDescriptors(poly,pos);
        end
        
        function index = doGetNearestIndex(hObj, index)
            % Return the nearest index to the requested input.
            
            % If the index is in range, we will return the index.
            [~,~,numPoints] = localGetVertexData(hObj.AnnotationTarget);
            
            % Constrain index to be in the range [1 numPoints]
            if numPoints>0
                index = max(1, min(index, numPoints));
            end
        end
        
        function index = doGetNearestPoint(hObj, position)
            % Returns the index representing the point on the polygon nearest
            % to a pixel position in the figure.
            
            index = localGetNearestVertex(hObj.AnnotationTarget, position);
        end
        
        function [index, interpolationFactor] = doGetInterpolatedPoint(hObj, position)
            % Returns the index and interpolation factor representing the
            % point on the object nearest to a pixel position in the figure.
            
            [index, ~, interpolationFactor] = localGetNearestEdgeVertex(hObj.AnnotationTarget, position);
        end
        
        function varargout = doGetDisplayAnchorPoint(hObj, index, interpolationFactor)
            % Returns the position that should be used to overlay views on
            % the object for the given index and interpolation factor.
            % Similar to Line Object
            poly = hObj.AnnotationTarget;
            if ~isnan(poly.Shape.Vertices(index))
                varargout{1} = matlab.graphics.shape.internal.util.LinePoint(...
                    localGetPoint(poly, index), ...
                    localGetPoint(poly, index+1), ...
                    interpolationFactor);
            else
                varargout{1} = matlab.graphics.shape.internal.util.SimplePoint([NaN NaN NaN]);
            end
        end
        
        function varargout = doGetReportedPosition(hObj, index, interpolationFactor)
            % Returns the position that should be reported back to the user
            % for the given index and interpolation factor.
            
            varargout{1} = doGetDisplayAnchorPoint(hObj, index, interpolationFactor);
            varargout{1}.Is2D = true;
        end
    end
    
end


%-------------------------------------------------------------------------%
function index = localGetNearestVertex(hObj, position)
% Treat data as scattered points and just look for the closest vertex

[xData, yData, ~] = localGetVertexData(hObj);

utils = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

index = utils.nearestPoint(hObj, position, true, xData, yData);
end

%-------------------------------------------------------------------------%
function [index, index2, interpolationFactor] = localGetNearestEdgeVertex(hObj, position)
% Find the nearest vertex and provide an interpolation structure if a
% point on an edge is hit.

pickUtils = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

[xData, yData, numPoints] = localGetVertexData(hObj);

% Treat data as a sequence of line segments and pick the
% closest segment
[index, index2, interpolationFactor] = pickUtils.nearestSegment(hObj, position, true, xData, yData);

% In order to make sure that the Annotatable interface sees n edges for n vertices,
% we lie that there is an edge between different boundaries.
% To make sure that we are not interpolating in the region between the
% boundaries, we check to see if the original data at given index is NaN and if
% so, we pick the nearest vertex with interp as 0.
if 1 <= index && index <= numPoints
    if isnan(hObj.Shape.Vertices(index))
        interpolationFactor = 0;
        index = localGetNearestVertex(hObj, position);
    end
end

end

%-------------------------------------------------------------------------%
function [xData, yData, dataSize] = localGetVertexData(hObj)
% Consider a polygon with 2 boundaries with the following actual vertices:
% Actual Vertices              Derived Vertices
% ---------------              ----------------
% Index   X     Y              Index   X     Y
% [1]     1     1              [1]     1     1
% [2]     1    10              [2]     1    10
% [3]    10    10              [3]    10    10
% [4]    10     1              [4]    10     1
% [5]   NaN   NaN              [5]     1     1
% [6]     3     3              [6]     3     3
% [7]     6     3              [7]     6     3
% [8]     6     6              [8]     6     6
% [9]     3     6              [9]     3     6
%                              [10]    3     3
% To make sure that clicking anywhere between the boundary start
% point and the boundary end point, the datatip snaps to the right point -
% we transform the vertices so that the NaNs are replaced by the
% start point of the boundary and the boundary end point is listed at the end.
% Hence, the derived vertices would be as listed above. This makes all the
% boundary vertices to be data-tipped.

% Get the xData and yData
Vertices = hObj.Shape.Vertices;

% Derived vertices calculations - Has no NaNs
% Terminate the final boundary
Vertices(end+1,:) = [NaN NaN];

NaNIndices = isnan(Vertices(:,1));
ReplaceIndices = [true; NaNIndices(1:end-1)];
Vertices(NaNIndices,:) = Vertices(ReplaceIndices,:);

xData = Vertices(:,1);
yData = Vertices(:,2);
% The Derived vertices inlcudes an additional vertex at the end which is the
% boundary end point. Excluding it for the data size.
dataSize = numel(xData) - 1;
end

%-------------------------------------------------------------------------%
function pt = localGetPoint(hObj, index)
% Get the (x,y,z) values of a point on the line

pt = [0 0 0];
[xd,yd] = localGetVertexData(hObj);

pt(1) = localIndexData(xd, index);
pt(2) = localIndexData(yd, index);

end

%-------------------------------------------------------------------------%
function val = localIndexData(data, index)
%Index into a vector if the index is valid, return NaN otherwise.

if index>0 && index<=numel(data)
    val = data(index);
else
    val = NaN;
end
end
