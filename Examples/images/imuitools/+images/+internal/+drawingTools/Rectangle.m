classdef Rectangle < images.internal.drawingTools.ROI
    
    % Copyright 2017, The Mathworks Inc.
    
    properties(Dependent)
        AspectRatio
        Draggable
        LineWidth
        FixedAspectRatio
        Position
        Resizable
        SnapToPixels
        StripesVisible
        StripeColor
        Visible
    end
    
    properties(GetAccess = public, SetAccess = protected)
        CopiedData
        Valid
    end
    
    properties(Access = protected)
        
        AspectRatioInternal = 1;
        FixedAspectRatioInternal = false;
        ResizableInternal = true;
        SnapToPixelsInternal = false;
        
        StartCorner
        NodeLocations
        RestrictPosition = [NaN NaN];
        
    end
    
    methods
        
        function self = Rectangle(varargin)
            self@images.internal.drawingTools.ROI(varargin{:});
        end
        
        %--Create Mask-----------------------------------------------------
        function BW = createMask(self,m,n)
            % Creates a binary mask size [m,n] with true values inside
            % ROI
            [x,y] = getRectangleCornerPositions(self);
            BW = poly2mask(x,y,m,n);
        end
        
        %--Inside ROI------------------------------------------------------
        function in = insideROI(self,x,y)
            % Returns logical array indicating if data points with
            % coordinates (x,y) is inside ROI. Use this method for
            % scattered data. To obtain a gridded mask, use createMask
            [xRect,yRect] = getRectangleCornerPositions(self);
            in = images.internal.inpoly(x,y,xRect,yRect);
        end
        
    end
    
    methods(Access = protected)
        
        function wireUpListeners(self)
            
            % If figure has any uimode already selected, remove it
            if ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode = [];
            end
            
            delete(self.ButtonStartEvt);
            
            self.setEmptyCallbackHandle();
            
            % Set callback for key press
            self.KeyPressEvt = event.listener(self.FigureHandle,...
                'WindowKeyPress',@(src,evt) keyPressDuringPlacement(self,src,evt));
            
            % Set callback for key release
            self.KeyReleaseEvt = event.listener(self.FigureHandle,...
                'WindowKeyRelease',@(src,evt) keyPressDuringPlacement(self,src,evt));
            
            self.ButtonMotionEvt = event.listener(self.FigureHandle,...
                'WindowMouseMotion',@(~,~) drawRectangle(self));
            
            % Set callback for mouse button release
            self.ButtonUpEvt = event.listener(self.FigureHandle,...
                'WindowMouseRelease',@(~,~) stopRectangle(self));
            
            % Start adding current location
            setConstraintLimits(self);
            startLocation = getCurrentAxesPoint(self);
            [constrainedX, constrainedY] = self.getConstrainedPosition(startLocation(1), startLocation(2));
            startRectangle(self,constrainedX,constrainedY);
            
        end
        
        function startRectangle(self,x,y)
            self.PositionInternal = [x,y,0,0];
            self.StartCorner = [x,y];
            self.RestrictPosition = [NaN, NaN];
        end
        
        function drawRectangle(self)
            if ~isempty(self.PositionInternal)
                
                if self.SnapToPixelsInternal
                    pos(1,:) = self.StartCorner - 0.5;
                else
                    pos(1,:) = self.StartCorner;
                end
                
                mouseLocation = getCurrentAxesPoint(self);
                
                [constrainedX, constrainedY] = self.getConstrainedPosition(mouseLocation(1), mouseLocation(2));
                [pos(2,1),pos(2,2)] = self.setRectangleRestriction(constrainedX, constrainedY);
                
                if self.SnapToPixelsInternal
                    pos = floor(pos);
                    pos = [min(pos(:,1)),min(pos(:,2)),max(pos(:,1))-min(pos(:,1)),max(pos(:,2))-min(pos(:,2))];
                    pos(1) = floor(pos(1)) + 0.5;
                    pos(2) = floor(pos(2)) + 0.5;
                    self.PositionInternal = pos;
                else
                    self.PositionInternal = [min(pos(:,1)),min(pos(:,2)),max(pos(:,1))-min(pos(:,1)),max(pos(:,2))-min(pos(:,2))];
                end
                
                updateView(self);
            end
        end
        
        function stopRectangle(self)
            drawRectangle(self);
            addDragPoints(self);
            endInteractivePlacement(self);
        end
        
        function addDragPoints(self)
            
            % This methods creates the array of drag points around the
            % rectangle and stores them as a vector of handles in
            % self.PointHandle
            % The array index in self.PointHandle for each location on the
            % rectangle is as follows:
            %
            % 7------6------5
            % |             |
            % 8             4
            % |             |
            % 1------2------3
            
            [xDrag,yDrag] = getDragPoints(self);
            
            for idx = 1:numel(xDrag)
                self.drawDragPoints(xDrag(idx),yDrag(idx));
            end
        end
        
        function hPoint = drawDragPoints(self, x, y)
            hPoint = line(x, y, ...
                'Parent', self.AxesHandle, ...
                'Marker', 'square', ...
                'MarkerFaceColor', getColor(self) , ...
                'MarkerEdgeColor', getEdgeColor(self) , ...
                'Clipping', 'on', ...
                'MarkerSize', self.getCircleSize(), ...
                'Tag','square', ...
                'Visible',self.VisibleInternal, ...
                'HandleVisibility','off', ...
                'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
            
            if self.ResizableInternal
                set(hPoint, 'ButtonDownFcn', @(src,~) startROIReshape(self,src));
            end
            
            pointHandles = self.PointHandle;
            self.PointHandle = [pointHandles, hPoint];
            
        end
        
        function [lineH,stripeLineH] = getInteractiveLine(self)
            if isempty(self.LineHandle)
                
                self.LineHandle =  line('Parent', self.AxesHandle, ...
                    'Color', getColor(self), ...
                    'LineWidth', self.LineWidthInternal, ...
                    'Tag','rectangleROI', ...
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
                    'Tag','rectangleStripeROI', ...
                    'Visible',visline, ...
                    'HandleVisibility','off', ...
                    'HitTest', 'off', ...
                    'PickableParts','none', ...
                    'XLimInclude','off','YLimInclude','off','ZLimInclude','off');
                
            end
            
            lineH = self.LineHandle;
            stripeLineH = self.StripeLineHandle;
        end
        
        function updateView(self)
            %called once self.Position is set to offer a new line view
            if ~isempty(self.PositionInternal)
                
                % Get updated coordinates
                [x,y] = getRectangleCornerPositions(self);
                [xDrag,yDrag] = getDragPoints(self);
                
                % Update graphics objects
                [lineH,stripeLineH] = getInteractiveLine(self);
                set(lineH, 'XData', x, 'YData', y);
                set(stripeLineH, 'XData', x, 'YData', y);
                
                if ~self.UserIsDrawing
                    for idx = 1:numel(xDrag)
                        set(self.PointHandle(idx), 'XData', xDrag(idx), 'YData', yDrag(idx));
                    end
                    
                    updateEnhancedIconPositions(self);
                end
                
            end
        end
        
        function [x,y] = setRectangleRestriction(self,x,y)
            
            if self.FixedAspectRatioInternal
                % Apply aspect ratio
                oldH = y - self.StartCorner(2);
                oldW = x - self.StartCorner(1);
                newAR = abs(oldH)/abs(oldW);
                
                if newAR > self.AspectRatioInternal
                    newH = abs(oldW.*self.AspectRatioInternal);
                    y = (oldH.*(newH./abs(oldH))) + self.StartCorner(2);
                else
                    newW = abs(oldH./self.AspectRatioInternal);
                    x = (oldW.*(newW./abs(oldW))) + self.StartCorner(1);
                end
                
            else
                
                if ~isnan(self.RestrictPosition(1))
                    x = self.RestrictPosition(1);
                end
                
                if ~isnan(self.RestrictPosition(2))
                    y = self.RestrictPosition(2);
                end
                
            end
            
        end
        
        function [x,y] = getRectangleCornerPositions(self)
            x = [self.PositionInternal(1); self.PositionInternal(1);...
                self.PositionInternal(1)+self.PositionInternal(3);...
                self.PositionInternal(1)+self.PositionInternal(3);...
                self.PositionInternal(1)];
            y  = [self.PositionInternal(2);...
                self.PositionInternal(2)+self.PositionInternal(4);...
                self.PositionInternal(2)+self.PositionInternal(4);...
                self.PositionInternal(2); self.PositionInternal(2)];
        end
        
        function [xPos,yPos] = getDragPoints(self)
            
            % The array index in self.PointHandle for each location on the
            % rectangle is as follows:
            %
            % 7------6------5
            % |             |
            % 8             4
            % |             |
            % 1------2------3
            
            % Intermediate values
            x = self.PositionInternal(1);
            xPlusW = self.PositionInternal(1) + self.PositionInternal(3);
            xPlusHalfW = self.PositionInternal(1) + (0.5*self.PositionInternal(3));
            
            y = self.PositionInternal(2);
            yPlusH = self.PositionInternal(2) + self.PositionInternal(4);
            yPlusHalfH = self.PositionInternal(2) + (0.5*self.PositionInternal(4));
            
            xPos = [x; xPlusHalfW; xPlusW; xPlusW; xPlusW; xPlusHalfW; x; x];
            yPos = [y; y; y; yPlusHalfH; yPlusH; yPlusH; yPlusH; yPlusHalfH];
            
        end
        
        function setStartCorner(self)
            
            % The array index in self.PointHandle for each location on the
            % rectangle is as follows:
            %
            % 7------6------5
            % |             |
            % 8             4
            % |             |
            % 1------2------3
            %
            % Determine the fixed corner of the rectangle during reshape
            
            [xPos,yPos] = getDragPoints(self);
            
            switch self.CurrentPointIdx
                case {1, 2, 8}
                    self.StartCorner = [xPos(5), yPos(5)];
                case 3
                    self.StartCorner = [xPos(7), yPos(7)];
                case {4, 5, 6}
                    self.StartCorner = [xPos(1), yPos(1)];
                case 7
                    self.StartCorner = [xPos(3), yPos(3)];
            end
            
            switch self.CurrentPointIdx
                % No restriction
                case {1, 3, 5, 7}
                    self.RestrictPosition = [NaN NaN];
                    
                    % Restrict movement in x direction
                case 2
                    self.RestrictPosition = [xPos(1) NaN];
                case 6
                    self.RestrictPosition = [xPos(5) NaN];
                    
                    % Restrict movement in y direction
                case 4
                    self.RestrictPosition = [NaN yPos(5)];
                case 8
                    self.RestrictPosition = [NaN yPos(1)];
            end
            
        end
        
        function reshapeROI(self, ~, startPoint)
            
            currentPoint = getCurrentAxesPoint(self);
            [newX, newY] = self.getConstrainedPosition(currentPoint(1), currentPoint(2));
            pos = [newX, newY];
            
            % Don't change if it is still at the old location
            if ~isequal(pos, startPoint)
                drawRectangle(self);
                notify(self, 'Moving');
            end
        end
        
        function keyPressDuringPlacement(self,~,evt)
            % Discontinue interactive drawing for backspace, delete,
            % escape key presses
            toggleAspectRatio = any(strcmp(evt.Key,{'shift'}));
            
            if toggleAspectRatio
                switch evt.EventName
                    case 'WindowKeyPress'
                        self.FixedAspectRatio = true;
                    case 'WindowKeyRelease'
                        self.FixedAspectRatio = false;
                end
                drawRectangle(self);
            end
            
        end
        
        function startLineDrag(self)
            
            hFig = self.FigureHandle;
            if strcmp(get(hFig, 'SelectionType'), 'normal')
                % Set axes limits
                setConstraintLimits(self);
                self.CachedPosition = self.PositionInternal(1:2);
                
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
                
            end
            determineSelectionStatus(self);
        end
        
        function dragLineMotion(self, startPoint)
            currentPoint = getCurrentAxesPoint(self);
            
            if ~isequal(self.getConstrainedPosition(currentPoint(1), currentPoint(2)), startPoint)
                
                [newX, newY] = self.getConstrainedDragPosition(currentPoint(1), currentPoint(2));
                
                newPositions = self.CachedPosition + [newX, newY] - startPoint;
                
                if self.SnapToPixelsInternal
                    newPositions = floor(newPositions) + 0.5;
                end
                
                self.PositionInternal(1:2) = newPositions;
                
                self.updateView();
                notify(self, 'Moving');
            end
        end
        
        function setDragBoundary(self,currentPoint)
            xMin = max(self.PositionInternal(1) - self.PositionConstraint(1),0);
            xMax = max(self.PositionConstraint(2) - (self.PositionInternal(1) + self.PositionInternal(3)),0);
            yMin = max(self.PositionInternal(2) - self.PositionConstraint(3),0);
            yMax = max(self.PositionConstraint(4) - (self.PositionInternal(2) + self.PositionInternal(4)),0);
            
            self.DragConstraint = [currentPoint(1) - xMin, currentPoint(1) + xMax,...
                currentPoint(2) - yMin, currentPoint(2) + yMax];
        end
        
        function cMenu = getContextMenu(self)
            if isempty(self.ContextMenu)
                cMenu = uicontextmenu(self.FigureHandle);
                uimenu(cMenu, 'Label', getString(message('images:roiContextMenuUIString:fixAspectRatioContextMenuLabel')), 'Callback', ...
                    @(~,~)self.toggleFixAspectRatio,...
                    'tag','contextAspectRatio');
                uimenu(cMenu,'Label',getString(message('images:roiContextMenuUIString:deleteRoiLabel')), ...
                    'Callback', @(~,~)self.deleteROI,...
                    'Tag','deleteROI');
                self.ContextMenu = cMenu;
            end
            cMenu = self.ContextMenu;
        end
        
        function setPointerFcn(self)
            iptPointerManager(self.FigureHandle);
            pointerBehavior.enterFcn = @(~,~) linePointerEnterFcn(self);
            pointerBehavior.exitFcn = @(~,~) linePointerExitFcn(self);
            pointerBehavior.traverseFcn = [];
            iptSetPointerBehavior(self.LineHandle, pointerBehavior);
            iptSetPointerBehavior(self.LabelHandle, pointerBehavior);
            
            % The array index in self.PointHandle for each location on the
            % rectangle is as follows:
            %
            % 7------6------5
            % |             |
            % 8             4
            % |             |
            % 1------2------3
            %
            % Apply pointer to corresponding point in self.PointHandle
            % array
            
            % Adjust pointer for cases when one or both of X,Y directions
            % are reversed
            if strcmp(self.AxesHandle.XDir,self.AxesHandle.YDir)
                pointerBehavior.enterFcn = @(~,~) dragPointerEnterFcn(self,'topr');
                iptSetPointerBehavior(self.PointHandle([1,5]),pointerBehavior);
                
                pointerBehavior.enterFcn = @(~,~) dragPointerEnterFcn(self,'topl');
                iptSetPointerBehavior(self.PointHandle([3,7]),pointerBehavior);
            else
                pointerBehavior.enterFcn = @(~,~) dragPointerEnterFcn(self,'topl');
                iptSetPointerBehavior(self.PointHandle([1,5]),pointerBehavior);
                
                pointerBehavior.enterFcn = @(~,~) dragPointerEnterFcn(self,'topr');
                iptSetPointerBehavior(self.PointHandle([3,7]),pointerBehavior);
            end
            
            pointerBehavior.enterFcn = @(~,~) dragPointerEnterFcn(self,'top');
            iptSetPointerBehavior(self.PointHandle([2,6]),pointerBehavior);
            
            pointerBehavior.enterFcn = @(~,~) dragPointerEnterFcn(self,'left');
            iptSetPointerBehavior(self.PointHandle([4,8]),pointerBehavior);
        end
        
        function dragPointerEnterFcn(self,symbol)
            try
                if self.ResizableInternal
                    set(self.FigureHandle,'Pointer',symbol);
                    set(self.PointHandle, 'Marker', 'square');
                end
            catch
                % No-op
            end
        end
        
        function linePointerEnterFcn(self)
            try
                if self.ResizableInternal
                    set(self.PointHandle, 'Marker', 'square');
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
            
            if isLabelHandleValid(self)
                delete(self.LabelHandle);
            end
            self.LabelHandle = [];
        end
        
        function doHighlight(self)
            color = getColor(self);
            [lineH,~] = getInteractiveLine(self);
            lineH.Color = color;
            set(self.LabelHandle,'Color',getEdgeColor(self),'BackgroundColor',color);
            set(self.PointHandle, 'MarkerFaceColor', color, 'MarkerEdgeColor', getEdgeColor(self));
        end
        
        function setMidpointVisibility(self,TF)
            if isPointHandleValid(self)
                if TF
                    set(self.PointHandle([1,3,5,7]),'Visible',self.VisibleInternal);
                    set(self.PointHandle([2,4,6,8]),'Visible','off');
                else
                    set(self.PointHandle,'Visible',self.VisibleInternal);
                end
            end
        end
        
        function toggleFixAspectRatio(self)
            self.FixedAspectRatio = ~self.FixedAspectRatio;
        end
        
    end
    
    methods
        % Set/Get methods
        
        %--Copied Data-----------------------------------------------------
        function copiedData = get.CopiedData(self)
            copiedData.Position = self.Position;
            copiedData.SemanticValue = self.SemanticValueInternal;
            copiedData.Label = self.LabelInternal;
            copiedData.Color = self.ColorInternal;
            copiedData.UserData = self.UserDataInternal;
        end
        
        %--Fixed Aspect Ratio----------------------------------------------
        function set.FixedAspectRatio(self,TF)
            self.FixedAspectRatioInternal = TF;
            setMidpointVisibility(self,TF);
            
            hobj = findall(self.ContextMenu,'Type','uimenu','Label','Fix Aspect Ratio');
            if ~isempty(hobj)
                if TF
                    hobj.Checked = 'on';
                else
                    hobj.Checked = 'off';
                end
            end
        end
        
        function TF = get.FixedAspectRatio(self)
            TF = self.FixedAspectRatioInternal;
        end
        
        %--Aspect Ratio----------------------------------------------------
        function set.AspectRatio(self,val)
            assert((isscalar(val) && val > 0),'Aspect ratio must be positive scalar value of height/width ratio');
            
            self.AspectRatioInternal = val;
            self.FixedAspectRatio = true;
        end
        
        function val = get.AspectRatio(self)
            val = self.AspectRatioInternal;
        end
        
        %--Draggable-------------------------------------------------------
        function set.Draggable(self,TF)
            self.DraggableInternal = TF;
            if TF
                set(self.LineHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
                set(self.LabelHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
            else
                set(self.LineHandle, 'ButtonDownFcn', []);
                set(self.LabelHandle, 'ButtonDownFcn', []);
                self.Resizable = TF;
            end
        end
        
        function TF = get.Draggable(self)
            TF = self.DraggableInternal;
        end
        
        %--Resizable-------------------------------------------------------
        function set.Resizable(self,TF)
            self.ResizableInternal = TF;
            if TF
                set(self.PointHandle,'ButtonDownFcn', @(src,~) startROIReshape(self,src));
            else
                set(self.PointHandle,'ButtonDownFcn', []);
            end
        end
        
        function TF = get.Resizable(self)
            TF = self.ResizableInternal;
        end
        
        %--Line Width------------------------------------------------------
        function set.LineWidth(self,val)
            assert(val > 0,'LineWidth must be positive scalar');
            
            set(self.LineHandle,'LineWidth',val);
            set(self.StripeLineHandle,'LineWidth',val);
            self.LineWidthInternal = val;
            
        end
        
        function val = get.LineWidth(self)
            val = self.LineWidthInternal;
        end
        
        %--Snap To Pixels--------------------------------------------------
        function set.SnapToPixels(self,TF)
            self.SnapToPixelsInternal = TF;
        end
        
        function TF = get.SnapToPixels(self)
            TF = self.SnapToPixelsInternal;
        end
        
        %--Stripe Color----------------------------------------------------
        function set.StripeColor(self, color)
            self.StripeColorInternal = color;
            [~,stripeLineH] = getInteractiveLine(self);
            stripeLineH.Color = color;
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
            set(self.StripeLineHandle,'Visible',self.StripesVisibleInternal);
            
        end
        
        function TF = get.StripesVisible(self)
            if strcmp(self.StripesVisibleInternal,'on')
                TF = true;
            else
                TF = false;
            end
        end
        
        %--Position--------------------------------------------------------
        function set.Position(self,pos)
            assert(isequal(size(pos),[1 4]), 'Rectangle position must be set as [x, y, w, h]');
            
            cachedVisibility = self.Visible;
            self.Visible = false;
            
            %Reset existing state
            cleanupGraphics(self);
            self.NumPoints = 0;
            
            % Convert to spatial coordinates if necessary
            if self.SnapToPixelsInternal
                pos(1) = pos(1) - 0.5;
                pos(2) = pos(2) - 0.5;
                pos(3) = floor(pos(3));
                pos(4) = floor(pos(4));
            end
            
            self.PositionInternal = pos;
            self.AspectRatioInternal = self.PositionInternal(4)/self.PositionInternal(3);
            
            addDragPoints(self);
            set(self.PointHandle, 'Marker', 'none')
            updateView(self);
            setLabel(self);
            uistack(self.PointHandle,'top');
            setPointerFcn(self)
            
            self.Visible = cachedVisibility;
            
        end
        
        function pos = get.Position(self)
            pos = self.PositionInternal;
            
            % Convert to pixel coordinates if necessary
            if self.SnapToPixelsInternal
                pos(1) = pos(1) + 0.5;
                pos(2) = pos(2) + 0.5;
            end
            
        end
        
        %--Valid-----------------------------------------------------------
        function isValid = get.Valid(self)
            %A valid rectangle should have at nonzero width and height
            isValid = ~isempty(self.PositionInternal) && ...
                (self.PositionInternal(3) > 0) && ...
                (self.PositionInternal(4) > 0) && ...
                ~isempty(self.PointHandle) && ...
                all(isvalid(self.PointHandle));
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
                    if self.StripesVisible
                        set(self.StripeLineHandle,'Visible',self.VisibleInternal);
                    end
                    notify(self,'ROIShown')
                else
                    set(self.LabelHandle,'Visible',self.VisibleInternal);
                    set(self.StripeLineHandle,'Visible',self.VisibleInternal);
                    notify(self,'ROIHidden')
                end
                set(self.LineHandle,'Visible',self.VisibleInternal);
                setMidpointVisibility(self,self.FixedAspectRatioInternal);
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
    
    methods (Access = protected)
        % Overloaded from ROI base class
        
        function startROIReshape(self, hPoint)
            
            % Set axes limits
            setConstraintLimits(self);
            
            hFig = self.FigureHandle;
            if strcmp(get(hFig, 'SelectionType'), 'normal')
                
                % Disable the figure's pointer manager during the drag.
                iptPointerManager(hFig, 'disable');
                
                % Get the mouse location in data space.
                currentPoint = getCurrentAxesPoint(self);
                self.CurrentPointIdx = find(self.PointHandle == hPoint);
                setStartCorner(self);
                
                self.setEmptyCallbackHandle();
                
                self.DragMotionEvt = event.listener(self.FigureHandle,...
                    'WindowMouseMotion',@(~,~) reshapeROI(self, hPoint, currentPoint));
                
                self.DragButtonUpEvt = event.listener(self.FigureHandle,...
                    'WindowMouseRelease',@(~,~) stopDrag(self, currentPoint));
                
                % Set callback for key press
                self.KeyPressEvt = event.listener(self.FigureHandle,...
                    'WindowKeyPress',@(src,evt) keyPressDuringPlacement(self,src,evt));
                
                % Set callback for key release
                self.KeyReleaseEvt = event.listener(self.FigureHandle,...
                    'WindowKeyRelease',@(src,evt) keyPressDuringPlacement(self,src,evt));
            end
            determineSelectionStatus(self);
        end
        
        function stopDrag(self, startPoint)
            
            self.AspectRatioInternal = self.PositionInternal(4)/self.PositionInternal(3);
            
            currentPoint = getCurrentAxesPoint(self);
            delete(self.DragMotionEvt);
            delete(self.DragButtonUpEvt);
            delete(self.KeyPressEvt);
            delete(self.KeyReleaseEvt);
            self.clearEmptyCallbackHandle();
            
            % Enable the figure's pointer manager.
            iptPointerManager(self.FigureHandle, 'enable');
            
            if ~isequal(currentPoint, startPoint)
                notify(self, 'Moved');
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
        
    end
    
end
