classdef ROI < handle
    
    % Copyright 2017, The Mathworks Inc.
    
    events
        BeingDeleted
        Deleted
        DrawingStarted
        DrawingFinished
        Moving
        Moved
        ROICtrlSelected
        ROISelected
        ROIDeselected
        ROIHidden
        ROIShown
    end
    
    properties(Abstract, GetAccess = public, SetAccess = protected)
        CopiedData
        Valid
    end
    
    properties(Hidden, GetAccess = public, SetAccess = protected)
        ID
    end
    
    properties(Abstract, Dependent)
        Draggable
        LineWidth
        Position
        StripesVisible
        StripeColor
        Visible
    end
    
    properties(Dependent)
        Color
        Constrained
        ConstraintBoundingBox
        Deletable
        HighlightColor
        HighlightWhenSelected
        Label
        LabelVisible
        SemanticValue
        Selected
        UserData
    end
    
    properties(Access = protected)
        
        % Internal representation of properties
        ColorInternal = [0 0.447 0.741];
        ConstrainedInternal = true;
        ConstraintBoundingBoxInternal = [];
        DeletableInternal = true;
        DraggableInternal = true;
        HighlightColorInternal = [1 1 0];
        HighlightWhenSelectedInternal = false;
        LabelInternal = '';
        LabelVisibleInternal = false;
        LineWidthInternal = getLineSize();
        PositionInternal = [];
        SemanticValueInternal = 1;
        SelectedInternal = false;
        StripesVisibleInternal = false;
        StripeColorInternal = [1 0 0.5];
        UserDataInternal = [];
        VisibleInternal = 'on';
        
        % Flag when user is interactively creating ROI
        UserIsDrawing = false;
        
        % Graphics ancestors
        FigureHandle
        AxesHandle
        
        % Handles to graphics components
        LineHandle
        StripeLineHandle
        CloseLineHandle
        StripeCloseLineHandle
        PointHandle
        LabelHandle
        TransparentOverlay
        OldFigurePointer
        
        % Internal event listeners
        ButtonDownEvt
        ButtonStartEvt
        ButtonMotionEvt
        ButtonUpEvt
        KeyPressEvt
        KeyReleaseEvt
        DragMotionEvt
        DragButtonUpEvt
        EmptyCallbackHandle
        FigureModeListener
        
        % Internal placeholders to manage positioning and constraint
        StartPoint
        PositionConstraint
        NumPoints = 0;
        CurrentPointIdx
        CachedPosition
        DragConstraint
        
        % Context menu
        ContextMenu
        
    end
    
    methods
        
        function self = ROI(varargin)
            
            % Get axes handle
            if nargin == 0
                hAxes = gca;
            else
                if isa(varargin{1},'matlab.graphics.axis.Axes') && isvalid(varargin{1})
                    hAxes = varargin{1};
                else
                    assert(false,'Parent must be valid axes object')
                end
            end
            
            % Set unique ID for ROI
            self.ID = self.setUniqueID();
            
            self.AxesHandle = hAxes;
            self.FigureHandle = ancestor(hAxes,'figure');
            
            setConstraintLimits(self);
            
        end
        
        %--Delete----------------------------------------------------------
        function delete(self)
            
            if ~isempty(self.ButtonDownEvt) && isvalid(self.ButtonDownEvt)
                delete(self.ButtonDownEvt);
            end
            cleanupGraphics(self);
        end
        
        %--Draw------------------------------------------------------------
        function draw(self)
            setTransparentOverlay(self);
            self.ButtonStartEvt = event.listener(self.FigureHandle,...
                'WindowMousePress',@(~,~) wireUpListeners(self));
            notify(self,'DrawingStarted');
            uiwait(self.FigureHandle);
        end
        
        %--Add Context Menu Item-------------------------------------------
        function addContextMenuItem(self,entryName,callback)
            uimenu(self.ContextMenu, 'Label', entryName, ...
                'Callback',callback,'tag','customMenuItem');
            if isLineHandleValid(self)
                set(self.LineHandle,'UIContextMenu',self.getContextMenu());
            end
            if isCloseLineHandleValid(self)
                set(self.CloseLineHandle,'UIContextMenu',self.getContextMenu());
            end
        end
        
        %--Remove Context Menu Item----------------------------------------
        function removeContextMenuItem(self,entryName)
            hobj = findall(self.ContextMenu,'Type','uimenu','Label',entryName);
            if ~isempty(hobj)
                delete(hobj);
                if isLineHandleValid(self)
                    set(self.LineHandle,'UIContextMenu',self.getContextMenu());
                end
                if isCloseLineHandleValid(self)
                    set(self.CloseLineHandle,'UIContextMenu',self.getContextMenu());
                end
            end
        end
        
    end
    
    methods (Hidden = true)
        
        %--Begin Drawing---------------------------------------------------
        function beginDrawing(self)
            setTransparentOverlay(self);
            wireUpListeners(self);
            notify(self,'DrawingStarted');
            uiwait(self.FigureHandle);
        end
        
        %--Set ID----------------------------------------------------------
        function setID(self,uuid)
            self.ID = uuid;
        end
        
    end
    
    methods (Abstract)
        
        BW = createMask(self,m,n)
        
    end
    
    methods (Abstract, Access = protected)
        
        cleanupGraphics(self)
        wireUpListeners(self)
        getContextMenu(self)
        doHighlight(self)
        updateView(self)
        setPointerFcn(self)
        startLineDrag(self)
        reshapeROI(self, hPoint, currentPoint)
        
    end
    
    methods(Access = protected)
        
        function endInteractivePlacement(self)
            % Remove Vertices
            self.UserIsDrawing = false;
            set(self.PointHandle, 'Marker', 'none')
            updateView(self);
            setLabel(self);
            uistack(self.PointHandle,'top');
            setPointerFcn(self);
            %Restore figure
            delete(self.StartPoint);
            delete(self.TransparentOverlay);
            delete(self.ButtonDownEvt);
            delete(self.ButtonMotionEvt);
            delete(self.ButtonUpEvt);
            delete(self.KeyPressEvt);
            delete(self.KeyReleaseEvt);
            delete(self.FigureModeListener);
            self.FigureHandle.Pointer = self.OldFigurePointer;
            self.clearEmptyCallbackHandle();
            uiresume(self.FigureHandle);
            notify(self,'DrawingFinished');
        end
        
        function setTransparentOverlay(self)
            % Reset existing state
            cleanupGraphics(self);
            self.NumPoints = 0;
            self.PositionInternal = [];
            self.UserIsDrawing = true;
            
            % Create a transparent layer that sits on top of the HG stack
            % that grabs button down. This prevents interaction with other
            % HG objects that have button down behavior as we are placing
            % ROI instances.
            hParent = self.AxesHandle;
            self.TransparentOverlay = axes('Parent',get(hParent,'Parent'),...
                'Units',get(hParent,'Units'),'Position',get(hParent,'Position'),...
                'Visible','off','HitTest','on','HandleVisibility','off',...
                'XLim',get(hParent,'XLim'),'YLim',get(hParent,'YLim'),...
                'YDir',get(hParent,'YDir'),'ZLim',get(hParent,'ZLim'),...
                'PlotBoxAspectRatio',get(hParent,'PlotBoxAspectRatio'));
            
            % Update the Position of the transparent overlay to follow the
            % scroll panel axes (hParent). The scroll panel axes moves when
            % there is a zoom/pan event during interactive placement,
            % causing a misalignment of the overlay and the scroll panel
            % axes. The following ensures that whenever the position of the
            % hParent changes, the position of hTransparentOverlay gets
            % updated.
            funcUpdatePosition = @(hobj,evt)set(self.TransparentOverlay,'Position',get(hParent,'Position'));
            
            positionChangedListener = event.proplistener(hParent,...
                hParent.findprop('Position'),'PostSet',funcUpdatePosition);
            
            % Associate the listener with the transparent overlay, so that
            % its life time coincides with that of the transparent overlay.
            setappdata(self.TransparentOverlay,'PostSetListener',positionChangedListener);
            
            self.OldFigurePointer = self.FigureHandle.Pointer;
            
            uistack(self.TransparentOverlay,'top');
            self.TransparentOverlay.PickableParts = 'all';
            
            iptPointerManager(self.FigureHandle);
            iptSetPointerBehavior(self.TransparentOverlay,@(~,~) set(self.FigureHandle,'Pointer','crosshair'));
            
            % If figure has any uimode already selected, remove it
            if ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode = [];
            end
            
        end
        
        function setLabel(self)
            labelPos = self.getEnhancedIconPositions();
            
            if strcmp(self.AxesHandle.YDir,'normal')
                alignDir = 'top';
            else
                alignDir = 'bottom';
            end
            
            self.LabelHandle = text('parent', self.AxesHandle, ...
                'BackgroundColor', getColor(self), 'String', self.Label, ...
                'Tag', 'label', 'Interpreter', 'none', ...
                'Clipping','on', 'HandleVisibility','off', ...
                'Position', labelPos, 'Color', getEdgeColor(self), ...
                'Margin',1, 'UIContextMenu', self.getContextMenu(), ...
                'Visible','off', 'VerticalAlignment',alignDir);

            uistack(self.LabelHandle,'top');
            if self.Valid && self.LabelVisible
                self.LabelHandle.Visible = self.VisibleInternal;
            else
                self.LabelHandle.Visible = 'off';
            end
            
            if self.DraggableInternal
                set(self.LabelHandle, 'ButtonDownFcn', @(~, ~) startLineDrag(self));
            end
            
        end
        
        function toggleSelected(self)
            self.Selected = ~self.Selected;
        end
        
        function [constrainedX, constrainedY] = getConstrainedPosition(self, X, Y)
            constrainedX = min(max(X, self.PositionConstraint(1)), self.PositionConstraint(2));
            constrainedY = min(max(Y, self.PositionConstraint(3)), self.PositionConstraint(4));
        end
        
        function [constrainedX, constrainedY] = getConstrainedDragPosition(self, X, Y)
            constrainedX = min(max(X, self.DragConstraint(1)), self.DragConstraint(2));
            constrainedY = min(max(Y, self.DragConstraint(3)), self.DragConstraint(4));
        end
        
        function deleteROI(self)
            if ~self.Deletable
                return;
            end
            
            notify(self,'BeingDeleted');
            cleanupGraphics(self);
            self.PositionInternal = [];
            self.NumPoints = 0;
            notify(self, 'Deleted');
        end
        
        function clickPos = getCurrentAxesPoint(self)
            cP = self.AxesHandle.CurrentPoint;
            clickPos = [cP(1,1) cP(1,2)];
        end
        
        function color = getColor(self)
            if self.Selected && self.HighlightWhenSelected
                color = self.HighlightColor;
            else
                color = self.Color;
            end
        end
        
        function color = getEdgeColor(self)
            if sum(getColor(self)) < 1
                color = [1 1 1];
            else
                color = [0 0 0];
            end
        end
        
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
                
                self.setEmptyCallbackHandle();
                
                self.DragMotionEvt = event.listener(self.FigureHandle,...
                    'WindowMouseMotion',@(~,~) reshapeROI(self, hPoint, currentPoint));
                
                self.DragButtonUpEvt = event.listener(self.FigureHandle,...
                    'WindowMouseRelease',@(~,~) stopDrag(self, currentPoint));
            end
            determineSelectionStatus(self);
        end
        
        function stopDrag(self, startPoint)
            currentPoint = getCurrentAxesPoint(self);
            delete(self.DragMotionEvt);
            delete(self.DragButtonUpEvt);
            self.clearEmptyCallbackHandle();
            
            % Enable the figure's pointer manager.
            iptPointerManager(self.FigureHandle, 'enable');
            
            if ~isequal(currentPoint, startPoint)
                notify(self, 'Moved');
            end
        end
        
        function determineSelectionStatus(self)
            % Set ROI selection status : Clicking selects/unselects
            % ROIs.
            figH = self.FigureHandle;
            clickType   = get(figH, 'SelectionType');
            leftClick   = strcmp(clickType, 'normal');
            ctrlPressed = strcmp(get(figH, 'CurrentModifier'), 'control');
            rightClick  = strcmp(clickType,'alt')& isempty(ctrlPressed);
            ctrlClick   = strcmp(clickType,'alt')& ~isempty(ctrlPressed);
            
            if leftClick || rightClick
                if ~self.Selected
                    self.Selected = true;
                    notify(self,'ROISelected');
                end
            elseif ctrlClick
                TF = self.Selected;
                toggleSelected(self);      
                if TF
                    notify(self,'ROIDeselected');
                else
                    notify(self,'ROICtrlSelected');
                end
            end
        end
        
        function setConstraintLimits(self)
            if self.ConstrainedInternal
                if isempty(self.ConstraintBoundingBoxInternal)
                    % Default constraint, ROI is constrained to axes limits
                    xLim = self.AxesHandle.XLim;
                    yLim = self.AxesHandle.YLim;
                else
                    % Custom bounding box applied as constraint
                    xLim = [self.ConstraintBoundingBox(1), self.ConstraintBoundingBox(1)+self.ConstraintBoundingBox(3)];
                    yLim = [self.ConstraintBoundingBox(2), self.ConstraintBoundingBox(2)+self.ConstraintBoundingBox(4)];
                end
                self.PositionConstraint = [xLim(1), xLim(2), yLim(1), yLim(2)];
            else
                % Set ROI to be unconstrained
                self.PositionConstraint = [-Inf, Inf, -Inf, Inf];
            end
        end
        
        function setEmptyCallbackHandle(self)
            % Set callback for mouse button motion
            self.EmptyCallbackHandle = @(~,~) self.emptyCallback();
            if isempty(self.FigureHandle.WindowButtonMotionFcn)
                self.FigureHandle.WindowButtonMotionFcn = self.EmptyCallbackHandle;
            end
        end
        
        function clearEmptyCallbackHandle(self)
            if isequal(self.FigureHandle.WindowButtonMotionFcn,self.EmptyCallbackHandle)
                self.FigureHandle.WindowButtonMotionFcn = [];
            end
        end
        
        function newFigureMode(self,varargin)
            
            if isempty(self.FigureHandle.ModeManager.CurrentMode)
                % Restore interactive placement
                self.ButtonDownEvt.Enabled = true;
                self.ButtonMotionEvt.Enabled = true;
                self.KeyPressEvt.Enabled = true;
                
                hParent = self.AxesHandle;
                set(self.TransparentOverlay,'XLim',get(hParent,'XLim'),'YLim',get(hParent,'YLim'),...
                    'YDir',get(hParent,'YDir'),'ZLim',get(hParent,'ZLim'),...
                    'PlotBoxAspectRatio',get(hParent,'PlotBoxAspectRatio'));
                
                if ~isempty(self.StartPoint) && isvalid(self.StartPoint)
                    set(self.StartPoint,'Visible','on');
                end
                
                updateView(self)
                % Update Transparent Overlay properties
            else
                % Hide Transparent Overlay
                % Hide Animated Line
                self.ButtonDownEvt.Enabled = false;
                self.ButtonMotionEvt.Enabled = false;
                self.KeyPressEvt.Enabled = false;
                
                if ~isempty(self.StartPoint) && isvalid(self.StartPoint)
                    set(self.StartPoint,'Visible','off');
                end
                
                updateView(self)
            end
        end
        
        function updateEnhancedIconPositions(self)
            labelPos = self.getEnhancedIconPositions();
            if ~isempty(self.LabelHandle)
                if self.Valid && self.LabelVisible
                    self.LabelHandle.Visible = self.VisibleInternal;
                else
                    self.LabelHandle.Visible = 'off';
                end
                self.LabelHandle.Position = labelPos;
            end
        end
        
        function labelPos = getEnhancedIconPositions(self)
            labelPos = self.getIconPos(self.PositionInternal);
        end
        
        function TF = isLabelHandleValid(self)
            TF = ~isempty(self.LabelHandle) && ishandle(self.LabelHandle) && ...
                isvalid(self.LabelHandle);
        end
        
        function TF = isLineHandleValid(self)
            TF = ~isempty(self.LineHandle) && ishandle(self.LineHandle) && ...
                isvalid(self.LineHandle);
        end
        
        function TF = isPointHandleValid(self)
            TF = ~isempty(self.PointHandle) && all(ishandle(self.PointHandle)) && ...
                all(isvalid(self.PointHandle));
        end
        
        function TF = isStripeLineHandleValid(self)
            TF = ~isempty(self.StripeLineHandle) && ishandle(self.StripeLineHandle) && ...
                isvalid(self.StripeLineHandle);
        end
        
        function TF = isCloseLineHandleValid(self)
            TF = ~isempty(self.CloseLineHandle) && ishandle(self.CloseLineHandle) && ...
                isvalid(self.CloseLineHandle);
        end
        
        function TF = isStripeCloseLineHandleValid(self)
            TF = ~isempty(self.StripeCloseLineHandle) && ishandle(self.StripeCloseLineHandle) && ...
                isvalid(self.StripeCloseLineHandle);
        end
        
    end
    
    methods
        % Set/Get methods
        
        %--Color-----------------------------------------------------------
        function set.Color(self, color)
            self.ColorInternal = color;
            doHighlight(self);
        end
        
        function color = get.Color(self)
            color = self.ColorInternal;
        end
        
        %--Constrained-----------------------------------------------------
        function set.Constrained(self,TF)
            self.ConstrainedInternal = TF;
        end
        
        function TF = get.Constrained(self)
            TF = self.ConstrainedInternal;
        end
        
        %--Constraint Bounding Box-----------------------------------------
        function set.ConstraintBoundingBox(self,bbox)
            % bbox should either be empty (default constraint of up-to-date
            % axes limits) or a 1x4 vector [x,y,w,h]
            if ~isempty(bbox)
                assert(isvector(bbox) && numel(bbox) == 4,'Invalid bounding box input');
                assert(bbox(3) > 0 && bbox(4) > 0,'Width and height of bounding box must be greater than zero');
            end
            self.Constrained = true;
            self.ConstraintBoundingBoxInternal = bbox;
        end
        
        function bbox = get.ConstraintBoundingBox(self)
            bbox = self.ConstraintBoundingBoxInternal;
        end
        
        %--Deletable-------------------------------------------------------
        function set.Deletable(self, TF)
            self.DeletableInternal = TF;
            doHighlight(self);
        end
        
        function TF = get.Deletable(self)
            TF = self.DeletableInternal;
        end
        
        %--Highlight Color-------------------------------------------------
        function set.HighlightColor(self, color)
            self.HighlightColorInternal = color;
            doHighlight(self);
        end
        
        function color = get.HighlightColor(self)
            color = self.HighlightColorInternal;
        end
        
        %--Highlight When Selected-----------------------------------------
        function set.HighlightWhenSelected(self, TF)
            self.HighlightWhenSelectedInternal = TF;
            doHighlight(self);
        end
        
        function TF = get.HighlightWhenSelected(self)
            TF = self.HighlightWhenSelectedInternal;
        end
        
        %--Label-----------------------------------------------------------
        function set.Label(self,val)
            self.LabelInternal = val;
            set(self.LabelHandle,'String',val);
        end
        
        function val = get.Label(self)
            val = self.LabelInternal;
        end
        
        %--Label Visible---------------------------------------------------
        function set.LabelVisible(self,TF)
            self.LabelVisibleInternal = TF;
            if isLabelHandleValid(self)
                if TF
                    self.LabelHandle.Visible = 'on';
                else
                    self.LabelHandle.Visible = 'off';
                end
            end
        end
        
        function TF = get.LabelVisible(self)
            TF = self.LabelVisibleInternal;
        end
        
        %--Semantic Value--------------------------------------------------
        function set.SemanticValue(self,val)
            if val >= 0
                self.SemanticValueInternal = round(val);
            end
        end
        
        function val = get.SemanticValue(self)
            val = self.SemanticValueInternal;
        end
        
        %--User Data-------------------------------------------------------
        function set.UserData(self,val)
            self.UserDataInternal = val;
        end
        
        function val = get.UserData(self)
            val = self.UserDataInternal;
        end
        
        %--Selected--------------------------------------------------------
        function tf = get.Selected(self)
            tf = self.SelectedInternal;
        end
        
        function set.Selected(self, val)
            self.SelectedInternal = val;
            doHighlight(self);
        end
        
    end
    
    methods (Static, Access = protected)
        
        function labelPos = getIconPos(pos)
            if isequal(size(pos),[1,4])
                % Rectangle case
                labelPos = [pos(1), pos(2)+pos(4)];
            else
                % Polygon case
                labelPos = [pos(1,1), pos(1,2)];
            end
        end
        
        function emptyCallback(varargin)
            % No-op callback
            % During interactive placement, the axes property CurrentPoint
            % is only updated when the figure's WindowButtonMotionFcn
            % property is not empty.
            
            % In the event that the user has not set the
            % WindowButtonMotionFcn property, we set it to this empty
            % callback function to force the CurrentPoint property to
            % update whenever the mouse is moved during drawing. If the
            % user has set the WindowButtonMotionFcn property, then there
            % is no need to replace it.
            
            % Once the user has finished drawing, we check that the
            % WindowButtonMotionFcn property is this emptyCallback and, if
            % true, we set it to empty again. If the user has set the
            % WindowButtonMotionFcn property, then there is no impact on
            % their callback.
        end
        
        function uuid = setUniqueID()
            if usejava('jvm')
                uuid = char(java.util.UUID.randomUUID);
            else
                uuid = num2str(matlab.internal.timing.timing('cpucount'));
            end
        end
            
    end
    
end

function line_size_points = getLineSize()
points_per_inch = 72;
pixels_per_inch = get(0, 'ScreenPixelsPerInch');
points_per_screen_pixel = points_per_inch / pixels_per_inch;
line_size_points = 3 * points_per_screen_pixel;
end