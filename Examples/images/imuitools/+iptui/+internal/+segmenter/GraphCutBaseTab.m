classdef GraphCutBaseTab < handle
    
    % Tab with shared components for Lazy Snapping and GrabCut UIs
    
    % Copyright 2017 The MathWorks, Inc.
    
    %%Public
    properties (GetAccess = public, SetAccess = protected)
        Visible = false;
    end
    
    
    %%Tab Management
    properties (Access = protected)
        hTab
        hToolGroup
        hTabGroup
        hToolstrip
        hApp

        hGraphCutMaskOverlay
        
        HideDataBrowser = true;
    end
    
    %%UI Controls
    properties
        DrawSection
        ClearSection
        SuperpixelSection
        ForegroundButton
        BackgroundButton
        EraseButton
        MarkerSizeButton
        ClearButton
        ShowSuperpixelButton
        SuperpixelDensityButton
        SuperpixelSliderLabel
        
        PanZoomSection
        PanZoomMgr
        
        TextureSection
        TextureMgr
        
        ViewSection
        ViewMgr
        
        ApplyCloseSection
        ApplyCloseMgr
        
        OpacitySliderListener
        ShowBinaryButtonListener
        
        foreScribble
        backScribble
        Eraser
        EditMode
        MessageStatus = true;

        hForeLine
        hBackLine
        
        OriginalPointerBehavior
    end
    
    %%Algorithm
    properties
        ImageProperties
        GraphCutter
        NumSuperpixels
        NumRequestedSuperpixels
        BackgroundInd
        ForegroundInd
        Boundaries
        isGraphBuilt
        SuperpixelLabelMatrix
        
        ROI
        
        MarkerSize
        imSize
    end
    
    methods (Abstract)
        onApply(self);
        onClose(self);
        setMode(self, mode);
    end
    
    methods (Abstract, Access = protected)
        layoutTab(self);
        applyGraphCut(self);
        TF = isGraphCutValid(self);
        clearAll(self);
        cleanupAfterClear(self);
        installPointer(self);
        disableAllButtons(self);
        getCommandsForHistory(self);
        showMessagePane(self);
        hideMessagePane(self)
    end
    
    %%Public API
    methods
        function self = GraphCutBaseTab(toolGroup, tabGroup, theToolstrip, theApp, tabTag, varargin)

            if (nargin == 5)
                self.hTab = iptui.internal.segmenter.createTab(tabGroup, tabTag);
            else
                self.hTab = iptui.internal.segmenter.createTab(tabGroup, tabTag, varargin{:});
            end
            
            self.hToolGroup = toolGroup;
            self.hTabGroup = tabGroup;
            self.hToolstrip = theToolstrip;
            self.hApp = theApp;
            
            self.layoutTab();
            self.loadPointerImages();
            
            self.disableAllButtons();
            
        end
        
        function show(self)
            
            if self.HideDataBrowser
                md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.hideClient('DataBrowserContainer',self.hToolGroup.Name);
            end
            
            if (~self.isVisible())
                self.hTabGroup.add(self.hTab)
            end
            
            self.hApp.showLegend()
            
            self.makeActive()
            self.Visible = true;
        end
        
        function hide(self)
            
            self.hApp.hideLegend()
            
            if self.HideDataBrowser
                md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.showClient('DataBrowserContainer',self.hToolGroup.Name);
            end
            
            self.hTabGroup.remove(self.hTab)
            self.Visible = false;
        end
        
        function makeActive(self)
            self.hTabGroup.SelectedTab = self.hTab;
        end
        
    end
    
    %%Layout
    methods (Access = protected)
        
        function layoutDrawSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            
            % Foreground button        
            self.ForegroundButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('drawForeground'),Icon.GRAPHCUTFOREGROUND_24);
            self.ForegroundButton.Tag = 'btnForegroundButton';
            self.ForegroundButton.Description = getMessageString('foregroundTooltip');
            addlistener(self.ForegroundButton, 'ValueChanged', @(~,~)self.addForegroundScribble());

            % Background button
            self.BackgroundButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('drawBackground'),Icon.GRAPHCUTBACKGROUND_24);
            self.BackgroundButton.Tag = 'btnBackgroundButton';
            self.BackgroundButton.Description = getMessageString('backgroundTooltip');
            addlistener(self.BackgroundButton, 'ValueChanged', @(~,~)self.addBackgroundScribble());
            
            % Erase button
            self.EraseButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('erase'),Icon.GRAPHCUTERASE_24);
            self.EraseButton.Tag = 'btnEraseButton';
            self.EraseButton.Description = getMessageString('eraseTooltip');
            addlistener(self.EraseButton, 'ValueChanged', @(~,~)self.eraseScribbles());
            
            % Layout
            c = self.DrawSection.addColumn();
            c.add(self.ForegroundButton);
            c2 = self.DrawSection.addColumn();
            c2.add(self.BackgroundButton);
            c3 = self.DrawSection.addColumn();
            c3.add(self.EraseButton);
        end
        
        function layoutClearSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            
            % Erase All button
            self.ClearButton = matlab.ui.internal.toolstrip.DropDownButton(getMessageString('eraseAll'), ...
                Icon.CLEARALL_24);
            self.ClearButton.Tag = 'btnClearButton';
            self.ClearButton.Description = getMessageString('clearAllTooltip');

            % Drop down list
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getMessageString('clearForeground'));
            sub_item1.ShowDescription = false;
            addlistener(sub_item1, 'ItemPushed', @(~,~) self.clearForeground());
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getMessageString('clearBackground'));
            sub_item2.ShowDescription = false;
            addlistener(sub_item2, 'ItemPushed', @(~,~) self.clearBackground());
            
            sub_item3 = matlab.ui.internal.toolstrip.ListItem(getMessageString('clearAll'));
            sub_item3.ShowDescription = false;
            addlistener(sub_item3, 'ItemPushed', @(~,~) self.clearAll());
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            sub_popup.add(sub_item3);
            
            self.ClearButton.Popup = sub_popup;
            self.ClearButton.Popup.Tag = 'btnClearButtonPopup';            

            % Layout
            c = self.ClearSection.addColumn();
            c.add(self.ClearButton);
            
        end
        
        function layoutSuperpixelSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            % Show Superpixel Boundary Button
            iconPath = fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','View.png');
            self.ShowSuperpixelButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('showSuperpixelBoundaries'),...
                matlab.ui.internal.toolstrip.Icon(iconPath));
            self.ShowSuperpixelButton.Tag = 'btnShowSuperpixelButton';
            self.ShowSuperpixelButton.Description = getMessageString('showSuperpixelTooltip');
            addlistener(self.ShowSuperpixelButton, 'ValueChanged', @(~,~) self.showSuperpixelBoundaries());

            % Superpixel Density Slider
            self.SuperpixelDensityButton = matlab.ui.internal.toolstrip.Slider([0,100],50);
            self.SuperpixelDensityButton.Tag = 'btnSuperpixelDensityButton';
            self.SuperpixelDensityButton.Ticks = 0;
            self.SuperpixelDensityButton.Description = getMessageString('superpixelTooltip');
            addlistener(self.SuperpixelDensityButton,'ValueChanged',@(~,~) self.updateSuperpixelDensity() );

            self.SuperpixelSliderLabel = matlab.ui.internal.toolstrip.Label(getMessageString('superpixelDensity'));
            
            % Layout
            c = self.SuperpixelSection.addColumn('width',120,...
                'HorizontalAlignment','center');
            c.add(self.ShowSuperpixelButton);
            c.add(self.SuperpixelDensityButton);
            c.add(self.SuperpixelSliderLabel);
            
        end
        
        function section = addPanZoomSection(self)
            
            self.PanZoomMgr = iptui.internal.PanZoomManager(self.hTab,self.hApp);
            section = self.PanZoomMgr.Section;
            
            addlistener(self.PanZoomMgr.ZoomInButton,'ValueChanged',@(hobj,evt)self.updateScribbleInteraction());
            addlistener(self.PanZoomMgr.ZoomOutButton,'ValueChanged',@(hobj,evt)self.updateScribbleInteraction());
            addlistener(self.PanZoomMgr.PanButton,'ValueChanged',@(hobj,evt)self.updateScribbleInteraction());
            
        end
        
        function section = addViewSection(self)
            
            self.ViewMgr = iptui.internal.segmenter.ViewControlsManager(self.hTab);
            section = self.ViewMgr.Section;
            
            self.OpacitySliderListener = addlistener(self.ViewMgr.OpacitySlider, 'ValueChanged', @(~,~)self.opacitySliderMoved());
            self.ShowBinaryButtonListener = addlistener(self.ViewMgr.ShowBinaryButton, 'ValueChanged', @(hobj,~)self.showBinaryPress(hobj));
        end

    end
    
    %%Algorithm
    methods (Access = protected)
        
        function initializeGraphCut(self)
           
            self.imSize = size(self.hApp.getImage());
            
            % Set default number of superpixels
            self.setSuperpixelDensity(self.SuperpixelDensityButton.Value)
                
            self.defineSuperpixels();
            
        end
        
        function defineSuperpixels(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.hApp.updateStatusBarText(getMessageString('performingOversegmentation'));
            self.showAsBusy()
            
            % Number of superpixels can't exceed the number of pixels
            if self.NumRequestedSuperpixels > self.imSize(1)*self.imSize(2)
                self.NumRequestedSuperpixels = self.imSize(1)*self.imSize(2);
            end
            
            [self.SuperpixelLabelMatrix,self.NumSuperpixels] = superpixels(...
                self.hApp.getImage(),self.NumRequestedSuperpixels,'IsInputLab',self.hApp.wasRGB);
            
            self.Boundaries = boundarymask(self.SuperpixelLabelMatrix);
            
            self.isGraphBuilt = false;
            
            if self.isGraphCutValid()
                self.applyGraphCut();
            else
                self.hApp.updateStatusBarText('');
                self.unshowAsBusy()
            end
            
        end

    end
    
    %%Callbacks
    methods (Access = protected)
        
        function addForegroundScribble(self)
            
            if self.ForegroundButton.Value
                self.BackgroundButton.Value = false;
                self.EraseButton.Value = false;               
                self.EditMode = 'fore';
                self.unselectPanZoomTools()
                self.updateScribbleInteraction();
            elseif ~self.isDrawStateValid()
                self.ForegroundButton.Value = true;
            end
            
        end
        
        function addBackgroundScribble(self)
            
            if self.BackgroundButton.Value
                self.EraseButton.Value = false;
                self.ForegroundButton.Value = false;
                self.EditMode = 'back';
                self.unselectPanZoomTools()

                self.updateScribbleInteraction();
            elseif ~self.isDrawStateValid()
                self.BackgroundButton.Value = true;
            end
            
        end
        
        function eraseScribbles(self)
            
            if self.EraseButton.Value
                self.BackgroundButton.Value = false;
                self.ForegroundButton.Value = false;
                self.EditMode = 'erase';
                self.unselectPanZoomTools()

                self.updateScribbleInteraction();
            elseif ~self.isDrawStateValid()
                self.EraseButton.Value = true;
            end
            
        end
        
        function TF = isDrawStateValid(self)
            TF = any([self.ForegroundButton.Value,...
                self.BackgroundButton.Value,...
                self.EraseButton.Value]);
        end
        
        function clearForeground(self)
            
            self.unselectPanZoomTools()
            
            % This is necessary to allow any lines to finsh drawing before
            % they are deleted.
            drawnow;
            
            self.clearForegroundMask();
            self.MessageStatus = true;
            self.cleanupAfterClear();
            
        end
        
        function clearBackground(self)
            
            self.unselectPanZoomTools()
            
            % This is necessary to allow any lines to finsh drawing before
            % they are deleted.
            drawnow;
            
            self.clearBackgroundMask();
            self.MessageStatus = false;
            self.cleanupAfterClear();
            
        end
        
        function clearForegroundMask(self)
            self.ForegroundInd = [];
            if ~isempty(self.hForeLine)
                delete(self.hForeLine)
                self.hForeLine = [];
            end
        end
        
        function clearBackgroundMask(self)
            self.BackgroundInd = [];
            if ~isempty(self.hBackLine)
                delete(self.hBackLine)
                self.hBackLine = [];
            end
        end
        
        function updateSuperpixelDensity(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
          
            self.setSuperpixelDensity(self.SuperpixelDensityButton.Value)
            
            self.defineSuperpixels();
            self.isGraphBuilt = false;
            self.hGraphCutMaskOverlay.redrawBoundary(self.Boundaries);

        end
        
        function setSuperpixelDensity(self,val)            
            % Number of Superpixels = (numel/100)*(% of slider) + 50;
             self.NumRequestedSuperpixels = round((((self.imSize(1)*self.imSize(2))/100)*(val/100)) + 100);            
        end
        
        function showSuperpixelBoundaries(self)
            % Toggle view of superpixel boundaries
            self.unselectPanZoomTools()
            
            if self.ShowSuperpixelButton.Value
                self.hGraphCutMaskOverlay.setBoundaryVisibility('on');
            else
                self.hGraphCutMaskOverlay.setBoundaryVisibility('off');
            end
                       
        end
        
        function opacitySliderMoved(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            newOpacity = self.ViewMgr.Opacity;
            self.hApp.updateScrollPanelOpacity(newOpacity)
            
            if ~isempty(self.hGraphCutMaskOverlay)
                self.hGraphCutMaskOverlay.AlphaMaskOpacity = newOpacity/100;
                self.hGraphCutMaskOverlay.redrawBoundary(self.Boundaries)  
            end
            
            self.hToolstrip.setMode(AppMode.OpacityChanged)
        end
        
        function showBinaryPress(self,hobj)
            
            import iptui.internal.segmenter.AppMode;
            self.unselectPanZoomTools()
            
            if hobj.Value
                self.hApp.showBinary()
                self.ViewMgr.OpacitySlider.Enabled = false;
                self.ViewMgr.OpacityLabel.Enabled  = false;
                self.hToolstrip.setMode(AppMode.ShowBinary)
            else
                self.hApp.unshowBinary()
                self.ViewMgr.OpacitySlider.Enabled = true;
                self.ViewMgr.OpacityLabel.Enabled  = true;
                self.hToolstrip.setMode(AppMode.UnshowBinary)
            end
        end
        
    end
    
     %%Helpers
    methods (Access = protected)
        
        function reactToOpacityChange(self)
            % We move the opacity slider to reflect a change in opacity
            % level coming from a different tab.            
            newOpacity = self.hApp.getScrollPanelOpacity();
            self.ViewMgr.Opacity = 100*newOpacity;
            
        end
        
        function reactToShowBinary(self)
            self.ViewMgr.OpacitySlider.Enabled     = false;
            self.ViewMgr.ShowBinaryButton.Value = true;
        end
        
        function reactToUnshowBinary(self)
            self.ViewMgr.OpacitySlider.Enabled     = true;
            self.ViewMgr.ShowBinaryButton.Value = false;
        end
        
        function updateScribbleInteraction(self)
            
            % If one of the zoom/pan buttons is selected, disable the
            % drawing interaction. If it is unselected, enable the
            % drawing interaction.
            if self.PanZoomMgr.ZoomInButton.Value || self.PanZoomMgr.ZoomOutButton.Value || self.PanZoomMgr.PanButton.Value
                self.removePointer()
            else
                self.installPointer()
            end
        end
        
        function getOriginalPointer(self)
            hAx  = self.hApp.getScrollPanelAxes();
            self.OriginalPointerBehavior = iptGetPointerBehavior(hAx);
        end
        
        function respondToClick(self,src)
            
            if ~strcmp(src.SelectionType, 'normal')
                return;
            end
            
            if ~isa(src.CurrentObject,'matlab.graphics.primitive.Image')
                return;
            end
            
            clickLocation = src.CurrentPoint;
            axesPosition  = src.CurrentAxes.Position;
            if (isClickOutsideAxes(clickLocation, axesPosition))
                return;
            end
            
            hAx  = self.hApp.getScrollPanelAxes();
            hFig = self.hApp.getScrollPanelFigure();
            
            currentPoint = hAx.CurrentPoint;
            currentPoint = round(currentPoint(1,1:2));
            
            isPointOutsideROI = ~isempty(self.ROI) && self.ROI.Valid && ~self.ROI.insideROI(currentPoint(1),currentPoint(2));
            
            if isPointOutsideROI
                currentPoint = [NaN, NaN];
            end
            
            switch self.EditMode
                case 'fore'
                   colorSpec = [0.467 .675 0.188];
                   if isempty(self.hForeLine)
                       self.hForeLine = line('Parent',hAx,'Color',colorSpec,'Visible','off',...
                        'LineWidth',3,'HitTest','off','tag','scribbleLine',...
                        'PickableParts','none','HandleVisibility','off',...
                        'Marker','.','MarkerSize',20,'MarkerEdgeColor',colorSpec,...
                        'MarkerFaceColor',colorSpec);
                       self.hForeLine.XData = currentPoint(1);
                       self.hForeLine.YData = currentPoint(2);
                       set(self.hForeLine,'Visible','on');
                   else
                       self.hForeLine.XData(end+1) = NaN;
                       self.hForeLine.YData(end+1) = NaN;
                   end
                case 'back'
                   colorSpec = [0.635 0.078 0.184];
                   if isempty(self.hBackLine)
                       self.hBackLine = line('Parent',hAx,'Color',colorSpec,'Visible','off',...
                        'LineWidth',3,'HitTest','off','tag','scribbleLine',...
                        'PickableParts','none','HandleVisibility','off',...
                        'Marker','.','MarkerSize',20,'MarkerEdgeColor',colorSpec,...
                        'MarkerFaceColor',colorSpec);
                       self.hBackLine.XData = currentPoint(1);
                       self.hBackLine.YData = currentPoint(2);
                       set(self.hBackLine,'Visible','on');
                   else
                       self.hBackLine.XData(end+1) = NaN;
                       self.hBackLine.YData(end+1) = NaN;
                   end
            end
        
            if ~isempty(self.hForeLine)
                uistack(self.hForeLine,'top');
            end
            
            scribbleDrag();
            hFig.WindowButtonMotionFcn = @scribbleDrag;
            hFig.WindowButtonUpFcn = @scribbleUp;
        
            function scribbleDrag(~,~)
                
                currentPoint = hAx.CurrentPoint;
                currentPoint = round(currentPoint(1,1:2));
                axesPosition  = [1, 1, self.imSize(2)-1, self.imSize(1)-1];
                
                isPointOutsideROI = ~isempty(self.ROI) && self.ROI.Valid && ~self.ROI.insideROI(currentPoint(1),currentPoint(2));
                
                if isPointOutsideROI || (isClickOutsideAxes(currentPoint, axesPosition))
                    currentPoint = [NaN, NaN];
                end
                
                switch self.EditMode
                    case 'fore'
                        self.hForeLine.XData(end+1) = currentPoint(1);
                        self.hForeLine.YData(end+1) = currentPoint(2);
                    case 'back'
                        self.hBackLine.XData(end+1) = currentPoint(1);
                        self.hBackLine.YData(end+1) = currentPoint(2);
                    case 'erase'
                        XMin = currentPoint(1) - self.MarkerSize;
                        XMax = currentPoint(1) + self.MarkerSize;
                        YMin = currentPoint(2) - self.MarkerSize;
                        YMax = currentPoint(2) + self.MarkerSize;
                        
                        if ~isempty(self.hForeLine)
                        QueryForeData = (self.hForeLine.XData > XMin) & ...
                            (self.hForeLine.XData < XMax) & ...
                            (self.hForeLine.YData > YMin) & ...
                            (self.hForeLine.YData < YMax);
                        
                        self.hForeLine.XData(QueryForeData) = NaN;
                        self.hForeLine.YData(QueryForeData) = NaN;
                        end
                        
                        if ~isempty(self.hBackLine)
                        QueryBackData = (self.hBackLine.XData > XMin) & ...
                            (self.hBackLine.XData < XMax) & ...
                            (self.hBackLine.YData > YMin) & ...
                            (self.hBackLine.YData < YMax);
                        
                        self.hBackLine.XData(QueryBackData) = NaN;
                        self.hBackLine.YData(QueryBackData) = NaN;
                        end
                end

            end
        
            function scribbleUp(~,~)
                scribbleDrag();
                hFig.WindowButtonMotionFcn = [];
                hFig.WindowButtonUpFcn = [];
                
                emptyLinesBeforeDraw = isempty(self.ForegroundInd) && isempty(self.BackgroundInd);

                if ~isempty(self.hForeLine)
                   cleanXData = self.hForeLine.XData(~isnan(self.hForeLine.XData));
                   cleanYData = self.hForeLine.YData(~isnan(self.hForeLine.YData));
                   self.ForegroundInd = unique(sub2ind(self.imSize(1:2),cleanYData,cleanXData));
                end

                if ~isempty(self.hBackLine)
                   cleanXData = self.hBackLine.XData(~isnan(self.hBackLine.XData));
                   cleanYData = self.hBackLine.YData(~isnan(self.hBackLine.YData));
                   self.BackgroundInd = unique(sub2ind(self.imSize(1:2),cleanYData,cleanXData));
                end
                
                emptyLinesAfterDraw = isempty(self.ForegroundInd) && isempty(self.BackgroundInd);
                noMarksAdded = emptyLinesBeforeDraw && emptyLinesAfterDraw;
                
                if noMarksAdded
                    % No scribbles before this draw interaction, no
                    % scribbles after. Nothing to do here.
                    return;
                end
                
                if self.isGraphCutValid()
                    self.applyGraphCut();
                    self.hideMessagePane();
                else
                    if isempty(self.BackgroundInd)
                        self.MessageStatus = false;
                    else
                        self.MessageStatus = true;
                    end
                    self.showMessagePane();
                    self.disableApply();
                    self.hApp.hideLegend();
                    self.hApp.ScrollPanel.resetPreviewMask();
                end
            end
        
        end
        
        function removePointer(self)
        
            hAx = self.hApp.getScrollPanelAxes();
            iptSetPointerBehavior(hAx,self.OriginalPointerBehavior);
            
            hFig = self.hApp.getScrollPanelFigure();
            hIm  = self.hApp.getScrollPanelImage();
            
            % Reset button up function to default.
            hFig.WindowButtonDownFcn = [];
            hIm.ButtonDownFcn = [];
        end
        
        function unselectPanZoomTools(self)            
            self.PanZoomMgr.unselectAll();
        end
        
        function TF = isVisible(self)
            existingTabs = self.hToolGroup.TabNames;
            TF = any(strcmp(existingTabs, self.hTab));
        end
        
        function updateImageProperties(self)
            im = self.hApp.getImage();
            
            self.ImageProperties = struct(...
                'ImageSize',size(im),...
                'DataType',class(im),...
                'DataRange',[min(im(:)) max(im(:))]);
        end
            
        function enableApply(self)
            self.ApplyCloseMgr.ApplyButton.Enabled = true;
        end
        
        function disableApply(self)
            self.ApplyCloseMgr.ApplyButton.Enabled = false;
        end
        
        function showAsBusy(self)
            self.hToolGroup.setWaiting(true);
        end
        
        function unshowAsBusy(self)
            self.hToolGroup.setWaiting(false)
        end
        
        function loadPointerImages(self)
            
            self.foreScribble = [NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
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
            
            self.Eraser = NaN(16);
            self.Eraser(5:12,5:12) = 1;
            self.Eraser(6:11,6:11) = 2;    

        end
        
    end
    
end

function TF = isClickOutsideAxes(clickLocation, axesPosition)
TF = (clickLocation(1) < axesPosition(1)) || ...
     (clickLocation(1) > (axesPosition(1) + axesPosition(3))) || ...
     (clickLocation(2) < axesPosition(2)) || ...
     (clickLocation(2) > (axesPosition(2)+axesPosition(4)));
end