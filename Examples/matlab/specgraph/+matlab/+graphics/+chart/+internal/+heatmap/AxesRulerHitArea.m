classdef AxesRulerHitArea < matlab.graphics.primitive.world.Group
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Transient, NonCopyable, Hidden, Access = ?ChartUnitTestFriend)
        HitArea matlab.graphics.primitive.world.TriangleStrip
    end
    
    methods
        function hObj = AxesRulerHitArea(varargin)
            % Create the hit area.
            hitArea = matlab.graphics.primitive.world.TriangleStrip;
            hitArea.Description = 'Axes Ruler Hit Area';
            hitArea.Internal = true;
            hitArea.PickableParts = 'all'; % Capture all clicks
            hitArea.HitTest = 'off'; % Forward clicks to parent
            hitArea.Clipping = 'off';
            hObj.HitArea = hitArea;
            hObj.addNode(hitArea);
            
            % Add dependency on the colormap
            hObj.addDependencyConsumed({'ref_frame','view', ...
                'dataspace', 'hgtransform_under_dataspace', ...
                'xyzdatalimits', 'resolution'});
            
            % Process Name/Value pairs
            matlab.graphics.chart.internal.ctorHelper(hObj, varargin);
        end
        
        function doUpdate(hObj, updateState)
            % Find the axes and layout of the axes.
            hAx = ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
            info = hAx.GetLayoutInformation;
            
            % Determine the vertices of a bounding box that includes the
            % region between the plot box and the decorated plot box.
            %
            %    3-----------7
            %    |           |
            % 1--4-----------8--11
            % |  |           |  |
            % |  |           |  |
            % |  |           |  |
            % 2--5-----------9--12
            %    |           |
            %    6-----------10
            pb = info.PlotBox;
            dpb = info.DecoratedPlotBox;
            xs = [dpb(1) pb(1) pb(1)+pb(3) dpb(1)+dpb(3)];
            ys = [dpb(2) pb(2) pb(2)+pb(4) dpb(2)+dpb(4)];
            cornersPixels = [...
                xs([1 1 2 2 2 2 3 3 3 3 4 4]);
                ys([2 3 1 2 3 4 1 2 3 4 2 3])];
            
            % Convert the corners from pixels to world coordinate space.
            aboveMatrix = updateState.TransformAboveDataSpace;
            belowMatrix = updateState.TransformUnderDataSpace;
            cornersWorld = matlab.graphics.internal.transformViewerToWorld(...
                updateState.Camera, aboveMatrix, updateState.DataSpace, ...
                belowMatrix, cornersPixels);
            
            % Set the vertex data, vertex indices, and strip data.
            hitArea = hObj.HitArea;
            hitArea.VertexData = single(cornersWorld);
            hitArea.VertexIndices = uint32([1 2 4 5 5 6 9 10 3 4 7 8 8 9 11 12]);
            hitArea.StripData = uint32(1:4:17);
            hgfilter('RGBAColorToGeometryPrimitive', hitArea, 'none');
        end
        
        function hObj = saveobj(hObj) %#ok<MANU>
            % Do not allow users to save this object.
            error(message('MATLAB:Chart:SavingDisabled', ...
                'matlab.graphics.chart.internal.heatmap.AxesRulerHitArea'));
        end
    end
end
