classdef DragToRearrange < matlab.graphics.interaction.uiaxes.Drag
    
    %   Copyright 2017-2018 The MathWorks, Inc.
    
    events (NotifyAccess = private)
        DragStarted
        DragComplete
    end
    
    properties
        HeatmapChart
        Highlight
    end
    
    properties (Transient, NonCopyable, Hidden, Access = ?ChartUnitTestFriend)
        DragGap
        DragHeatmap
    end
    
    methods
        function hDrag = DragToRearrange(hChart, hHighlight)
            hFigure = ancestor(hChart, 'figure');
            hDrag = hDrag@matlab.graphics.interaction.uiaxes.Drag(hFigure, ...
                'WindowMousePress', 'WindowMouseMotion', 'WindowMouseRelease');
            hHeatmap = hChart.Heatmap;
            
            % Create a draggable gap to cover the row/column being moved.
            hGap = matlab.graphics.primitive.Rectangle;
            hGap.Description = 'Drag Gap';
            hGap.EdgeColor = hHeatmap.LineColor;
            hGap.LineWidth = hHeatmap.LineWidth;
            hGap.AlignVertexCenters = 'on';
            hGap.FaceColor = [0.94 0.94 0.94];
            hGap.PickableParts = 'none';
            hGap.HitTest = 'off';
            hGap.Internal = true;
            hDrag.DragGap = hGap;
            
            % Create a draggable heatmap to represent the row/column being
            % moved.
            hHeatmap = matlab.graphics.chart.primitive.Heatmap;
            hHeatmap.Description = 'Drag Heatmap';
            hHeatmap.PickableParts = 'none';
            hHeatmap.HitTest = 'off';
            hHeatmap.Internal = true;
            hDrag.DragHeatmap = hHeatmap;
            
            hDrag.HeatmapChart = hChart;
            if nargin >= 2
                hDrag.Highlight = hHighlight;
            end
            hDrag.enable();
        end
    end
    
    methods (Access = protected)
        function tf = validate(hDrag, ~, eventData)
            % Get the object that was hit.
            hitObject = eventData.HitObject;
            
            if any(hitObject == hDrag.Highlight) && hDrag.HeatmapChart.EnableInteractions
                % Make sure the click occurred outside the axes, over one of
                % the two rulers.
                point = eventData.IntersectionPoint(1,1:2);
                [xr, yr] = matlab.graphics.internal.getRulersForChild(hitObject);
                xl = xr.NumericLimits;
                yl = yr.NumericLimits;
                
                outsideX = point(1) <= xl(1) || point(1) >= xl(2);
                outsideY = point(2) <= yl(1) || point(2) >= yl(2);
                tf = xor(outsideX, outsideY);
            else
                % You can only drag the highlight tick labels.
                tf = false;
            end
        end
        
        function customEventData = start(hDrag, ~, eventData)
            % Get a handle to the heatmap chart.
            hChart = hDrag.HeatmapChart;
            hFigure = ancestor(hChart,'figure');
            
            % Determine which ruler was hit.
            hitObject = eventData.HitObject;
            point = eventData.IntersectionPoint(1,1:2);
            [xr, yr] = matlab.graphics.internal.getRulersForChild(hitObject);
            xl = xr.NumericLimits;
            yl = yr.NumericLimits;
            
            if point(2) <= yl(1) || point(2) >= yl(2)
                % Hit the x-ruler.
                dimLetter = 'X';
                dimNumber = 1;
                limits = xl;
            elseif point(1) <= xl(1) || point(1) >= xl(2)
                % Hit the y-ruler.
                dimLetter = 'Y';
                dimNumber = 2;
                limits = yl;
            end
            
            % Collect data needed for the rearrange operation.
            index = round(hitObject.Position(dimNumber));
            dataProp = [dimLetter 'DisplayData'];
            itemBeingMoved = hChart.(dataProp)(index);
            hideLabelProp = ['Hide' dimLetter 'DisplayLabels'];
            limitsPadding = hitObject.Size/2;
            limits = limits + [limitsPadding -limitsPadding];
            
            % Cache information about the axes layout.
            rotationModeProp = [dimLetter 'TickLabelRotationMode'];
            axesLabelProp = [dimLetter 'Label'];
            hAxesLabel = hChart.Axes.(axesLabelProp);
            activePositionProperty = char(hChart.ActivePositionProperty);
            activePositionProperty = strrep(activePositionProperty, 'position','Position');
            activePositionProperty(1) = upper(activePositionProperty(1));
            
            % Prepare custom event data.
            customEventData.Object = hitObject;
            customEventData.Dimension = dimNumber;
            customEventData.StartIndex = index;
            customEventData.NumericLimits = limits;
            customEventData.ItemBeingMoved = itemBeingMoved;
            customEventData.HideLabelProp = hideLabelProp;
            customEventData.ActivePositionProperty = activePositionProperty;
            customEventData.Position = hChart.(activePositionProperty);
            customEventData.AxesLabelHandle = hAxesLabel;
            customEventData.TickRotationModeProperty = rotationModeProp;
            customEventData.OldPointer.Name = hFigure.Pointer;
            customEventData.OldPointer.CData = hFigure.PointerShapeCData;
            customEventData.OldPointer.HotSpot = hFigure.PointerShapeHotSpot;
            
            % Blank the labels of the heatmap. Set ActivePositionProperty
            % to innerposition, label PositionMode to manual, and tick
            % label rotation mode to manual, so that hiding labels doesn't
            % cause the layout to change.
            hChart.Axes.(rotationModeProp) = 'manual';
            hAxesLabel.PositionMode = 'manual';
            hChart.ActivePositionProperty = 'innerposition';
            hChart.(hideLabelProp) = itemBeingMoved;
            
            % Add drag handles to the scene.
            hDrag.showDragHandles(dimLetter, index);
            
            % Update the cursor to show the closed hand.
            setptr(hFigure, 'closedhand');
            
            % Collect the event data.
            dragEventData = matlab.graphics.chart.internal.heatmap.DragToRearrangeEventData;
            dragEventData.Axis = dimLetter;
            dragEventData.Item = itemBeingMoved;
            dragEventData.StartIndex = index;
            dragEventData.EndIndex = index;
            dragEventData.DragOccurred = false;
            dragEventData.HitObject = hitObject;
            
            % Notify listeners that the drag is starting.
            notify(hDrag, 'DragStarted', dragEventData)
        end
        
        function move(hDrag, ~, eventData, customEventData)
            import matlab.graphics.interaction.internal.calculateIntersectionPoint
            
            % Determine which axes was hit.
            hChart = hDrag.HeatmapChart;
            hitAxes = ancestor(eventData.HitPrimitive, 'matlab.graphics.axis.AbstractAxes', 'node');
            
            % Get the current intersection point. Once the drag has
            % started, allow the cursor to move outside the bounds of the
            % axes. To do this, the intersection point will need to be
            % calculated relative to the axes.
            point = eventData.IntersectionPoint;
            if isempty(hitAxes) || hitAxes ~= hChart.Axes || all(isnan(point))
                point = calculateIntersectionPoint(eventData.PointInPixels, hChart.Axes);
            end
            
            % Determine the new location.
            dim = customEventData.Dimension;
            position = point(dim);
            
            if isfinite(position)
                % Constrain the new location to the limits.
                limits = customEventData.NumericLimits;
                position = max(limits(1), min(limits(2), position));
                
                % Update the location of the tick label.
                hitObject = customEventData.Object;
                hitObject.Position(dim) = position;
                
                % Update the order of the items.
                endIndex = round(position);
                itemBeingMoved = customEventData.ItemBeingMoved;
                hChart.moveDisplayData(char('W'+dim), itemBeingMoved, endIndex);
                
                % Update the location of the drag handles.
                hDrag.moveDragHandles(dim, position);
            end
        end
        
        function stop(hDrag, ~, eventData, customEventData)
            % Lock the highlight to the nearest category.
            hitObject = customEventData.Object;
            dim = customEventData.Dimension;
            index = round(hitObject.Position(dim));
            hitObject.Position(dim) = index;
            
            % Finish drag and clean up drag related artifacts.
            hDrag.stopOrCancel(eventData, customEventData, index);
        end
        
        function cancel(hDrag, ~, eventData, customEventData)
            % Move highlight back to the starting category.
            hitObject = customEventData.Object;
            dim = customEventData.Dimension;
            index = customEventData.StartIndex;
            hitObject.Position(dim) = index;
            
            % Restore the original ordering of the categories.
            hChart = hDrag.HeatmapChart;
            itemBeingMoved = customEventData.ItemBeingMoved;
            hChart.moveDisplayData(char('W'+dim), itemBeingMoved, index);
            
            % Finish drag and clean up drag related artifacts.
            hDrag.stopOrCancel(eventData, customEventData, index);
        end
    end
    
    methods (Access = protected)
        function stopOrCancel(hDrag, eventData, customEventData, index)
            % Hide drag handles.
            hDrag.hideDragHandles();
            
            % Restore the label of the heatmap.
            hChart = hDrag.HeatmapChart;
            hChart.(customEventData.HideLabelProp) = {};
            
            % Restore the layout of the heatmap.
            activePositionProperty = customEventData.ActivePositionProperty;
            hAxesLabel = customEventData.AxesLabelHandle;
            rotationModeProp = customEventData.TickRotationModeProperty;
            hChart.(activePositionProperty) = customEventData.Position;
            hChart.Axes.(rotationModeProp) = 'auto';
            hAxesLabel.PositionMode = 'auto';
            
            % Collect the event data.
            dim = customEventData.Dimension;
            dragEventData = matlab.graphics.chart.internal.heatmap.DragToRearrangeEventData;
            dragEventData.Axis = char('W'+dim);
            dragEventData.Item = customEventData.ItemBeingMoved;
            dragEventData.StartIndex = customEventData.StartIndex;
            dragEventData.EndIndex = index;
            dragEventData.DragOccurred = customEventData.StartIndex ~= index;
            dragEventData.HitObject = eventData.HitObject;
            
            % Restore the original pointer.
            hFigure = ancestor(hChart,'figure');
            hFigure.Pointer = customEventData.OldPointer.Name;
            hFigure.PointerShapeCData = customEventData.OldPointer.CData;
            hFigure.PointerShapeHotSpot = customEventData.OldPointer.HotSpot;
            
            % Notify listeners that the drag is finished.
            notify(hDrag, 'DragComplete', dragEventData)
        end
        
        function showDragHandles(hDrag, dim, index)
            hChart = hDrag.HeatmapChart;
            hHighlight = hDrag.Highlight;
            
            hGap = hDrag.DragGap;
            hHeatmap = hDrag.DragHeatmap;
            
            switch dim
                case 'X'
                    position = [index 1];
                    colorData = hChart.ColorDisplayData(:,index);
                case 'Y'
                    position = [1 index];
                    colorData = hChart.ColorDisplayData(index,:);
            end
            
            hDrag.syncHeatmapProperties(hChart.Heatmap, hHeatmap)
            hHeatmap.ColorData = colorData;
            
            hGap.Position([1 2]) = round(position)-0.5;
            hGap.Position([4 3]) = size(colorData);
            hHeatmap.Position([1 2]) = position;
            
            hGap.Parent = hHighlight.DragHandles;
            hHeatmap.Parent = hHighlight.DragHandles;
        end
        
        function moveDragHandles(hDrag, dim, position)
            hDrag.DragGap.Position(dim) = round(position)-0.5;
            hDrag.DragHeatmap.Position(dim) = position;
        end
        
        function hideDragHandles(hDrag)
            hDrag.DragGap.Parent = [];
            hDrag.DragHeatmap.Parent = [];
        end
    end
    
    methods (Hidden)
        function hObj = saveobj(hObj) %#ok<MANU>
            % Do not allow users to save this object.
            error(message('MATLAB:Chart:SavingDisabled', ...
                'matlab.graphics.chart.internal.heatmap.DragToRearrange'));
        end
    end
    
    methods (Static)
        function syncHeatmapProperties(hFrom, hTo)
            % Sync heatmap properties from the chart to the drag heatmap.
            
            % Copy the visual design properties.
            properties = { ...
                'FontName','FontAngle','FontWeight','MinimumFontSize', ...
                'CellMargin','CellLabelFormat','CellLabelColor', ...
                'GridVisible','GridLineStyle','LineColor','LineWidth', ...
                'ColorScaling','MissingDataLabel', 'MissingDataColor'};
            set(hTo, properties, get(hFrom, properties));
            
            % Set the FontSize to match the ActualFontSize so that the drag
            % heatmap has the same font size as the actual heatmap.
            actualFontSize = hFrom.ActualFontSize;
            if actualFontSize > 0
                hTo.FontSize = actualFontSize;
            else
                hTo.CellLabelColor = 'none';
            end
        end
    end
end
