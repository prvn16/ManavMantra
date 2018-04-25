classdef Polygon < images.internal.drawingTools.ROI
    
    % Copyright 2017, The Mathworks Inc.
    
    events
        VertexAdded
        VertexBeingAdded
        VertexRemoved
        VertexBeingRemoved
    end
    
    properties(Dependent)
        Closed
        Draggable
        LineWidth
        Position
        StripesVisible
        StripeColor
        VerticesDraggable
        Visible
    end
    
    properties(GetAccess = public, SetAccess = protected)
        CopiedData
        Valid
    end
    
    properties(Dependent, Hidden)
        MinimumNumberOfPoints
    end
    
    properties(Access = protected)
        
        ClosedInternal = true;
        VerticesDraggableInternal = true;
        MinimumNumberOfPointsInternal = 2;
        
        VertexContextMenu
        
    end
    
    methods
        
        function self = Polygon(varargin)
            self@images.internal.drawingTools.ROI(varargin{:});
        end
        
        %--Create Mask-----------------------------------------------------
        function BW = createMask(self,m,n)
            % Creates a binary mask size [m,n] with true values inside
            % polygon
            BW = poly2mask(self.PositionInternal(:,1),self.PositionInternal(:,2),m,n);
        end
        
        %--Inside ROI------------------------------------------------------
        function in = insideROI(self,x,y)
            % Returns logical array indicating if data points with
            % coordinates (x,y) is inside polygon. Use this method for
            % scattered data. To obtain a gridded mask, use createMask
            in = images.internal.inpoly(x,y,self.PositionInternal(:,1),self.PositionInternal(:,2));
        end
        
    end
    
    methods(Access = protected)
        
        function wireUpListeners(self)
            
            % If figure has any uimode already selected, remove it
            if ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode = [];
            end
            
            delete(self.ButtonStartEvt);
            
            % Set callback for mouse button down
            self.ButtonDownEvt = event.listener(self.FigureHandle,...
                'WindowMousePress',@(src,evt) onAxesClick(self,src,evt));
            
            self.setEmptyCallbackHandle();
            
            self.ButtonMotionEvt = event.listener(self.FigureHandle,...
                'WindowMouseMotion',@(~,~) animateConnectionLine(self));
            
            % Set callback for key press
            self.KeyPressEvt = event.listener(self.FigureHandle,...
                'WindowKeyPress',@(src,evt) keyPressDuringPlacement(self,src,evt));
            
            % Create a listener for figure modes to handle built-in zoom,
            % pan, etc. gracefully
            self.FigureModeListener = event.proplistener(self.FigureHandle.ModeManager,self.FigureHandle.ModeManager.findprop('CurrentMode'),...
                'PostSet',@self.newFigureMode);
            
            % Immediately add vertex to start location
            setConstraintLimits(self);
            startLocation = getCurrentAxesPoint(self);
            [constrainedX, constrainedY] = self.getConstrainedPosition(startLocation(1), startLocation(2));
            self.addVertex(constrainedX, constrainedY);
            
        end
        
        function cMenu = getVertexContextMenu(self, pointHandle)
            cMenu = uicontextmenu(self.FigureHandle);
            uimenu(cMenu, 'Label', getString(message('images:roiContextMenuUIString:deleteVertexContextMenuLabel')),...
                'Callback', @(~, evt) deleteVertex(self, pointHandle), ...
                'Tag','contextDeleteVertex');
        end
        
        function cMenu = getContextMenu(self)
            if isempty(self.ContextMenu)
                cMenu = uicontextmenu(self.FigureHandle);
                uimenu(cMenu, 'Label', getString(message('images:roiContextMenuUIString:addVertexContextMenuLabel')),...
                    'Callback', @(~,~) onLineClickAddVertex(self),...
                    'Tag','contextAddPoint');
                uimenu(cMenu,'Label',getString(message('images:roiContextMenuUIString:deleteRoiLabel')), ...
                    'Callback', @(~,~)self.deleteROI, ...
                    'Tag','contextDeleteROI');
                self.ContextMenu = cMenu;
            end
            cMenu = self.ContextMenu;
        end
        
        function [newIndex, xLine, yLine] = insertVertex(self, mousePos)
            % Line vector: The vector from point one to point two for each
            % polygon line
            % Mouse vector: The vector from point one of each polygon line
            % to the mouse location where the user wants to add a vertex
            
            idx = (1:self.NumPoints)';
            
            pos = self.PositionInternal;
            deltaMousePos = mousePos - pos;
            mouseMag = sqrt(sum(deltaMousePos.^2,2));
            mouseUnitVec = deltaMousePos./mouseMag;
            
            pos(end+1,:) = pos(1,:);
            deltaLinePos = diff(pos,1,1);
            lineMag = sqrt(sum(deltaLinePos.^2,2));
            lineUnitVec = deltaLinePos./lineMag;
            
            % Remove lines from consideration that have a larger magnitude
            idx(mouseMag > lineMag) = [];
            
            % Degenerate case
            if isempty(idx)
                idx = 1;
            end
            
            % Dot product of mouse unit vector and line unit vector
            out = dot(mouseUnitVec,lineUnitVec,2);
            out = out(idx);
            
            [~,tempidx] = max(out);
            newIndex = idx(tempidx(1)) + 1;
            
            xLine = pos(newIndex-1:newIndex,1);
            yLine = pos(newIndex-1:newIndex,2);
            
        end
        
        function setPointerFcn(self)
            iptPointerManager(self.FigureHandle);
            pointerBehavior.enterFcn = @(~,~) linePointerEnterFcn(self);
            pointerBehavior.exitFcn = @(~,~) linePointerExitFcn(self);
            pointerBehavior.traverseFcn = [];
            iptSetPointerBehavior(self.LineHandle, pointerBehavior);
            iptSetPointerBehavior(self.CloseLineHandle, pointerBehavior);
            iptSetPointerBehavior(self.LabelHandle, pointerBehavior);
            
            pointerBehavior.enterFcn = @(~,~) verticesPointerEnterFcn(self);
            iptSetPointerBehavior(self.PointHandle,pointerBehavior);
        end
        
        function verticesPointerEnterFcn(self)
            try
                if self.VerticesDraggableInternal
                    set(self.FigureHandle,'Pointer','circle');
                    set(self.PointHandle, 'Marker', 'o');
                end
            catch
                % No-op
            end
        end
        
        function firstVertexPointerEnterFcn(self)
            try
                set(self.FigureHandle,'Pointer','circle');
            catch
                % No-op
            end
        end
        
        function linePointerEnterFcn(self)
            try
                if self.VerticesDraggableInternal
                    set(self.PointHandle, 'Marker', 'o');
                end
                if self.DraggableInternal
                    set(self.FigureHandle,'Pointer','fleur');
                end
            catch
                % No-op
            end
        end
        
        function linePointerExitFcn(self)
            try
                set(self.PointHandle, 'Marker', 'none')
            catch
                % No-op
            end
        end
        
        function cleanupGraphics(self)
            
            pointH = self.PointHandle;
            for inx=1:length(pointH)
                if ishandle(pointH(inx)) && isvalid(pointH(inx))
                    iptSetPointerBehavior(pointH(inx), []);
                    delete(pointH(inx));
                end
            end
            self.PointHandle = [];
            
            if isLineHandleValid(self)
                iptSetPointerBehavior(self.LineHandle, []);
                delete(self.LineHandle);
            end
            self.LineHandle = [];
            
            if isStripeLineHandleValid(self)
                delete(self.StripeLineHandle);
            end
            self.StripeLineHandle = [];
            
            if isStripeCloseLineHandleValid(self)
                delete(self.StripeCloseLineHandle);
            end
            self.StripeCloseLineHandle = [];
            
            if isCloseLineHandleValid(self)
                iptSetPointerBehavior(self.CloseLineHandle, []);
                delete(self.CloseLineHandle);
            end
            self.CloseLineHandle = [];
            
            if isLabelHandleValid(self)
                delete(self.LabelHandle);
            end
            self.LabelHandle = [];
        end
        
        function deleteVertex(self, hPoint)
            
            if ~self.Deletable
                return;
            end
            
            % Check if removing vertex will move polygon below the minimum
            % number of vertices required to be valid. If true, delete the
            % polygon
            if (self.NumPoints-1) < self.MinimumNumberOfPoints
                deleteROI(self);
                return;
            end
            
            % Delete requested vertex
            notify(self, 'VertexBeingRemoved');
            idx = self.PointHandle == hPoint;
            self.PositionInternal(idx, :) = [];
            self.PointHandle(idx) = [];
            delete(hPoint);
            self.NumPoints = self.NumPoints - 1;
            
            self.updateView();
            updateEnhancedIconPositions(self);
            notify(self, 'VertexRemoved');
        end
        
        function onLineClickAddVertex(self)
            clickPos = getCurrentAxesPoint(self);
            x = clickPos(1);
            y = clickPos(2);
            mouse_pos = [x, y];
            notify(self, 'VertexBeingAdded');
            [new_ind, x_line, y_line] = insertVertex(self, mouse_pos);
            insertPos = self.getPositionOnLine(x_line, y_line, mouse_pos);
            addVertex(self, insertPos(1), insertPos(2), new_ind);
            setPointerFcn(self);
            updateView(self);
            notify(self, 'VertexAdded');
        end
        
        function completed = onAxesClick(self,~,evt)
            hFig = self.FigureHandle;
            is_double_click = strcmp(get(hFig,'SelectionType'),'open');
            is_right_click  = strcmp(get(hFig,'SelectionType'),'alt');
            is_left_click = strcmp(get(hFig, 'SelectionType'), 'normal');
            
            if ~is_left_click && isempty(self.PositionInternal)
                completed = false;
                return
            end
            
            completed = is_double_click || is_right_click;
            
            if isa(evt.HitObject,'matlab.graphics.primitive.Line') && strcmp(evt.HitObject.Tag,'StartPoint')
                completed = true;
            end
            
            % Distinction between right click and other completion gestures is
            % that right click placement ends on buttonUp.
            if completed
                self.endInteractivePlacement();
            else
                setConstraintLimits(self);
                clickPos = getCurrentAxesPoint(self);
                [constrainedX, constrainedY] = self.getConstrainedPosition(clickPos(1), clickPos(2));
                addVertex(self, constrainedX, constrainedY);
            end
        end
        
        function addVertex(self, x, y, vertexNum)
            %Add a new vertex at the given x,y position and vertexIdx
            %position
            if nargin < 4
                %Append
                vertexNum = self.NumPoints + 1;
                self.PositionInternal(vertexNum, :) = [x, y];
            else
                %Insert
                xPos = self.PositionInternal(:,1);
                yPos = self.PositionInternal(:,2);
                xPos = [xPos(1:vertexNum-1) ; x; xPos(vertexNum:end)];
                yPos = [yPos(1:vertexNum-1) ; y; yPos(vertexNum:end)];
                self.PositionInternal = [xPos yPos];
            end
            self.NumPoints = self.NumPoints + 1;
            drawPoint(self, x, y, vertexNum);
        end
        
        function hPoint = drawPoint(self, x, y, vertexNum)
            hPoint = line(x, y, ...
                'Parent', self.AxesHandle, ...
                'Marker', 'o', ...
                'MarkerFaceColor', getColor(self) , ...
                'MarkerEdgeColor', getEdgeColor(self) , ...
                'Clipping', 'on', ...
                'MarkerSize', self.getCircleSize(), ...
                'Tag','circle', ...
                'Visible',self.VisibleInternal, ...
                'HandleVisibility','off', ...
                'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
            set(hPoint, 'UIContextMenu', self.getVertexContextMenu(hPoint));
            
            if self.VerticesDraggableInternal
                set(hPoint, 'ButtonDownFcn', @(src,~) startROIReshape(self,src));
            end
            
            if nargin < 4
                %Append
                self.PointHandle(end+1) = hPoint;
            else
                %Insert
                pointHandles = self.PointHandle;
                self.PointHandle = [pointHandles(1:vertexNum-1) hPoint pointHandles(vertexNum:end)];
                if (length(self.PointHandle) == 1) && self.UserIsDrawing
                    setCloseFcnForFirstPoint(self, x, y);
                end
            end
            
        end
        
        function animateConnectionLine(self)
            % Draw a line that connects the last placed vertex with the
            % current position of the mouse in the axes coordinate system.
            if ~isempty(self.PositionInternal)
                pos = get(self.AxesHandle, 'CurrentPoint');
                x = [self.PositionInternal(:, 1); pos(1, 1)];
                y  = [self.PositionInternal(:,2); pos(1, 2)];
                [lineH,~,stripeLineH,~] = getInteractiveLine(self);
                
                set(lineH, 'XData', x, 'YData', y);
                set(stripeLineH, 'XData', x, 'YData', y);
            end
        end
        
        function keyPressDuringPlacement(self,~,evt)
            % Discontinue interactive drawing for backspace, delete,
            % escape key presses
            abortDrawing = any(strcmp(evt.Key,{'backspace','delete','escape'}));
            
            if abortDrawing
                endInteractivePlacement(self);
                deleteROI(self);
            end
            
        end
        
        function setCloseFcnForFirstPoint(self,x,y)
            
            self.StartPoint = line(x, y, ...
                'Parent', self.TransparentOverlay, ...
                'Marker', 'o', ...
                'MarkerFaceColor', getColor(self) , ...
                'MarkerEdgeColor', getEdgeColor(self) , ...
                'Clipping', 'on', ...
                'MarkerSize', self.getCircleSize(), ...
                'Tag','StartPoint', ...
                'Visible',self.VisibleInternal, ...
                'HandleVisibility','off', ...
                'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
            
            iptSetPointerBehavior(self.StartPoint,@(~,~) firstVertexPointerEnterFcn(self));
            
        end
        
        function [lineH,closeLineH,stripeLineH,stripeCloseLineH] = getInteractiveLine(self)
            if isempty(self.LineHandle)
                
                self.LineHandle =  line('Parent', self.AxesHandle, ...
                    'Color', getColor(self), ...
                    'LineWidth', self.LineWidthInternal, ...
                    'Tag','lineROI', ...
                    'Visible',self.VisibleInternal, ...
                    'HandleVisibility','off', ...
                    'UIContextMenu', self.getContextMenu(), ...
                    'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
                
                if self.DraggableInternal
                    set(self.LineHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
                end
                
            end
            
            if isempty(self.StripeLineHandle)
                
                if self.StripesVisible && self.Visible
                    visline = 'on';
                else
                    visline = 'off';
                end
                
                self.StripeLineHandle =  line('Parent', self.AxesHandle, ...
                    'Color', self.StripeColor, ...
                    'LineStyle', '--', ...
                    'LineWidth', self.LineWidthInternal, ...
                    'Tag','stripeROI', ...
                    'Visible',visline, ...
                    'HandleVisibility','off', ...
                    'HitTest', 'off', ...
                    'PickableParts','none', ...
                    'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
                
            end
            
            lineH = self.LineHandle;
            stripeLineH = self.StripeLineHandle;
            
            if isempty(self.CloseLineHandle)
                
                self.CloseLineHandle =  line('Parent', self.AxesHandle, ...
                    'Color', getColor(self), ...
                    'LineWidth', self.LineWidthInternal, ...
                    'Tag','closeLineROI',...
                    'Visible','off', ...
                    'HandleVisibility','off', ...
                    'UIContextMenu', self.getContextMenu(), ...
                    'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
                
                if self.DraggableInternal
                    set(self.CloseLineHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
                end
                
            end
            
            if isempty(self.StripeCloseLineHandle)
                
                self.StripeCloseLineHandle =  line('Parent', self.AxesHandle, ...
                    'Color', self.StripeColor, ...
                    'LineStyle', '--', ...
                    'LineWidth', self.LineWidthInternal, ...
                    'Tag','stripeCloseROI',...
                    'Visible','off', ...
                    'HandleVisibility','off', ...
                    'HitTest', 'off', ...
                    'PickableParts','none', ...
                    'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
                
            end
            
            closeLineH = self.CloseLineHandle;
            stripeCloseLineH = self.StripeCloseLineHandle;
        end
        
        function updateView(self)
            %called once self.Position is set to offer a new line view
            if ~isempty(self.PositionInternal)
                [lineH,closeLineH,stripeLineH,stripeCloseLineH] = getInteractiveLine(self);
                X = self.PositionInternal(:, 1);
                Y = self.PositionInternal(:, 2);
                set(lineH, 'XData', X, 'YData', Y);
                set(closeLineH, 'XData', [X(1) X(end)], 'YData', [Y(1) Y(end)]);
                set(stripeLineH, 'XData', X, 'YData', Y);
                set(stripeCloseLineH, 'XData', [X(1) X(end)], 'YData', [Y(1) Y(end)]);
                
                if self.Closed && self.Visible && ~self.UserIsDrawing
                    visline = 'on';
                else
                    visline = 'off';
                end
                
                set(closeLineH,'Visible',visline);
                
                if self.StripesVisible && self.Closed && self.Visible && ~self.UserIsDrawing
                    visline = 'on';
                else
                    visline = 'off';
                end
                
                set(stripeCloseLineH,'Visible',visline);
                
            end
        end
        
        function reshapeROI(self, hPoint, startPoint)
            
            currentPoint = getCurrentAxesPoint(self);
            [newX, newY] = self.getConstrainedPosition(currentPoint(1), currentPoint(2));
            pos = [newX, newY];
            
            % Don't change if it is still at the old location
            if ~isequal(pos, startPoint)
                set(hPoint, 'XData', newX, 'YData', newY);
                self.PositionInternal(self.CurrentPointIdx, :) = pos;
                self.updateView();
                updateEnhancedIconPositions(self);
                notify(self, 'Moving');
            end
        end
        
        function startLineDrag(self)
            
            hFig = self.FigureHandle;
            if strcmp(get(hFig, 'SelectionType'), 'normal')
                % Set axes limits
                setConstraintLimits(self);
                self.CachedPosition = self.PositionInternal;
                
                % Disable the figure's pointer manager during the drag.
                iptPointerManager(hFig, 'disable');
                
                % Get the mouse location in data space.
                currentPoint = getCurrentAxesPoint(self);
                setDragBoundary(self,currentPoint);
                self.setEmptyCallbackHandle();
                
                self.DragMotionEvt = event.listener(self.FigureHandle,...
                    'WindowMouseMotion',@(~,~) dragLineMotion(self, currentPoint));
                
                self.DragButtonUpEvt = event.listener(self.FigureHandle,...
                    'WindowMouseRelease',@(~,~) stopDrag(self, currentPoint));
                
            elseif strcmp(get(hFig,'SelectionType'),'open')
                onLineClickAddVertex(self);
            end
            determineSelectionStatus(self);
        end
        
        function dragLineMotion(self, startPoint)
            currentPoint = getCurrentAxesPoint(self);
            
            if ~isequal(self.getConstrainedPosition(currentPoint(1), currentPoint(2)), startPoint)
                
                [newX, newY] = self.getConstrainedDragPosition(currentPoint(1), currentPoint(2));
                
                newPositions = self.CachedPosition + [newX, newY] - startPoint;
                self.PositionInternal = newPositions;
                
                for idx=1:length(newPositions)
                    set(self.PointHandle(idx), 'XData', newPositions(idx,1), 'YData', newPositions(idx,2));
                end
                self.updateView();
                updateEnhancedIconPositions(self);
                notify(self, 'Moving');
            end
        end
        
        function setDragBoundary(self,currentPoint)
            xMin = max(min(self.PositionInternal(:,1)) - self.PositionConstraint(1),0);
            xMax = max(self.PositionConstraint(2) - max(self.PositionInternal(:,1)),0);
            yMin = max(min(self.PositionInternal(:,2)) - self.PositionConstraint(3),0);
            yMax = max(self.PositionConstraint(4) - max(self.PositionInternal(:,2)),0);
            
            self.DragConstraint = [currentPoint(1) - xMin, currentPoint(1) + xMax,...
                currentPoint(2) - yMin, currentPoint(2) + yMax];
        end
        
        function doHighlight(self)
            color = getColor(self);
            [lineH,closeLineH,~,~] = getInteractiveLine(self);
            lineH.Color = color;
            closeLineH.Color = color;
            set(self.LabelHandle,'Color',getEdgeColor(self),'BackgroundColor',color);
            set(self.PointHandle, 'MarkerFaceColor', color, 'MarkerEdgeColor', getEdgeColor(self));
        end
        
    end
    
    methods
        % Set/Get methods
        
        %--Closed----------------------------------------------------------
        function set.Closed(self,TF)
            self.ClosedInternal = TF;
            if TF
                set(self.CloseLineHandle,'Visible','on');
            else
                set(self.CloseLineHandle,'Visible','off');
            end
        end
        
        function TF = get.Closed(self)
            TF = self.ClosedInternal;
        end
        
        
        
        %--Copied Data-----------------------------------------------------
        function copiedData = get.CopiedData(self)
            copiedData.Position = self.PositionInternal;
            copiedData.SemanticValue = self.SemanticValueInternal;
            copiedData.Label = self.LabelInternal;
            copiedData.Color = self.ColorInternal;
            copiedData.Closed = self.ClosedInternal;
            copiedData.UserData = self.UserDataInternal;
        end
        
        %--Draggable-------------------------------------------------------
        function set.Draggable(self,TF)
            self.DraggableInternal = TF;
            if TF
                set(self.LineHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
                set(self.CloseLineHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
                set(self.LabelHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
            else
                set(self.LineHandle, 'ButtonDownFcn', []);
                set(self.CloseLineHandle, 'ButtonDownFcn', []);
                set(self.LabelHandle, 'ButtonDownFcn', []);
                self.VerticesDraggable = TF;
            end
        end
        
        function TF = get.Draggable(self)
            TF = self.DraggableInternal;
        end
        
        %--Line Width------------------------------------------------------
        function set.LineWidth(self,val)
            assert(val > 0,'LineWidth must be positive scalar');
            
            set(self.LineHandle,'LineWidth',val);
            set(self.CloseLineHandle,'LineWidth',val);
            set(self.StripeLineHandle,'LineWidth',val);
            set(self.StripeCloseLineHandle,'LineWidth',val);
            
            self.LineWidthInternal = val;
            
        end
        
        function val = get.LineWidth(self)
            val = self.LineWidthInternal;
        end
        
        %--Stripe Color----------------------------------------------------
        function set.StripeColor(self, color)
            self.StripeColorInternal = color;
            [~,~,stripeLineH,stripeCloseLineH] = getInteractiveLine(self);
            stripeLineH.Color = color;
            stripeCloseLineH.Color = color;
        end
        
        function color = get.StripeColor(self)
            color = self.StripeColorInternal;
        end
        
        %--Stripes Visible-------------------------------------------------
        function set.StripesVisible(self, TF)
            if TF
                self.StripesVisibleInternal = 'on';
            else
                self.StripesVisibleInternal = 'off';
            end
            set(self.StripeCloseLineHandle,'Visible',self.StripesVisibleInternal);
            set(self.StripeLineHandle,'Visible',self.StripesVisibleInternal);
            
        end
        
        function TF = get.StripesVisible(self)
            if strcmp(self.StripesVisibleInternal,'on')
                TF = true;
            else
                TF = false;
            end
        end
        
        %--Minimum Number Of Points----------------------------------------
        function set.MinimumNumberOfPoints(self,val)
            if val >= 0
                self.MinimumNumberOfPointsInternal = round(val);
            end
        end
        
        function val = get.MinimumNumberOfPoints(self)
            val = self.MinimumNumberOfPointsInternal;
        end
        
        %--Position--------------------------------------------------------
        function set.Position(self,pos)
            assert(size(pos,2) == 2, 'n x 2 array of points is expected');
            
            cachedVisibility = self.Visible;
            self.Visible = false;
            
            %Reset existing state
            cleanupGraphics(self);
            self.NumPoints = 0;
            self.PositionInternal = [];
            
            numPoints = size(pos, 1);
            X = pos(:, 1);
            Y = pos(:, 2);
            for idx = 1:numPoints
                addVertex(self, X(idx), Y(idx));
            end
            set(self.PointHandle, 'Marker', 'none')
            updateView(self);
            setLabel(self);
            uistack(self.PointHandle,'top');
            setPointerFcn(self)
            
            self.Visible = cachedVisibility;
            
        end
        
        function pos = get.Position(self)
            pos = self.PositionInternal;
        end
        
        %--Valid-----------------------------------------------------------
        function isValid = get.Valid(self)
            %A valid polygon should have at least one point
            isValid = ~isempty(self.PositionInternal) && ...
                (self.NumPoints >= self.MinimumNumberOfPoints) && ...
                ~isempty(self.PointHandle) && ...
                all(isvalid(self.PointHandle));
        end
        
        %--Vertices Draggable----------------------------------------------
        function set.VerticesDraggable(self,TF)
            self.VerticesDraggableInternal = TF;
            if TF
                set(self.PointHandle,'ButtonDownFcn', @(src,~) startROIReshape(self,src));
            else
                set(self.PointHandle,'ButtonDownFcn', []);
            end
        end
        
        function TF = get.VerticesDraggable(self)
            TF = self.VerticesDraggableInternal;
        end
        
        %--Visible---------------------------------------------------------
        function set.Visible(self,TF)
            if TF
                self.VisibleInternal = 'on';
            else
                self.VisibleInternal = 'off';
            end
            
            if ~isempty(self.PositionInternal)
                if TF
                    if self.LabelVisible
                        set(self.LabelHandle,'Visible',self.VisibleInternal);
                    end
                    if self.Closed
                        set(self.CloseLineHandle,'Visible',self.VisibleInternal);
                        if self.StripesVisible
                            set(self.StripeCloseLineHandle,'Visible',self.VisibleInternal);
                        end
                    end
                    if self.StripesVisible
                        set(self.StripeLineHandle,'Visible',self.VisibleInternal);
                    end
                    notify(self,'ROIShown')
                else
                    set(self.LabelHandle,'Visible',self.VisibleInternal);
                    set(self.CloseLineHandle,'Visible',self.VisibleInternal);
                    set(self.StripeCloseLineHandle,'Visible',self.VisibleInternal);
                    set(self.StripeLineHandle,'Visible',self.VisibleInternal);
                    notify(self,'ROIHidden')
                end
                set(self.LineHandle,'Visible',self.VisibleInternal);
                set(self.PointHandle,'Visible',self.VisibleInternal);
            end
        end
        
        function TF = get.Visible(self)
            if strcmp(self.VisibleInternal,'on')
                TF = true;
            else
                TF = false;
            end
        end
        
    end
    
    methods (Static, Access = protected)
        
        function circle_size_points = getCircleSize()
            points_per_inch = 72;
            pixels_per_inch = get(0, 'ScreenPixelsPerInch');
            circle_diameter_pixels = 5;
            points_per_screen_pixel = points_per_inch / pixels_per_inch;
            circle_size_points = 2*circle_diameter_pixels * points_per_screen_pixel;
        end
        
        function insertPos = getPositionOnLine(x_line, y_line, mouse_pos)
            % Interactive polygon addition picks the closest point that lies
            % exactly along the line between two vertices. Since the perimter
            % line has width associated with it, the location where button
            % down occurs along the line has to be tuned slightly.
            
            %Line segement coordinates we want to insert within
            % x_line: [x1 x2]
            % y_line: [y1 y2]
            
            %v1 is vector along polygon line segment
            v1 = [diff(x_line),diff(y_line)];
            
            % v2 is a vector from vertex to current mouse position
            v2 = [mouse_pos(1)-x_line(1),mouse_pos(2)-y_line(1)];
            
            %project parallel portion of v2 onto v1 to find point where
            %perpendicular bisector of current point to line segment connects
            insertPos = (dot(v1,v2)./dot(v1,v1)).*v1 +[x_line(1) y_line(1)];
        end
        
    end
    
end