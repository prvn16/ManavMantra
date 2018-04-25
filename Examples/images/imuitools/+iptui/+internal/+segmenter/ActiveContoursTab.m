classdef ActiveContoursTab < handle
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    %%Public
    properties (GetAccess = public, SetAccess = private)
        Visible = false;
    end
    
    %%Tab Management
    properties (Access = private)
        hTab
        hToolGroup
        hTabGroup
        hApp
        hToolstrip
    end
    
    %%UI Controls
    properties (Access = private)
        ActiveContoursSection
        IterationsLabel
        IterationsText
        MethodLabel
        MethodButton
        EvolveButton
        
        PanZoomSection
        PanZoomMgr
        
        ViewSection
        ViewMgr
        
        TextureSection
        TextureMgr
        
        ApplyCloseSection
        ApplyCloseMgr
        
        ShowBinaryButtonListener
        OpacitySliderListener
        
        Timer
    end
    
    %%Algorithm
    properties (Access = private)
        Algorithm
        Iterations
        CurrentIteration
        
        Speed
        Evolver
        
        % Flag to notify segment button about intention to stop
        % segmentation.
        ContinueSegmentationFlag
        
        StopSegmentationFlag
        DiscardSegmentation
        
        CurrentMask
    end
    
    %%Public API
    methods
        function self = ActiveContoursTab(toolGroup, tabGroup, theToolstrip, theApp, varargin)

            if (nargin == 3)
                self.hTab = iptui.internal.segmenter.createTab(tabGroup,'activeContoursTab');
            else
                self.hTab = iptui.internal.segmenter.createTab(tabGroup,'activeContoursTab', varargin{:});
            end
            
            self.hToolGroup = toolGroup;
            self.hTabGroup = tabGroup;
            self.hToolstrip = theToolstrip;
            self.hApp = theApp;
            
            self.layoutTab();
            self.Algorithm = 'Chan-Vese'; % Set default algorithm
            
            self.Timer = timer('TimerFcn',@(~,~) self.evolveButtonCallback(),...
                    'ObjectVisibility','off','ExecutionMode','singleShot',...
                    'Tag','ImageSegmenterActiveContourTimer','StartDelay',0.01);
        end
        
        function show(self)
            self.hApp.showLegend()
            self.setMethodForColorImages()
            self.hTabGroup.add(self.hTab)
            self.Visible = true;
        end
        
        function hide(self)
            self.hApp.hideLegend()
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
                case {AppMode.NoImageLoaded, AppMode.NoMasks}
                    %If the app enters a state with no mask, make sure we set
                    %the state back to unshow binary.
                    if self.ViewMgr.ShowBinaryButton.Enabled
                        self.reactToUnshowBinary();
                        % This is needed to ensure that state is settled after
                        % unshow binary.
                        drawnow;
                    end
                    self.disableAllButtons()
                    self.enableClose()
                case {AppMode.MasksExist}
                    self.enableAllButtons()
                    self.disableApply()
                case {AppMode.ImageLoaded, AppMode.Drawing,...
                      AppMode.HistoryIsNotEmpty,...
                      AppMode.ThresholdImage, AppMode.ThresholdDone,...
                      AppMode.FloodFillDone, AppMode.MorphologyDone,...
                      AppMode.FloodFillTabOpened,...
                      AppMode.FloodFillSelection, AppMode.MorphImage,...
                      AppMode.MorphTabOpened, AppMode.GraphCutOpened,...
                      AppMode.GraphCutDone, AppMode.FindCirclesOpened,...
                      AppMode.FindCirclesDone, AppMode.GrabCutOpened,...
                      AppMode.GrabCutDone}
                    % No-op.
                case AppMode.ActiveContoursDone
                    self.hApp.ActiveContoursIsRunning = false;
                case {AppMode.DrawingDone}
                    self.enableAllButtons()
                case {AppMode.ActiveContoursTabOpened}
                    self.DiscardSegmentation = false;
                    self.ContinueSegmentationFlag = true;
                    self.disableApply()
                case {AppMode.ActiveContoursRunning}
                    self.hApp.ActiveContoursIsRunning = true;
                    self.disableActiveContoursSection();
                    self.setEvolveToStop()
                    self.disableApply()
                case {AppMode.ActiveContoursIterationsDone}
                    self.hApp.ActiveContoursIsRunning = false;
                    self.enableActiveContoursSection();
                    self.setStopToEvolve()
                    self.enableApply()
                case {AppMode.ActiveContoursNoMask}
                    self.enableActiveContoursSection();
                    self.disableApply()
                case AppMode.OpacityChanged
                    self.reactToOpacityChange()
                case AppMode.ShowBinary
                    self.reactToShowBinary()
                case AppMode.UnshowBinary
                    self.reactToUnshowBinary()
                case AppMode.ToggleTexture
                    self.TextureMgr.updateTextureState(self.hApp.Session.UseTexture);
                    self.setMethodForColorImages()
                otherwise
                    assert(false, 'Unrecognized mode')
            end
            
        end
        
        function onApply(self)
            
            self.unselectPanZoomTools()
            self.disableApply();
            self.hApp.addToHistory(self.CurrentMask, self.createDescriptionForHistory(), self.createCommandForHistory())
        end
        
        function onClose(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.stopSegmentationAlgorithmAndDiscard();
            self.hApp.clearTemporaryHistory()
            self.unselectPanZoomTools()
            
            self.hToolstrip.showSegmentTab()
            self.hToolstrip.hideActiveContourTab()
            self.hToolstrip.setMode(AppMode.ActiveContoursDone);
        end
        
        function forceSegmentationToStop(self)
            self.StopSegmentationFlag = true;
        end
    end
    
    %%Layout
    methods (Access = private)
        function layoutTab(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            % Add Sections to Active Contours Tab
            self.ActiveContoursSection = self.hTab.addSection(getMessageString('activeContours'));
            self.ActiveContoursSection.Tag = 'ActiveContours';
            self.TextureSection        = self.addTextureSection();
            self.PanZoomSection        = self.addPanZoomSection();
            self.ViewSection           = self.addViewSection();
            self.ApplyCloseSection     = self.addApplyCloseSection();
            
            self.layoutActiveContoursSection()
        end
        
        function layoutActiveContoursSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            %Iterations Label
            self.IterationsLabel  = matlab.ui.internal.toolstrip.Label(getMessageString('iterations'));
            self.IterationsLabel.Description = getMessageString('iterationsTooltip');
            
            %Method Label
            self.MethodLabel = matlab.ui.internal.toolstrip.Label(getMessageString('method'));
            self.MethodLabel.Description = getMessageString('algTooltip');
            
            %Method Button
            self.MethodButton = matlab.ui.internal.toolstrip.DropDownButton(getMessageString('chanVese'));
            self.MethodButton.Tag = 'btnMethod';
            self.MethodButton.Description = getMessageString('methodTooltip');
            
            %Method Dropdown
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getMessageString('chanVeseTitle'));
            sub_item1.Description = getMessageString('chanVeseDescription');
            addlistener(sub_item1, 'ItemPushed', @self.setChanVeseMethodSelection);
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getMessageString('edgeTitle'));
            sub_item2.Description = getMessageString('edgeDescription');
            addlistener(sub_item2, 'ItemPushed', @self.setEdgeMethodSelection);
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            
            self.MethodButton.Popup = sub_popup;
            self.MethodButton.Popup.Tag = 'popupMethodList';

            %Iterations Text
            self.Iterations = 100;
            self.IterationsText = matlab.ui.internal.toolstrip.EditField(num2str(self.Iterations));
            self.IterationsText.Tag = 'txtIterations';
            self.IterationsText.Description = getMessageString('iterationsTooltip');
            addlistener(self.IterationsText, 'ValueChanged', @self.updateIterations);
            
            %Evolve Button
            self.EvolveButton = matlab.ui.internal.toolstrip.Button(getMessageString('evolve'),matlab.ui.internal.toolstrip.Icon.RUN_24);
            self.EvolveButton.Tag = 'btnSegment';
            self.EvolveButton.Description = getMessageString('evolveSegmentationTooltip');
            addlistener(self.EvolveButton, 'ButtonPushed', @(~,~) self.updateSegmentState());
            
            %Layout
            c = self.ActiveContoursSection.addColumn();
            c.add(self.IterationsLabel);
            c.add(self.MethodLabel);
            c2 = self.ActiveContoursSection.addColumn('width',90,...
                'HorizontalAlignment','center');
            c2.add(self.IterationsText);
            c2.add(self.MethodButton);
            c3 = self.ActiveContoursSection.addColumn();
            c3.add(self.EvolveButton);
            
        end
        
        function section = addPanZoomSection(self)
            
            self.PanZoomMgr = iptui.internal.PanZoomManager(self.hTab,self.hApp);
            section = self.PanZoomMgr.Section;
        end
        
        function section = addTextureSection(self)
            self.TextureMgr = iptui.internal.segmenter.TextureManager(self.hTab,self.hApp,self.hToolstrip);
            section = self.TextureMgr.Section;
        end
        
        function section = addViewSection(self)
            
            self.ViewMgr = iptui.internal.segmenter.ViewControlsManager(self.hTab);
            section = self.ViewMgr.Section;
            
            self.OpacitySliderListener    = addlistener(self.ViewMgr.OpacitySlider, 'ValueChanged', @(~,~)self.opacitySliderMoved());
            self.ShowBinaryButtonListener = addlistener(self.ViewMgr.ShowBinaryButton, 'ValueChanged', @(hobj,~)self.showBinaryPress(hobj));
        end
        
        function section = addApplyCloseSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            tabName = getMessageString('activeContoursTab');
            
            self.ApplyCloseMgr = iptui.internal.ApplyCloseManager(self.hTab, tabName);
            section = self.ApplyCloseMgr.Section;
            
            addlistener(self.ApplyCloseMgr.ApplyButton,'ButtonPushed',@(~,~)self.onApply());
            addlistener(self.ApplyCloseMgr.CloseButton,'ButtonPushed',@(~,~)self.onClose());
        end
    end
    
    %%Callbacks
    methods (Access = private)
        function setChanVeseMethodSelection(self,~,~)
            
            import iptui.internal.segmenter.getMessageString;
            self.unselectPanZoomTools()

            self.Algorithm = 'Chan-Vese';
            self.MethodButton.Text = getMessageString('chanVese');

        end
        
        function setEdgeMethodSelection(self,~,~)
            
            import iptui.internal.segmenter.getMessageString;
            self.unselectPanZoomTools()

            self.Algorithm = 'edge';
            self.MethodButton.Text = getMessageString('edge');
                    
        end
        
        function updateIterations(self,~,~)
            
            self.unselectPanZoomTools()
            
            nIter = str2double(self.IterationsText.Value);
            
            %Reset number of iterations to previous value if invalid text
            %is entered.
            isValid = isscalar(nIter) && isfinite(nIter) && nIter>0 && nIter==floor(nIter);
            if ~isValid
                nIter = self.Iterations;
                self.IterationsText.Value = num2str(nIter);
            else
                self.Iterations = nIter;
            end
        end
        
        function evolveButtonCallback(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
                        
            self.hToolstrip.setMode(AppMode.ActiveContoursRunning)
            self.hApp.clearTemporaryHistory()
            
            try
                if self.hApp.Session.UseTexture
                    self.runSegmentationAlgorithm(1000*self.hApp.Session.getTextureFeatures(), self.hApp.getCurrentMask());
                else
                    self.runSegmentationAlgorithm(self.hApp.getImage(), self.hApp.getCurrentMask());
                end
                
                
                if ~self.DiscardSegmentation
                    self.hApp.setTemporaryHistory(self.CurrentMask, self.createDescriptionForHistory(), self.createCommandForHistory())
                end
                self.updateSegmentButtonIcon('segment')
                self.hToolstrip.setMode(AppMode.ActiveContoursIterationsDone)
            catch ME
                if strcmp(ME.identifier,'images:imageSegmenter:emptyMask')
                    % If the contour becomes empty, bring up a dialog
                    % asking the user to change parameters and re-try or
                    % close the tab.
                    self.updateSegmentButtonIcon('segment')
                    iptui.internal.segmenter.invalidSegmentationDialog();
                    self.hToolstrip.setMode(AppMode.ActiveContoursNoMask)
                elseif strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
                    % Deleting the app while it is running will cause self
                    % to become an invalid handle. Do nothing, the app is
                    % already being destroyed.
                else
                    rethrow(ME)
                end
            end
            
            self.hApp.updateStatusBarText('');
        end
        
        function updateSegmentState(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            if self.ContinueSegmentationFlag
                start(self.Timer);
            else
                self.stopSegmentationAlgorithm();
                self.hToolstrip.setMode(AppMode.ActiveContoursIterationsDone)
            end

        end
        
        function updateSegmentButtonIcon(self, name)
            
            import iptui.internal.segmenter.getMessageString;
            switch name
                case 'segment'
                    self.EvolveButton.Icon = matlab.ui.internal.toolstrip.Icon.RUN_24;
                    self.EvolveButton.Text = getMessageString('evolve');
                    self.ContinueSegmentationFlag = true;
                    self.TextureMgr.Enabled = true;
                case 'stop'
                    self.EvolveButton.Icon = matlab.ui.internal.toolstrip.Icon.END_24;
                    self.EvolveButton.Text = getMessageString('stopSegmentation');
                    self.ContinueSegmentationFlag = false;
                    self.TextureMgr.Enabled = false;
            end
        end
        
        function opacitySliderMoved(self)
            
            self.unselectPanZoomTools()
            
            newOpacity = self.ViewMgr.Opacity;
            self.hApp.updateScrollPanelOpacity(newOpacity)
            
            self.hToolstrip.setMode(iptui.internal.segmenter.AppMode.OpacityChanged)
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
    
    %%Algorithm
    methods (Access = private)
        function initializeSegmentationAlgorithm(self, im, mask)
            
            % Setup speed function object.
            switch self.Algorithm
                case 'Chan-Vese'
                    smoothFactor     = 0;
                    contractionBias  = 0;
                    foregroundWeight = 1;
                    backgroundWeight = 1;
                    self.Speed = images.activecontour.internal.ActiveContourSpeedChanVese(...
                        smoothFactor,...
                        contractionBias,...
                        foregroundWeight,...
                        backgroundWeight);
                case 'edge'
                    smoothFactor        = 1;
                    contractionBias     = 0.3;
                    advectionWeight     = 1;
                    sigma               = 2;
                    gradientNormFactor  = 1;
                    edgeExponent        = 1;
                    self.Speed = images.activecontour.internal.ActiveContourSpeedEdgeBased(...
                        smoothFactor,...
                        contractionBias,...
                        advectionWeight,...
                        sigma,...
                        gradientNormFactor,...
                        edgeExponent);
            end
            
            % Create contour evolver object
            self.Evolver = images.activecontour.internal.ActiveContourEvolver(...
                im,...
                mask,...
                self.Speed);
            
            % Flag used to decide whether we need to halt algorithm
            self.StopSegmentationFlag = false;
        end
        
        function runSegmentationAlgorithm(self, im, mask)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.initializeSegmentationAlgorithm(im, mask);
            
            prevState = warning('off','images:activecontour:vanishingContour');
            cleanUp = onCleanup(@() warning(prevState));
            
            for n = 1:self.Iterations
               
                self.CurrentIteration = n;
                
                % Evolve contour for 1 iteration.
                self.Evolver = moveActiveContour(self.Evolver, 1, false);
                self.CurrentMask = self.Evolver.ContourState;
                self.hApp.updateScrollPanelPreview(self.CurrentMask)
                self.hApp.updateStatusBarText(getMessageString('iterationStatusText', num2str(n), num2str(self.Iterations)));
                
                % Flush event queue for listeners in view to process and
                % update graphics in response to changes in mask and
                % current iteration count.
                drawnow();
                
                if ~(any(self.CurrentMask(:)))
                   ME = MException('images:imageSegmenter:emptyMask',...
                       'Mask has evolved to an all false state.');
                   throw(ME); 
                end

                if self.StopSegmentationFlag
                    break;
                end
            end
            
            % Segmentation may need to be discarded if Close was pressed during contour evolution.
            if ~self.DiscardSegmentation
                self.hApp.updateScrollPanelPreview(self.CurrentMask)
            end
        end
        
        function stopSegmentationAlgorithm(self)
            self.StopSegmentationFlag = true;
        end
        
        function stopSegmentationAlgorithmAndDiscard(self)
            self.stopSegmentationAlgorithm()
            self.DiscardSegmentation = true;
        end
    end
    
    %%Helpers
    methods (Access = private)
        function unselectPanZoomTools(self)
            
            self.PanZoomMgr.unselectAll();    
        end
        
        function reactToOpacityChange(self)
            % Move the opacity slider to reflect change in opacity level
            % coming from a different tab.
            
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
        
        function disableAllButtons(self)
            self.IterationsLabel.Enabled            = false;
            self.IterationsText.Enabled             = false;
            self.MethodLabel.Enabled                = false;
            self.MethodButton.Enabled               = false;
            self.EvolveButton.Enabled               = false;
            self.PanZoomMgr.Enabled                 = false;
            self.TextureMgr.Enabled                 = false;
            self.ViewMgr.Enabled                    = false;
            self.ApplyCloseMgr.ApplyButton.Enabled  = false;
            self.ApplyCloseMgr.CloseButton.Enabled  = false;
        end
        
        function enableAllButtons(self)
            self.IterationsLabel.Enabled            = true;
            self.IterationsText.Enabled             = true;
            self.MethodLabel.Enabled                = true;
            self.EvolveButton.Enabled               = true;
            self.PanZoomMgr.Enabled                 = true;
            self.TextureMgr.Enabled                 = true;
            self.ViewMgr.Enabled                    = true;
            self.ApplyCloseMgr.ApplyButton.Enabled  = true;
            self.ApplyCloseMgr.CloseButton.Enabled  = true;
            self.setMethodForColorImages()
        end
        
        function disableActiveContoursSection(self)
            self.IterationsLabel.Enabled    = false;
            self.IterationsText.Enabled     = false;
            self.MethodLabel.Enabled        = false;
            self.MethodButton.Enabled       = false;
            self.EvolveButton.Enabled       = true;
        end
        
        function enableActiveContoursSection(self)
            self.IterationsLabel.Enabled    = true;
            self.IterationsText.Enabled     = true;
            self.MethodLabel.Enabled        = true;
            self.EvolveButton.Enabled       = true;
            self.setMethodForColorImages()
        end
        
        function setEvolveToStop(self)
            self.EvolveButton.Icon = matlab.ui.internal.toolstrip.Icon.END_24;
            self.EvolveButton.Text = iptui.internal.segmenter.getMessageString('stopSegmentation');
            self.ContinueSegmentationFlag = false;
            self.TextureMgr.Enabled = false;
        end
        
        function setStopToEvolve(self)
            self.EvolveButton.Icon = matlab.ui.internal.toolstrip.Icon.RUN_24;
            self.EvolveButton.Text = iptui.internal.segmenter.getMessageString('evolve');
            self.ContinueSegmentationFlag = true;
            self.TextureMgr.Enabled = true;
        end
        
        function enableApply(self)
            self.ApplyCloseMgr.ApplyButton.Enabled = true;
        end
        
        function enableClose(self)
            self.ApplyCloseMgr.CloseButton.Enabled = true;
        end
        
        function disableApply(self)
            self.ApplyCloseMgr.ApplyButton.Enabled = false;
        end
        
        function setMethodForColorImages(self)
            if self.hApp.wasRGB || self.hApp.Session.UseTexture
                self.setChanVeseMethodSelection()
                self.MethodButton.Enabled = false;
            else
                self.MethodButton.Enabled = true;
            end
        end
        
        function cmd = createCommandForHistory(self)
            cmd{1} = sprintf('iterations = %d;', self.CurrentIteration);
            if self.hApp.Session.UseTexture
                cmd{2} = sprintf('BW = activecontour(gaborX, BW, iterations, ''%s'');', self.Algorithm);
            else
                cmd{2} = sprintf('BW = activecontour(X, BW, iterations, ''%s'');', self.Algorithm);
            end
        end
        
        function description = createDescriptionForHistory(self)
            if self.hApp.Session.UseTexture
                description = iptui.internal.segmenter.getMessageString('activeContoursTextureComment');    
            else
                description = iptui.internal.segmenter.getMessageString('activeContoursComment');
            end
        end
    end
end
