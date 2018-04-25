classdef PaintBrush < handle
    
    % Copyright 2017, The Mathworks Inc.
    
    events
        Created
        DrawingStarted
        DrawingFinished
        MaskEdited
        BeingDeleted
        Deleted
        MaskSelected
        MaskDeselected
    end
    
    properties(GetAccess = public, SetAccess = private)
        Valid
    end
    
    properties(Dependent)
        % COLOR - Color of marker that appears when drawing
        Color
        
        % ERASE - Mode to determine when to add to mask and when to erase
        % from mask: True - erase from mask, False - add to mask 
        Erase
        
        % ERASECOLOR - Color of marker that appears when erasing
        EraseColor
        
        % LABEL - Label for PaintBrush object
        Label
        
        % MARKERSIZE - Size of marker applied when drawing or erasing
        MarkerSize
        
        % MASK - Binary mask
        Mask
        
        % SELECTED - Logical scalar value denoting if object is selected
        Selected
        
        % SEMANTICVALUE - Numeric label for object. Must be integer value
        % greater than zero
        SemanticValue
    end
        
    properties(Access = private)
        
        ColorInternal = [0 1 0];
        EraseInternal = false;
        EraseColorInternal = [1 0 0];
        LabelInternal = '';
        MarkerSizeInternal = 101;
        MaskInternal = [];
        SemanticValueInternal = 1;
        SelectedInternal = false;
                
        ImageSize
        FigureHandle
        AxesHandle
        
        TransparentOverlay
        ButtonDownEvt
        ButtonMotionEvt
        ButtonUpEvt
        EmptyCallbackHandle
        OldFigurePointer
        PointerSet = false;
        
        Indices = [];
        PatchColor
        
        LastPoint = [];
                
    end
    
    methods
        
        function self = PaintBrush(varargin)
            % Get axes handle
            if nargin == 0
                hAxes = gca;
                self.ImageSize = round([hAxes.YLim(2) - hAxes.YLim(1),hAxes.XLim(2) - hAxes.XLim(1)]);
            else
                if isa(varargin{1},'matlab.graphics.axis.Axes') && isvalid(varargin{1})
                    hAxes = varargin{1};
                else
                    assert(false,'Parent must be valid axes object')
                end
                self.ImageSize = varargin{2};
            end
            
            self.AxesHandle = hAxes;
            self.FigureHandle = ancestor(hAxes,'figure');
            notify(self,'Created');
        end
        
        function delete(self)
            notify(self,'BeingDeleted');
            self.MaskInternal = [];
            delete(self.ButtonDownEvt);
            delete(self.ButtonMotionEvt);
            delete(self.ButtonUpEvt);
            notify(self,'Deleted');
        end
        
        function addPixels(self,pixels)            
            mask = false([self.ImageSize(1),self.ImageSize(2)]);
            mask(pixels) = true;
            mask = imdilate(mask,ones(self.MarkerSize),'same');
            if ~self.Valid
                self.MaskInternal = mask;
            else
                self.MaskInternal = self.MaskInternal | mask;
            end
            notify(self,'MaskEdited');
        end
        
        function removePixels(self,pixels)            
            mask = false([self.ImageSize(1),self.ImageSize(2)]);
            if ~self.Valid
                self.MaskInternal = mask;
            end
            mask(pixels) = true;
            mask = imdilate(mask,ones(self.MarkerSize),'same');
            self.MaskInternal = self.MaskInternal & ~mask;
            notify(self,'MaskEdited');
        end
        
        function draw(self)
            setTransparentOverlay(self);
            self.ButtonDownEvt = event.listener(self.FigureHandle,...
                'WindowMousePress',@(~,~) wireUpListeners(self));
            notify(self,'DrawingStarted');
            uiwait(self.FigureHandle);
        end

    end
    
    methods(Hidden = true)
        
        function beginDrawing(self)
            setTransparentOverlay(self);
            wireUpListeners(self);
            notify(self,'DrawingStarted');
            uiwait(self.FigureHandle);
        end
        
    end
    
    methods(Access = private)
        
        function movePaintBrush(self)
            
            clickPos = round(getCurrentAxesPoint(self));
            
            if ~isInBounds(self, clickPos(1), clickPos(2))
                self.LastPoint = [];
                return;
            end
            
            if ~isempty(self.LastPoint)
                
                % Find number of points to draw between mouse locations
                lastClickPos = self.LastPoint;
                numInterp = round(max(abs(clickPos - lastClickPos)) + 1);
                interpPos(:,1) = round(linspace(lastClickPos(1),clickPos(1),numInterp));
                interpPos(:,2) = round(linspace(lastClickPos(2),clickPos(2),numInterp));
                
                addPatch(self,interpPos);
                
            else
                addPatch(self,clickPos);
            end
            
            self.LastPoint = clickPos;
        end
        
        function stopPaintBrush(self)

            self.Indices = unique(self.Indices);

            if ~self.Erase
                self.addPixels(self.Indices)
            else
                self.removePixels(self.Indices)
            end

            self.Indices = [];
            self.LastPoint = [];
            
            self.endInteractivePlacement();
        end
        
        function addPatch(self,clickPos)
            
            n = size(clickPos,1);
            
            offset = round((self.MarkerSize - 1) / 2)+0.5;
            
            offsetMat = [-offset,-offset;
                +offset,-offset;
                +offset,+offset;
                -offset,+offset];
            
            offsetMat = repmat(offsetMat,[n,1]);
            
            patchVerts = imresize(clickPos,[4*n,2],'nearest') + offsetMat;
            
            patchFaces = reshape((1:4*n),[4,n])';
            
            try
                ind = sub2ind(self.ImageSize(1:2),clickPos(:,2),clickPos(:,1));
                self.Indices = [self.Indices ind'];
                
                patch('Parent',self.TransparentOverlay,'HitTest','off','HandleVisibility','off',...
                    'FaceColor',self.PatchColor,'EdgeColor','none','Faces',patchFaces,...
                    'Vertices',patchVerts);
            catch
                % No-op - Ignore anything that is out of bounds
            end
            
        end
        
        function wireUpListeners(self)
            
            % If figure has any uimode already selected, remove it
            if ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode = [];
            end
            
            delete(self.ButtonDownEvt);
            
            % Set callback for mouse button motion
            self.EmptyCallbackHandle = @(~,~) self.emptyCallback();
            
            if isempty(self.FigureHandle.WindowButtonMotionFcn)
                self.FigureHandle.WindowButtonMotionFcn = self.EmptyCallbackHandle;
            end
            
            self.ButtonMotionEvt = event.listener(self.FigureHandle,...
                'WindowMouseMotion',@(~,~) movePaintBrush(self));
            
            % Set callback for mouse button release
            self.ButtonUpEvt = event.listener(self.FigureHandle,...
                'WindowMouseRelease',@(~,~) stopPaintBrush(self));

            % Start adding current location
            movePaintBrush(self);
        end
        
        function setTransparentOverlay(self)
            % Prevent the axes limits from changing while drawing
            hParent = self.AxesHandle;
            set(hParent,'XLimMode','manual','YLimMode','manual')
            
            % Reset existing state
            self.Indices = [];
            self.LastPoint = [];
            
            if ~self.Erase
                self.PatchColor = self.ColorInternal;
            else
                self.PatchColor = self.EraseColorInternal;
            end
            
            % Create a transparent layer that sits on top of the HG stack
            % that grabs button down. This prevents interaction with other
            % HG objects that have button down behavior as we are placing
            % polygon instances. 
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
            
            uistack(self.TransparentOverlay,'top');
            self.TransparentOverlay.PickableParts = 'all';
            
            setPointer(self);
            
            % If figure has any uimode already selected, remove it
            if ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode = [];
            end
            
        end
        
        function endInteractivePlacement(self)
            
            %Restore figure
            delete(self.TransparentOverlay);
            delete(self.ButtonMotionEvt);
            delete(self.ButtonUpEvt);
            self.FigureHandle.Pointer = self.OldFigurePointer.Pointer;
            if strcmp(self.OldFigurePointer.Pointer,'custom')
                self.FigureHandle.PointerShapeCData = self.OldFigurePointer.PointerShapeCData;
                self.FigureHandle.PointerShapeHotSpot = self.OldFigurePointer.PointerShapeHotSpot;
            end
            self.PointerSet = false;
            if isequal(self.FigureHandle.WindowButtonMotionFcn,self.EmptyCallbackHandle)
                self.FigureHandle.WindowButtonMotionFcn = [];
            end
            uiresume(self.FigureHandle);
            notify(self,'DrawingFinished')
            
        end
            
        function clickPos = getCurrentAxesPoint(self)
            cP = self.AxesHandle.CurrentPoint;
            clickPos = [cP(1,1) cP(1,2)];
        end
        
        function tf = isInBounds(self, X, Y)
            XLim = self.AxesHandle.XLim;
            YLim = self.AxesHandle.YLim;
            tf = X >= XLim(1) && X <= XLim(2) && Y >= YLim(1) && Y <= YLim(2);
        end
        
        function setPointer(self)
            if ~self.PointerSet
                self.OldFigurePointer.Pointer = self.FigureHandle.Pointer;
                if strcmp(self.OldFigurePointer.Pointer,'custom')
                    self.OldFigurePointer.PointerShapeCData = self.FigureHandle.PointerShapeCData;
                    self.OldFigurePointer.PointerShapeHotSpot = self.FigureHandle.PointerShapeHotSpot;
                end
                iptPointerManager(self.FigureHandle);
                myPointer = self.pencilPointer;
                if self.Erase
                    myPointer = myPointer';
                end
                iptSetPointerBehavior(self.TransparentOverlay,@(~,~) set(self.FigureHandle,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16 1]));
                self.PointerSet = true;
            end
        end
        
    end
    
     methods
        % Set/Get methods
        
        %------------------------------------------------------------------
        % Position
        function set.Mask(self,mask)
            assert(isequal(size(mask),[self.ImageSize(1),self.ImageSize(2)]), 'Mask must match first two dimensions of image size');
            self.MaskInternal = logical(mask);
            notify(self,'Created');
        end
        
        function pos = get.Mask(self)
            pos = self.MaskInternal;
        end
        
        %------------------------------------------------------------------
        % Color
        function set.Color(self, color)
            self.ColorInternal = color;
        end
        
        function color = get.Color(self)
            color = self.ColorInternal;
        end
        
        %------------------------------------------------------------------
        % Erase
        function set.Erase(self, TF)
            self.EraseInternal = TF;
        end
        
        function TF = get.Erase(self)
            TF = self.EraseInternal;
        end
        
        %------------------------------------------------------------------
        % MarkerSize
        function set.MarkerSize(self, val)
            val = round(val);
            if val >= 1
                % Marker size must be odd
                if mod(val,2) == 0
                    val = round(val + 1);
                end
                self.MarkerSizeInternal = val;
            end
        end
        
        function val = get.MarkerSize(self)
            val = self.MarkerSizeInternal;
        end
        
        %------------------------------------------------------------------
        % Selected
        function TF = get.Selected(self)
            TF = self.SelectedInternal;
        end
        
        function set.Selected(self, TF)
            if TF 
                if ~self.SelectedInternal
                    notify(self,'MaskSelected');
                end
            else
                if self.SelectedInternal
                    notify(self,'MaskDeselected');
                end
            end
            self.SelectedInternal = TF;
        end
        
        %------------------------------------------------------------------
        % Label
        function set.Label(self,val)
            self.LabelInternal = val;
        end
        
        function val = get.Label(self)
            val = self.LabelInternal;
        end
        
        %------------------------------------------------------------------
        % SemanticValue
        function set.SemanticValue(self,val)
            if val >= 0
                self.SemanticValueInternal = round(val);
            end
        end
        
        function val = get.SemanticValue(self)
            val = self.SemanticValueInternal;
        end
        
        %------------------------------------------------------------------
        % Valid
        function isValid = get.Valid(self)
            %A valid mask should not be empty
            isValid = ~isempty(self.MaskInternal);
        end
        
     end
     
     methods(Static,Access = private)
         
         function myPointer = pencilPointer
             myPointer = [NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
                 NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN;
                 NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,1,NaN,NaN;
                 NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,1,2,2,1,NaN;
                 NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,1,2,1,2,1,NaN;
                 NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,2,1,2,1,NaN,NaN;
                 NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN;
                 NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN;
                 NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN;
                 NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN;
                 NaN,NaN,1,1,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
                 NaN,NaN,1,2,1,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
                 NaN,1,2,2,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
                 NaN,1,2,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
                 1,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
                 1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN];
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
         
     end
    
end