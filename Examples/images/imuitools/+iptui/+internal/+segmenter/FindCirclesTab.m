classdef FindCirclesTab < handle
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    %%Public
    properties (GetAccess = public, SetAccess = private)
        Visible = false;
    end
    
    %%Tab Management
    properties (Access = private)
        hTab
        hToolGroup
        hTabGroup
        hToolstrip
        hApp
    end
    
    %%UI Controls
    properties
        DiameterSection
        MinDiameterEditBox
        MinDiameterLabel
        MaxDiameterEditBox
        MaxDiameterLabel
        
        SensitivitySlider
        SensitivityLabel
        
        ObjectPolarityLabel
        ObjectPolarityCombo
        
        MeasureSection
        MeasureButton
        
        RunSection
        RunButton
        
        PanZoomSection
        PanZoomMgr
        
        ViewSection
        ViewMgr
        
        ApplyCloseSection
        ApplyCloseMgr
        
        ImageSize
        
        OriginalPointerBehavior
        
        Timer
    end
    
    %%Algorithm
    properties
        MaxVal
        MinRadius = 25;
        MaxRadius = 75;
        ObjectPolarityItems = {'bright','dark'};
        
        Iterations
        CurrentIteration
        
        MeasurementLine
        MeasurementDisplay

        ContinueSegmentationFlag
        StopSegmentationFlag
        DiscardSegmentation
        
        CurrentMask
    end
    
    %%Public API
    methods
        function self = FindCirclesTab(toolGroup, tabGroup, theToolstrip, theApp, varargin)

            if (nargin == 3)
                self.hTab = iptui.internal.segmenter.createTab(tabGroup, 'findCirclesTab');
            else
                self.hTab = iptui.internal.segmenter.createTab(tabGroup, 'findCirclesTab', varargin{:});
            end
            
            self.hToolGroup = toolGroup;
            self.hTabGroup = tabGroup;
            self.hToolstrip = theToolstrip;
            self.hApp = theApp;
            
            self.layoutTab();
            
            self.disableAllButtons();
            
            self.Timer = timer('TimerFcn',@(~,~) self.applyFindCircles(),...
                    'ObjectVisibility','off','ExecutionMode','singleShot',...
                    'Tag','ImageSegmenterFindCirclesTimer','StartDelay',0.01);
                
        end
        
        function show(self)
            
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.hideClient('DataBrowserContainer',self.hToolGroup.Name);
            
            if (~self.isVisible())
                self.hTabGroup.add(self.hTab)
            end
                        
            self.makeActive()
            self.Visible = true;
        end
        
        function hide(self)
            
            self.hApp.hideLegend()
            
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.showClient('DataBrowserContainer',self.hToolGroup.Name);
            
            self.hTabGroup.remove(self.hTab)
            self.Visible = false;
        end
        
        function makeActive(self)
            self.hTabGroup.SelectedTab = self.hTab;
        end
        
        function deleteTimer(self)
            if ~isempty(self.Timer) && isvalid(self.Timer)
                stop(self.Timer)
                delete(self.Timer)
            end
        end
        
        function setMode(self, mode)
            import iptui.internal.segmenter.AppMode;
            
            switch (mode)
            case AppMode.FindCirclesOpened
                 self.DiscardSegmentation = false;
                 self.ContinueSegmentationFlag = true;
                 self.ImageSize = size(self.hApp.getImage());
                 resetRadii(self);
                 self.enableAllButtons();
                 
            case AppMode.FindCirclesDone
                 self.MeasureButton.Value = false;
                                 
            case {AppMode.NoImageLoaded, ...
                  AppMode.Drawing, ...
                  AppMode.ActiveContoursRunning, ...
                  AppMode.FloodFillSelection, ...
                  AppMode.DrawingDone, ...
                  AppMode.ActiveContoursDone, ...
                  AppMode.FloodFillDone, ...
                  AppMode.HistoryIsEmpty, ...
                  AppMode.HistoryIsNotEmpty, ...
                  AppMode.ThresholdImage, ...
                  AppMode.ThresholdDone, ...
                  AppMode.MorphologyDone, ...
                  AppMode.ActiveContoursIterationsDone, ...
                  AppMode.MorphImage,AppMode.MorphTabOpened,...
                  AppMode.ActiveContoursTabOpened,...
                  AppMode.ActiveContoursNoMask,...
                  AppMode.GraphCutOpened,...
                  AppMode.GraphCutDone,...
                  AppMode.ImageLoaded,...
                  AppMode.ToggleTexture,...
                  AppMode.GrabCutOpened,...
                  AppMode.GrabCutDone}
                %No-op
                
            case AppMode.NoMasks
                %If the app enters a state with no mask, make sure we set
                %the state back to unshow binary.
                if self.ViewMgr.ShowBinaryButton.Enabled
                    self.reactToUnshowBinary();
                    % This is needed to ensure that state is settled after
                    % unshow binary.
                    drawnow;
                end
                self.ViewMgr.Enabled = false;
                
            case AppMode.MasksExist
                self.ViewMgr.Enabled = true;

            case AppMode.OpacityChanged
                self.reactToOpacityChange()
            case AppMode.ShowBinary
                self.reactToShowBinary()
            case AppMode.UnshowBinary
                self.reactToUnshowBinary()
            end
            
        end
        
        function applyAndClose(self)
            self.onApply();
            self.onClose();
        end
        
        function onApply(self)
            self.unselectPanZoomTools()
            
            self.hApp.commitTemporaryHistory()
            self.disableApply();
            
        end
        
        function onClose(self)
            
            import iptui.internal.segmenter.AppMode;
            self.hApp.updateStatusBarText('');
            self.hApp.clearTemporaryHistory()
            
            self.unselectPanZoomTools()
            
            % This ensures that zoom tools have settled down before the
            % marker pointer is removed.
            drawnow;
            
            self.hToolstrip.showSegmentTab()
            self.hToolstrip.hideFindCirclesTab()
            self.disableAllButtons();
            self.hToolstrip.setMode(AppMode.FindCirclesDone);
        end
    end
    
    %%Layout
    methods (Access = private)
        
        function layoutTab(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.MeasureSection      = self.hTab.addSection(getMessageString('measure'));
            self.MeasureSection.Tag  = 'Measure Section';
            self.DiameterSection     = self.hTab.addSection(getMessageString('findCircles'));
            self.DiameterSection.Tag = 'Settings Section';
            self.PanZoomSection      = self.addPanZoomSection();
            self.ViewSection         = self.addViewSection();
            self.ApplyCloseSection   = self.addApplyCloseSection();
            
            self.layoutMeasureSection();
            self.layoutDiameterSection();
            
        end
        
        function layoutDiameterSection(self)

            import iptui.internal.segmenter.getMessageString;
            import iptui.internal.utilities.setToolTipText;
            import images.internal.app.Icon;
            
            % Min Diameter
            self.MinDiameterEditBox = matlab.ui.internal.toolstrip.EditField(num2str(2*self.MinRadius));
            self.MinDiameterEditBox.Tag = 'btnMinDiameterEditBox';
            self.MinDiameterEditBox.Description = getMessageString('minDiameterTooltip');
            addlistener(self.MinDiameterEditBox,'ValueChanged', @(hobj,~) self.validateMinDiameter(hobj));
            
            % Min Label
            self.MinDiameterLabel = matlab.ui.internal.toolstrip.Label(getMessageString('minDiameter'));
            self.MinDiameterLabel.Tag = 'labelMinDiameter';
            self.MinDiameterLabel.Description = getMessageString('minDiameterTooltip');
            
            % Max Label
            self.MaxDiameterLabel = matlab.ui.internal.toolstrip.Label(getMessageString('maxDiameter'));
            self.MaxDiameterLabel.Tag = 'labelMaxDiameter';
            self.MaxDiameterLabel.Description = getMessageString('maxDiameterTooltip');
            
            % Max Diameter
            self.MaxDiameterEditBox = matlab.ui.internal.toolstrip.EditField(num2str(2*self.MaxRadius));
            self.MaxDiameterEditBox.Tag = 'btnMaxDiameterEditBox';
            self.MaxDiameterEditBox.Description = getMessageString('maxDiameterTooltip');
            addlistener(self.MaxDiameterEditBox, 'ValueChanged', @(hobj,~) self.validateMaxDiameter(hobj));
            
            % Polarity Label
            self.ObjectPolarityLabel = matlab.ui.internal.toolstrip.Label(getMessageString('fgPolarity'));
            self.ObjectPolarityLabel.Tag = 'labelObjPolarity';
            self.ObjectPolarityLabel.Description = getMessageString('fgPolarityTooltip');
            
            % Polarity Combo Box
            self.ObjectPolarityCombo = matlab.ui.internal.toolstrip.DropDown({getMessageString('bright');getMessageString('dark')});
            self.ObjectPolarityCombo.SelectedIndex = 1;
            self.ObjectPolarityCombo.Tag = 'comboObjPolarity';
            self.ObjectPolarityCombo.Description = getMessageString('fgPolarityTooltip');
            
            % Sensitivity Slider
            self.SensitivitySlider = matlab.ui.internal.toolstrip.Slider([0,100],85);
            self.SensitivitySlider.Ticks = 0;
            self.SensitivitySlider.Tag = 'btnSensitivitySlider';
            self.SensitivitySlider.Description = getMessageString('sensitivityFindCirclesTooltip');
            
            self.SensitivityLabel = matlab.ui.internal.toolstrip.Label(getMessageString('sensitivity'));
            
            %Run Button
            self.RunButton = matlab.ui.internal.toolstrip.Button(getMessageString('run'), matlab.ui.internal.toolstrip.Icon.RUN_24);
            self.RunButton.Tag = 'btnRun';
            self.RunButton.Description = getMessageString('runTooltip');
            addlistener(self.RunButton, 'ButtonPushed', @(~,~) self.updateSegmentState());

            % Layout
            c = self.DiameterSection.addColumn(...
                'HorizontalAlignment','right');
            c.add(self.MinDiameterLabel);
            c.add(self.MaxDiameterLabel);
            c.add(self.ObjectPolarityLabel);
            c2 = self.DiameterSection.addColumn('width',60);
            c2.add(self.MinDiameterEditBox);
            c2.add(self.MaxDiameterEditBox);
            c2.add(self.ObjectPolarityCombo);
            c3 = self.DiameterSection.addColumn('width',100,...
                'HorizontalAlignment','center');
            c3.add(self.SensitivityLabel);
            c3.add(self.SensitivitySlider);
            c4 = self.DiameterSection.addColumn();
            c4.add(self.RunButton);

        end
        
        function layoutMeasureSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;

            % Run Button
            self.MeasureButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('measureDiameter'), Icon.RULER_24);
            self.MeasureButton.Tag = 'btnRuler';
            self.MeasureButton.Description = getMessageString('measureDiameterTooltip');     
            addlistener(self.MeasureButton, 'ValueChanged', @(~,~) self.measureCallback());
            
            % Layout
            c = self.MeasureSection.addColumn();
            c.add(self.MeasureButton);
            
        end
        
        function section = addPanZoomSection(self)
            
            self.PanZoomMgr = iptui.internal.PanZoomManager(self.hTab,self.hApp);
            section = self.PanZoomMgr.Section;
            
            addlistener(self.PanZoomMgr.ZoomInButton,'ValueChanged',@(hobj,evt)self.updateMeasurementInteraction());
            addlistener(self.PanZoomMgr.ZoomOutButton,'ValueChanged',@(hobj,evt)self.updateMeasurementInteraction());
            addlistener(self.PanZoomMgr.PanButton,'ValueChanged',@(hobj,evt)self.updateMeasurementInteraction());
            
        end
        
        function section = addViewSection(self)
            
            self.ViewMgr = iptui.internal.segmenter.ViewControlsManager(self.hTab);
            section = self.ViewMgr.Section;
            
            addlistener(self.ViewMgr.OpacitySlider, 'ValueChanged', @(~,~)self.opacitySliderMoved());
            addlistener(self.ViewMgr.ShowBinaryButton, 'ValueChanged', @(hobj,~)self.showBinaryPress(hobj));
        end
        
        function section = addApplyCloseSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            tabName = getMessageString('findCirclesTab');
            
            useApplyAndClose = true;
            
            self.ApplyCloseMgr = iptui.internal.ApplyCloseManager(self.hTab, tabName, useApplyAndClose);
            section = self.ApplyCloseMgr.Section;
            
            addlistener(self.ApplyCloseMgr.ApplyButton,'ButtonPushed',@(~,~)self.applyAndClose());
            addlistener(self.ApplyCloseMgr.CloseButton,'ButtonPushed',@(~,~)self.onClose());
        end
    end
    
    %%Algorithm
    methods (Access = private)
        
        function applyFindCircles(self)      
            
            import iptui.internal.segmenter.AppMode;
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            self.MeasureButton.Value = false;
            self.measureCallback();
            self.disableAllButtons();
            self.disableApply();
            self.hApp.updateStatusBarText(getMessageString('detectingCircles'));
            
            self.StopSegmentationFlag = false;
            self.updateSegmentButtonIcon('stop')
            drawnow;
            self.hApp.clearTemporaryHistory()
            
            % Ignore all warnings
            warnstate = warning('off','all');
            resetWarningObj = onCleanup(@()warning(warnstate));

            idx = self.ObjectPolarityCombo.SelectedIndex;
            objectPolarity  = self.ObjectPolarityItems{idx};
            
            sensitivityVal = self.SensitivitySlider.Value / 100;
            
            [centers,radii,~] = imfindcircles(self.hApp.getRGBImage(),...
                [self.MinRadius self.MaxRadius],...
                'ObjectPolarity',objectPolarity,'Sensitivity',sensitivityVal);
            
            % Flush event queue for listeners in view to process and
            % update graphics in response to changes in mask and
            % current iteration count.
            drawnow();
            
            if ~isvalid(self.hApp)
                return;
            end
                
            if self.StopSegmentationFlag
                self.hApp.updateStatusBarText('');
                self.updateSegmentButtonIcon('segment');
                self.enableAllButtons();
                return;
            end
            
            mask = false(self.ImageSize(1:2));
                
            if ~isempty(centers) && ~self.StopSegmentationFlag
                mask = self.createMaskFromCircles(mask,centers,radii);
                if ~isvalid(self.hApp)
                    return;
                end
                self.hToolstrip.setMode(AppMode.MasksExist)
                self.hApp.showLegend();
                if ~self.DiscardSegmentation
                    self.hApp.setTemporaryHistory(mask, ...
                         getMessageString('findCirclesComment'), self.getCommandsForHistory(objectPolarity));
                end
                self.hApp.ScrollPanel.resetCommittedMask();
                self.enableApply();
                self.hApp.updateStatusBarText('');
            else
                self.hApp.updateStatusBarText(getMessageString('noCircles'));
                self.hToolstrip.setMode(AppMode.NoMasks)
                self.disableApply();
                self.hApp.ScrollPanel.resetPreviewMask();
            end
            
            self.updateSegmentButtonIcon('segment')
            self.enableAllButtons();
            
                                    
        end
        
        function mask = createMaskFromCircles(self,mask,centers,radii)

            import iptui.internal.segmenter.getMessageString;
            
            [X,Y] = meshgrid(1:size(mask,2),1:size(mask,1));
            self.Iterations = length(radii);
            for n = 1:self.Iterations
                self.CurrentIteration = n;
                mask = mask | (hypot(X-centers(n,1),Y-centers(n,2)) <= radii(n));
                if ~isvalid(self.hApp)
                    return;
                end
                self.hApp.updateScrollPanelPreview(mask)
                self.hApp.updateStatusBarText(getMessageString('iterationStatusText', num2str(n), num2str(self.Iterations)));
                
                % Flush event queue for listeners in view to process and
                % update graphics in response to changes in mask and
                % current iteration count.
                drawnow();
                if self.StopSegmentationFlag
                    break;
                end
            end

        end
        
        function updateSegmentState(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            if self.ContinueSegmentationFlag
                start(self.Timer);
            else
                self.stopSegmentationAlgorithm();
            end
        end
        
        function updateSegmentButtonIcon(self, name)
            
            import iptui.internal.segmenter.getMessageString;
            switch name
                case 'segment'
                    self.RunButton.Icon =  matlab.ui.internal.toolstrip.Icon.RUN_24;
                    self.RunButton.Text = 'Run';
                    self.ContinueSegmentationFlag = true;
                case 'stop'
                    self.RunButton.Icon =  matlab.ui.internal.toolstrip.Icon.END_24;
                    self.RunButton.Text = getMessageString('stopSegmentation');
                    self.ContinueSegmentationFlag = false;
            end
        end
        
        function stopSegmentationAlgorithm(self)
            self.StopSegmentationFlag = true;
        end
        
        function stopSegmentationAlgorithmAndDiscard(self)
            self.stopSegmentationAlgorithm()
            self.DiscardSegmentation = true;
        end
        
        function resetRadii(self)
            
            self.MaxVal = round(hypot(self.ImageSize(1),self.ImageSize(2))/2);
            if self.MaxRadius > self.MaxVal
                self.MaxRadius = self.MaxVal;
                self.MaxDiameterEditBox.Value = num2str(2*self.MaxVal);
            end
            if self.MinRadius > self.MaxVal
                self.MinRadius = self.MaxVal;
                self.MinDiameterEditBox.Value = num2str(2*self.MaxVal);
            end
            
        end

    end
    
    %%Callbacks
    methods (Access = private)
        
        function measureCallback(self)
            
            self.unselectPanZoomTools();
            drawnow;
            
            if self.MeasureButton.Value
                self.updateMeasurementInteraction();
            else
                self.removePointer();
                delete(self.MeasurementLine)
                self.MeasurementLine = [];
                delete(self.MeasurementDisplay)
                self.MeasurementDisplay = [];
                drawnow;
            end
            
        end
        
        function validateMinDiameter(self,obj)
            value = round(str2double(obj.Value)/2);
            if ~isfinite(value) || ~isreal(value) || value <= 0
                self.MinDiameterEditBox.Value = num2str(2*self.MinRadius);
                return;
            end

            if value > self.MaxVal
                value = self.MaxVal;
            end
            
            if value > self.MaxRadius
                value = self.MaxRadius;
            end
            
            self.MinRadius = value;
            self.MinDiameterEditBox.Value = num2str(2*value);
            
        end
        
        function validateMaxDiameter(self,obj)
            value = round(str2double(obj.Value)/2);
            if ~isfinite(value) || ~isreal(value) || value <= 0
                self.MaxDiameterEditBox.Value = num2str(2*self.MaxRadius);
                return;
            end
            
            if value > self.MaxVal
                value = self.MaxVal;
            end
            
            if value < self.MinRadius
                value = self.MinRadius;
            end

            self.MaxRadius = value;
            self.MaxDiameterEditBox.Value = num2str(2*value);
            
        end
        
        function opacitySliderMoved(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            newOpacity = self.ViewMgr.Opacity;
            self.hApp.updateScrollPanelOpacity(newOpacity)
            
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
        
        function respondToClick(self,src)
            
            if ~strcmp(src.SelectionType, 'normal')
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
            
            if isempty(self.MeasurementLine)
                self.MeasurementLine = line('Parent',hAx,'Color',[0 0 0],'Visible','off',...
                    'LineWidth',3,'HitTest','off','tag','scribbleLine',...
                    'PickableParts','none','HandleVisibility','off',...
                    'Marker','.','MarkerSize',20,'MarkerEdgeColor',[1 1 1],...
                    'MarkerFaceColor',[1 1 1]);
                self.MeasurementLine.XData = currentPoint(1);
                self.MeasurementLine.YData = currentPoint(2);
                set(self.MeasurementLine,'Visible','on');
            end
            
            set(self.MeasurementLine,'XData',currentPoint(1),'YData',currentPoint(2));
            
            if isempty(self.MeasurementDisplay)
                self.MeasurementDisplay = text('Parent',hAx,'String','0',...
                    'Visible','off','Color',[0 0 0],'EdgeColor',[0 0 0],...
                    'BackgroundColor',[1 1 1],'Position',currentPoint,...
                    'HandleVisibility','off','PickableParts','none',...
                    'HitTest','off');
                set(self.MeasurementDisplay,'Visible','on')
            end    
            
            scribbleDrag();
            hFig.WindowButtonMotionFcn = @scribbleDrag;
            hFig.WindowButtonUpFcn = @scribbleUp;
        
            function scribbleDrag(~,~)
                
                currentPoint = hAx.CurrentPoint;
                currentPoint = round(currentPoint(1,1:2));
                axesPosition  = [1, 1, self.ImageSize(2)-1, self.ImageSize(1)-1];
                
                if (isClickOutsideAxes(currentPoint, axesPosition))
                    return;
                end
                
                self.MeasurementLine.XData(2) = currentPoint(1);
                self.MeasurementLine.YData(2) = currentPoint(2);
                
                diam = hypot((self.MeasurementLine.XData(2)-self.MeasurementLine.XData(1)),...
                    self.MeasurementLine.YData(2)-self.MeasurementLine.YData(1));
                
                midpoints = [(self.MeasurementLine.XData(2)+self.MeasurementLine.XData(1))/2, (self.MeasurementLine.YData(2)+self.MeasurementLine.YData(1))/2];
                
                set(self.MeasurementDisplay,'Position',midpoints,'String',sprintf('%0.2f pixels',diam));

            end
        
            function scribbleUp(~,~)
                scribbleDrag();
                hFig.WindowButtonMotionFcn = [];
                hFig.WindowButtonUpFcn = [];
            end
            
        end
        
    end
    
     %%Helpers
    methods (Access = private)
        
        function reactToOpacityChange(self)
            % We move the opacity slider to reflect a change in opacity
            % level coming from a different tab.            
            newOpacity = self.hApp.getScrollPanelOpacity();
            self.ViewMgr.Opacity = 100*newOpacity;
            
        end
        
        function reactToShowBinary(self)
            self.ViewMgr.OpacitySlider.Enabled  = false;
            self.ViewMgr.ShowBinaryButton.Value = true;
        end
        
        function reactToUnshowBinary(self)
            self.ViewMgr.OpacitySlider.Enabled  = true;
            self.ViewMgr.ShowBinaryButton.Value = false;
        end
        
        function unselectPanZoomTools(self)            
            self.PanZoomMgr.unselectAll();
        end
        
        function TF = isVisible(self)
            existingTabs = self.hToolGroup.TabNames;
            TF = any(strcmp(existingTabs, self.hTab));
        end
        
        function enableAllButtons(self)

            self.PanZoomMgr.Enabled                             = true;
            self.ApplyCloseMgr.CloseButton.Enabled              = true;
            self.MinDiameterEditBox.Enabled                     = true;
            self.MaxDiameterEditBox.Enabled                     = true;
            self.SensitivitySlider.Enabled                      = true;
            self.ObjectPolarityCombo.Enabled                    = true;
            self.MeasureButton.Enabled                          = true;
            
        end
        
        function disableAllButtons(self)

            self.ApplyCloseMgr.ApplyButton.Enabled              = false;
            self.ApplyCloseMgr.CloseButton.Enabled              = false;
            self.MinDiameterEditBox.Enabled                     = false;
            self.MaxDiameterEditBox.Enabled                     = false;
            self.SensitivitySlider.Enabled                      = false;
            self.ObjectPolarityCombo.Enabled                    = false;
            self.MeasureButton.Enabled                          = false;
            
        end
            
        function enableApply(self)
            self.ApplyCloseMgr.ApplyButton.Enabled = true;
        end
        
        function disableApply(self)
            self.ApplyCloseMgr.ApplyButton.Enabled = false;
        end
        
        function updateMeasurementInteraction(self)
            
            % If one of the zoom/pan buttons is selected, disable the
            % drawing interaction. If it is unselected, enable the
            % drawing interaction.
            if self.PanZoomMgr.ZoomInButton.Value || self.PanZoomMgr.ZoomOutButton.Value || self.PanZoomMgr.PanButton.Value
                self.removePointer()
            elseif self.MeasureButton.Value
                self.installPointer()
            end
        end
        
        function getOriginalPointer(self)
            hAx  = self.hApp.getScrollPanelAxes();
            self.OriginalPointerBehavior = iptGetPointerBehavior(hAx);
        end
        
        function installPointer(self)
            
            hAx  = self.hApp.getScrollPanelAxes();
            hFig = self.hApp.getScrollPanelFigure();
            
            % Setup pointer manager for the figure
            iptPointerManager(hFig);
            % Install new pointer behavior
            iptSetPointerBehavior(hAx,@(src,evt) set(src,'Pointer','crosshair'));
            
            % Add listener to button up
            hFig.WindowButtonDownFcn = @(src,~) self.respondToClick(src);
            
        end
        
        function removePointer(self)
        
            hAx = self.hApp.getScrollPanelAxes();
            iptSetPointerBehavior(hAx,self.OriginalPointerBehavior);
            
            hFig = self.hApp.getScrollPanelFigure();
            
            % Reset button up function to default.
            hFig.WindowButtonDownFcn = '';
        end
        
        function commands = getCommandsForHistory(self,polarity)
        
           if self.hApp.wasRGB
               varname = 'RGB';
           else
               varname = 'X';
           end
           
           sensitivityVal = self.SensitivitySlider.Value / 100;
            
           commands{1} = sprintf('[centers,radii,~] = imfindcircles(%s,[%d %d],''ObjectPolarity'',''%s'',''Sensitivity'',%0.2f);',varname,self.MinRadius,self.MaxRadius,polarity,sensitivityVal);
           commands{2} = sprintf('BW = false(size(%s,1),size(%s,2));',varname,varname);
           commands{3} = '[Xgrid,Ygrid] = meshgrid(1:size(BW,2),1:size(BW,1));';
           if self.CurrentIteration > 1
               commands{4} = sprintf('for n = 1:%d',self.CurrentIteration);
               commands{5} = '    BW = BW | (hypot(Xgrid-centers(n,1),Ygrid-centers(n,2)) <= radii(n));';
               commands{6} = 'end';
           else
               commands{4} = 'BW = BW | (hypot(Xgrid-centers(1,1),Ygrid-centers(1,2)) <= radii(1));';
           end

        end

        
    end
    
end

function TF = isClickOutsideAxes(clickLocation, axesPosition)
TF = (clickLocation(1) < axesPosition(1)) || ...
     (clickLocation(1) > (axesPosition(1) + axesPosition(3))) || ...
     (clickLocation(2) < axesPosition(2)) || ...
     (clickLocation(2) > (axesPosition(2)+axesPosition(4)));
end