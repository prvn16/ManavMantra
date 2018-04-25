classdef ColorSegmentationTool < handle
    
    %   Copyright 2013-2017 The MathWorks, Inc.
    
    
    properties (Hidden = true, SetAccess = private)
        % Data members must be public for current testing methodology.
        % This is an implementation detail of the class, not truly public data
        % members. That is why they are hidden.
        
        % Handle to figures docked in toolstrip
        FigureHandles
        
        % Handle to current figure docked in toolstrip
        hFigCurrent
        
        % binary image that current defines mask
        mask
        sliderMask
        clusterMask
        
        % Cached colorspace representations of image data
        imRGB
        
        %Handle to mask opacity slider
        hMaskOpacitySlider
        
        % Image preview handle.
        ImagePreviewDisplay
        
        % Polygon ROIs
        hPolyROIs
        
        % Invert Mask Button
        hInvertMaskButton
        hHidePointCloud
        
        % Cache knowledge of whether we normalized double input data so
        % that we can have thresholds in "generate function" context match
        % image data. Do the same for massaging of image data to handle
        % Nans and Infs appropriately.
        normalizedDoubleData
        massageNansInfs
        
    end
    
    properties (Access = private)
        
        %ToolGroup
        hToolGroup
        
        % Tabs
        hTabGroup
        ThresholdTab
        ImageCaptureTab
        
        %imscrollpanel that contains overlay view
        hScrollpanel
        
        % Sections
        LoadImageSection
        ThresholdControlsSection
        ChooseProjectionSection
        ColorSpacesSection
        ManualSelectionSection
        PanZoomSection
        ViewSegmentationSection
        ExportSection
        
        % Handles to buttons in toolstrip
        hColorSpacesButton
        hShowBinaryButton
        hZoomInButton
        hZoomOutButton
        hPanButton
        hOverlayColorButton
        hPointCloudBackgroundSlider
        isLiveUpdate
        
        % Handles to buttons in toolstrip that are enabled/distabled based
        % on whether data has been loaded into app.
        hChangeUIComponentHandles
        lassoSensitiveComponentHandles
        
        % Cached knowledge of current opacity so that
        % we can flip back and forth from "Show Binary" toggle mode
        currentOpacity
        
        % We cache ClientActionListener on ToolGroup so that we can
        % disable/enable it at specific times.
        ClientActionListener
        
        % We cache the listener for whether or not a colorspace has been
        % selected in iptui.internal.ColorSpaceMontageView so that we don't
        % continue listening for a color space selection if the
        % colorSegmentor app is destroyed.
        colorspaceSelectedListener
        
        % We cache listeners to state changed on buttons so that we can
        % disable/enable button listeners when a new image is loaded and we
        % restore the button states to an initialized state.
        binaryButonStateChangedListener
        invertMaskItemStateChangedListener
        sliderMovedListener
        pointCloudSliderMovedListener
        
        %Handle to current open iptui.internal.ColorSpaceMontageView
        %instance
        hColorSpaceMontageView
        hColorSpaceProjectionView
        
        % Handles of selected regions
        hFreehandROIs
        freehandManager
        polyManager
        
        % Listeners for selected regions
        hFreehandListener
        hPolyMovedListener
        hSliderMovedListener
        hPolyListener
        hFreehandMovedListener
        
        preLassoPanZoomState
        preLassoToolstripState
        
        % Size of image
        imSize
        
        % Logical used when deleting polygons
        isProjectionApplied
        
        % Background color of point cloud
        pointCloudColor
        maskColor
        
        % Logical to handle different states of app
        isFreehandApplied
        isManualDelete
        is3DView
        isFigClicked
        
        % Cached icons
        LoadImageIcon
        newColorspaceIcon
        hidePointCloudIcon
        liveUpdateIcon
        invertMaskIcon
        resetButtonIcon
        zoomInIcon
        zoomOutIcon
        panIcon
        showBinaryIcon
        createMaskIcon
        freeIcon
        polyIcon
        rotateIcon
        rotatePointer
        
    end
    
    
    methods
        
        
        function self = ColorSegmentationTool(varargin)
            
            self.hToolGroup = matlab.ui.internal.desktop.ToolGroup(getString(message('images:colorSegmentor:appName')));
            self.hTabGroup = matlab.ui.internal.toolstrip.TabGroup();
            
            % Add DDUX logging to Toolgroup
            images.internal.app.utilities.addDDUXLogging(self.hToolGroup,'Image Processing Toolbox','Color Thresholder');
            
            % Create Tabs
            self.ThresholdTab = self.hTabGroup.addTab(getString(message('images:colorSegmentor:thresholdTab')));
            self.ThresholdTab.Tag = getString(message('images:colorSegmentor:ThresholdTabName'));
            
            % Initialize the camera preview instance.
            self.ImagePreviewDisplay = [];
            
            % Remove view Tab.
            self.removeViewTab();
            
            % Remove Quick Access Bar (QAB).
            self.removeQuickAccessBar()
            
            % Disable interactive tiling in app. We want to enforce layout
            % so that multiple color space segmentation documents cannot be
            % viewed at one time. An assumption of the design is that only
            % one imscrollpanel is visible at a time.
            self.disableInteractiveTiling();
            
            % Add Sections to Threshold Tab
            self.LoadImageSection               = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:loadImage')));
            self.LoadImageSection.Tag           = 'LoadImage';
            self.ColorSpacesSection             = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:colorSpaces')));
            self.ColorSpacesSection.Tag         = 'ColorSection';
            self.ThresholdControlsSection       = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:thresholdControls')));
            self.ThresholdControlsSection.Tag   = 'ThresholdControlsSection';
            self.ViewSegmentationSection        = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:viewSegmentation')));
            self.ViewSegmentationSection.Tag    = 'ViewSegmentationSection';
            self.PanZoomSection                 = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:zoomAndPan')));
            self.PanZoomSection.Tag             = 'PanZoomSection';
            self.ManualSelectionSection         = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:colorSelection')));
            self.ManualSelectionSection.Tag     = 'ManualSelectionSection';
            self.ChooseProjectionSection        = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:pointCloud')));
            self.ChooseProjectionSection.Tag    = 'ChooseProjection';
            self.ExportSection                  = self.ThresholdTab.addSection(getString(message('images:colorSegmentor:export')));
            self.ExportSection.Tag              = 'Export';
            
            % Layout Panels/Buttons within each section
            self.loadAppIcons();
            self.layoutLoadImageSection();
            self.layoutColorSpacesSection();
            self.layoutManualSelectionSection();
            self.layoutThresholdControlsSection();
            self.layoutPanZoomSection();
            self.layoutViewSegmentationSection();
            self.layoutExportSection();
            self.layoutChooseProjectionSection();
            
            self.hToolGroup.addTabGroup(self.hTabGroup);
            
            % Initialize Background color with default
            self.pointCloudColor = 1 - repmat(self.hPointCloudBackgroundSlider.Value,1,3)/100;
            self.maskColor = [0 0 0];
            
            % Disable ui controls in app until data is loaded
            self.setControlsEnabled(false);
            self.hPointCloudBackgroundSlider.Enabled = false;
            
            % Disable "Hide" option in tabs.
            g = self.hToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_DOCUMENT_BAR_HIDE, false);
            
            disableDragDropOnToolGroup(self);
            
            % Initial layout of view
            [x,y,width,height] = imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition();
            self.hToolGroup.setPosition(x,y,width,height);
            self.hToolGroup.disableDataBrowser();
            self.hToolGroup.open();
            
            imageslib.internal.apputil.manageToolInstances('add', 'colorThresholder', self.hToolGroup);
            
            self.isProjectionApplied = false;
            self.isFreehandApplied = false;
            self.isManualDelete = true;
            
            % We want to destroy the current
            % iptui.internal.ColorSegmentationTool instance if a user
            % interactively closes the toolgroup associated with this
            % instance.
            addlistener(self.hToolGroup, 'GroupAction', ...
                @(~,ed) doClosingSession(self,ed));
            
            % If image data was specified, load it into the app
            if nargin > 0
                im = varargin{1};
                self.importImageData(im);
            else
                self.hColorSpacesButton.Enabled = false;
            end
            
            % Listen for changes in Active/Closing figures in the ToolGroup
            self.ClientActionListener = addlistener(self.hToolGroup,...
                'ClientAction',@(hobj,evt) clientActionCB(self,hobj,evt));
            
        end
        
        
    end
    
    methods
        
        % Methods provided for testing.
        function viewSpecifiedColorspace(self,colorSpaceString)
            % viewSpecifiedColorSpace - Initialize app with RGB image and
            % load specified color space document into app.
            % h.viewSpecifiedColorSpace(RGB,colorSpaceString) creates a
            % segmentation view in the color space specified by
            % colorSpaceString ('RGB','HSV','L*a*b*','YCbCr').
            
            % Replicate behavior for button callback from montage view
            self.hColorSpaceMontageView.customProjection(colorSpaceString);
            self.hColorSpaceMontageView.SelectedColorSpace = colorSpaceString;
            self.hColorSpaceMontageView.delete();
            
            % Enable UI controls
            self.setControlsEnabled(true);
            self.hPointCloudBackgroundSlider.Enabled = true;
            
            % Each time a new color space is loaded the app manages the state
            % of specific UI controls.
            self.manageControlsOnNewColorspace();
            
        end
        
        function [h3DPoly, h2DPoly, h2DRotate] = getPointCloudButtonHandles(self)
            % getPointCloudButtonHandles - Get handles to buttons for
            % current figure window. Requires that a colorspace tab be the
            % current figure and not the "Choose a Color Space" tab
            h3DPoly = findobj(self.hFigCurrent,'Tag','ProjectButton');
            h2DPoly = findobj(self.hFigCurrent,'Tag','PolyButton');
            h2DRotate = findobj(self.hFigCurrent,'Tag','RotateButton');
            
        end
        
        function hButton = getMontageViewButtonHandle(self,csname)
            % getMontageViewButtonHandles - Get handles for buttons for the
            % four color spaces from the "Choose a Color Space" tab
            if self.hasCurrentValidMontageInstance()
                hButton = self.hColorSpaceMontageView.getButtonHandle(csname);
            else
                hButton = [];
            end
            
        end
        
    end
    
    methods
        % This is used both by the app internally and is used in testing,
        % so it needs to be public
        function initializeAppWithRGBImage(self,im)
            
            % Cache knowledge of RGB representation of image.
            self.imRGB = im;
            
            % Initialize mask
            self.mask = true(size(im,1),size(im,2));
            
            % Enable colorspaces button
            self.hColorSpacesButton.Enabled = true;
            
        end
        
        
    end
    
    % Assorted utility methods used by app
    methods (Access = private)
        
        function [self,im] = normalizeDoubleDataDlg(self,im)
            
            self.normalizedDoubleData = false;
            self.massageNansInfs      = false;
            
            % Check if image has NaN,Inf or -Inf valued pixels.
            finiteIdx       = isfinite(im(:));
            hasNansInfs     = ~all(finiteIdx);
            
            % Check if image pixels are outside [0,1].
            isOutsideRange  = any(im(finiteIdx)>1) || any(im(finiteIdx)<0);
            
            % Offer the user the option to normalize and clean-up data if
            % either of these conditions is true.
            if isOutsideRange || hasNansInfs
                
                buttonname = questdlg(getString(message('images:colorSegmentor:normalizeDataDlgMessage')),...
                    getString(message('images:colorSegmentor:normalizeDataDlgTitle')),...
                    getString(message('images:colorSegmentor:normalizeData')),...
                    getString(message('images:commonUIString:cancel')),...
                    getString(message('images:colorSegmentor:normalizeData')));
                
                if strcmp(buttonname,getString(message('images:colorSegmentor:normalizeData')))
                    
                    % First clean-up data by removing NaN's and Inf's.
                    if hasNansInfs
                        % Replace nan pixels with 0.
                        im(isnan(im)) = 0;
                        
                        % Replace inf pixels with 1.
                        im(im== Inf)   = 1;
                        
                        % Replace -inf pixels with 0.
                        im(im==-Inf)   = 0;
                        
                        self.massageNansInfs = true;
                    end
                    
                    % Normalize data in [0,1] if outside range.
                    if isOutsideRange
                        im = mat2gray(im);
                        self.normalizedDoubleData = true;
                    end
                    
                else
                    im = [];
                end
                
            end
        end
        
        function cdata = computeColorspaceRepresentation(self,csname)
            
            switch (csname)
                
                case 'RGB'
                    cdata = self.imRGB;
                case 'HSV'
                    cdata = rgb2hsv(self.imRGB);
                case 'YCbCr'
                    cdata = rgb2ycbcr(self.imRGB);
                case 'L*a*b*'
                    cdata = rgb2lab(self.imRGB);
                    
                otherwise
                    assert('Unknown colorspace name specified.');
            end
            
        end
        
        function doClosingSession(self, evt)
            if strcmp(evt.EventData.EventType, 'CLOSING')
                % Force the graphics system to flush in case the app is in
                % process of creating new graphics object
                drawnow;
                % Remove the Camera tab if it exists.
                if isCameraPreviewInApp(self)
                    % Close the preview window.
                    drawnow;
                    self.ImageCaptureTab.closePreviewWindowCallback;
                end
                % Remove the Choose a Color Space tab if it exists.
                if ~isempty(self.hColorSpaceMontageView)
                    self.hColorSpaceMontageView.delete()
                end
                imageslib.internal.apputil.manageToolInstances('remove', 'colorThresholder', self.hToolGroup);
                delete(self.hToolGroup)
                delete(self);
            end
        end
        
        
        function clientActionCB(self,~,evt)
            
            hFig = evt.EventData.Client;
            
            if strcmpi(evt.EventData.EventType,'ACTIVATED')
                
                self.manageROIButtonStates()
                % Re-parent scrollpanel to the activated figure.
                
                clientTitle = evt.EventData.ClientTitle;
                existingTabs = self.hToolGroup.TabNames;
                
                % Handle toolstrip state
                if strcmp(clientTitle,getString(message('images:colorSegmentor:chooseColorspace')))
                    self.hColorSpacesButton.Enabled = false;
                    self.setControlsEnabled(false);
                    self.hPointCloudBackgroundSlider.Enabled = true;
                elseif strcmp(clientTitle,getString(message('images:colorSegmentor:MainPreviewFigure')))
                    self.hColorSpacesButton.Enabled = false;
                    self.setControlsEnabled(false);
                    self.hPointCloudBackgroundSlider.Enabled = false;
                elseif self.validColorspaceFiguresInApp()
                    self.setControlsEnabled(true);
                    self.hColorSpacesButton.Enabled = true;
                    if self.hHidePointCloud.Value
                        self.hPointCloudBackgroundSlider.Enabled = false;
                    else
                        self.hPointCloudBackgroundSlider.Enabled = true;
                    end
                end
                
                % Special case Camera preview tab before others.
                if strcmpi(clientTitle, getString(message('images:colorSegmentor:MainPreviewFigure')))
                    % If image capture tab is not in the toolgroup, add it and bring
                    % focus to it.
                    if ~any(strcmpi(existingTabs, getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                        add(self.hTabGroup, getToolTab(self.ImageCaptureTab), 2);
                    end
                    % Select the capture tab.
                    self.hTabGroup.SelectedTab = getToolTab(self.ImageCaptureTab);
                    % Set it as the current figure.
                    self.hFigCurrent = hFig;
                elseif self.validColorspaceFiguresInApp()
                    % This conditional is necessary because an event fires
                    % when the last figure in the desktop is closed and
                    % hFig is no longer valid.
                    
                    hLeftPanel = findobj(hFig,'tag','LeftPanel');
                    
                    if ~isempty(hLeftPanel)
                        layoutScrollpanel(self,hLeftPanel);
                        
                        % Need to know current colorspace representation of image
                        % here. Use appdata for now. This is making an extra copy
                        % of the CData that we will want to avoid.
                        hRightPanel = findobj(hFig,'tag','RightPanel');
                        histHandles = getappdata(hRightPanel,'HistPanelHandles');
                        hProjectionView = getappdata(hRightPanel,'ProjectionView');
                        self.hColorSpaceProjectionView = hProjectionView;
                        
                        % Update mask
                        self.hFigCurrent = hFig;
                        cData = getappdata(hRightPanel,'ColorspaceCData');
                        self.updateMask(cData,histHandles{:});
                        hPanel3D = findobj(hRightPanel,'tag','proj3dpanel');
                        
                        % Update logical indicating view state
                        if strcmp(get(hPanel3D,'Visible'),'on')
                            self.is3DView = true;
                        else
                            self.is3DView = false;
                        end
                        
                        % If point cloud visible, apply polygons to mask
                        if ~self.hHidePointCloud.Value
                            self.applyClusterROIs();
                        end
                        
                        self.hideOtherROIs()
                        
                    end
                    
                    % Remove the contextual tab and show Threshold tab.
                    if any(strcmp(existingTabs, getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                        remove(self.hTabGroup, getToolTab(self.ImageCaptureTab));
                    end
                    self.hTabGroup.SelectedTab = self.ThresholdTab;
                else
                    % Remove the contextual tab and show Threshold tab.
                    if any(strcmp(existingTabs, getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                        remove(self.hTabGroup, getToolTab(self.ImageCaptureTab));
                    end
                    self.hTabGroup.SelectedTab = self.ThresholdTab;
                end
                
            end
            
            % When the last figure in the app has been closed, disable the
            % appropriate UI controls.
            if strcmpi(evt.EventData.EventType,'CLOSED')
                appDeleted = ~isvalid(self) || ~isvalid(self.hToolGroup);
                if ~appDeleted
                    self.manageROIButtonStates()
                    if ~self.validColorspaceFiguresInApp()
                        self.setControlsEnabled(false);
                        if self.hToolGroup.isClientShowing(getString(message('images:colorSegmentor:chooseColorspace')))
                            self.hPointCloudBackgroundSlider.Enabled = true;
                            self.hColorSpacesButton.Enabled = false;
                        elseif self.hToolGroup.isClientShowing(getString(message('images:colorSegmentor:MainPreviewFigure')))
                            self.hPointCloudBackgroundSlider.Enabled = false;
                            self.hColorSpacesButton.Enabled = false;
                        else
                            self.hColorSpacesButton.Enabled = true;
                            self.hPointCloudBackgroundSlider.Enabled = false;
                        end
                    end
                end
            end
            
        end
        
        
        function manageROIButtonStates(self)
            
            if ~isvalid(self) || ~isvalid(self.hToolGroup)
                return
            end
            
            % First check if freehand or polygon tools were selected
            if ~isempty(self.freehandManager)
                self.resetLassoTool()
                self.freehandManager = [];
                set(findobj(self.hScrollpanel,'Tag','SelectButton'),'Value',0);
            end
            
            if ~isempty(self.polyManager)
                self.disablePolyRegion()
                self.polyManager = [];
                % Reset polygon button
                validHandles = self.FigureHandles(ishandle(self.FigureHandles));
                arrayfun(@(h) set(findobj(h,'Tag','PolyButton'),'Value',0),validHandles);
            end
            
        end
        
        
        function updateMask(self,cData,hChan1Hist,hChan2Hist,hChan3Hist)
            % updateMask - Updates the mask for the histogram sliders and
            % then combines with the mask from any polygons drawn on point
            % cloud
            
            channel1Lim = hChan1Hist.currentSelection;
            channel2Lim = hChan2Hist.currentSelection;
            channel3Lim = hChan3Hist.currentSelection;
            
            firstPlane  = cData(:,:,1);
            secondPlane = cData(:,:,2);
            thirdPlane  = cData(:,:,3);
            
            % The hue channel can have a min greater than max, so that
            % needs special handling. We could special case the H channel,
            % or we can build a mask treating every channel like H.
            if isa(hChan1Hist,'iptui.internal.InteractiveHistogramHue') && (channel1Lim(1) >= channel1Lim(2) )
                BW = bsxfun(@ge,firstPlane,channel1Lim(1)) | bsxfun(@le,firstPlane,channel1Lim(2));
            else
                BW = bsxfun(@ge,firstPlane,channel1Lim(1)) & bsxfun(@le,firstPlane,channel1Lim(2));
            end
            
            BW = BW & bsxfun(@ge,secondPlane,channel2Lim(1)) & bsxfun(@le,secondPlane,channel2Lim(2));
            BW = BW & bsxfun(@ge,thirdPlane,channel3Lim(1)) & bsxfun(@le,thirdPlane,channel3Lim(2));
            
            self.sliderMask = BW;
            
            % Combine with Cluster mask
            self.updateMasterMask();
            
        end
        
        
        function updateClusterMask(self,varargin)
            % updateClusterMask - Updates the mask from any polygons drawn
            % on point cloud and then combines with the mask from the
            % histogram sliders
            
            switch nargin
                case 1
                    % If no mask is input reset mask
                    self.clusterMask = true([size(self.imRGB,1) size(self.imRGB,2)]);
                case 2
                    self.clusterMask = varargin{1};
            end
            
            % Combine with Slider mask
            self.updateMasterMask();
            
        end
        
        
        function updateMasterMask(self)
            % updateMasterMask - Combines mask from polygons on point cloud
            % with mask from histogram sliders
            
            BW = self.sliderMask & self.clusterMask;
            
            if self.hInvertMaskButton.Value
                self.mask = ~BW;
            else
                self.mask = BW;
            end
            
            % Now update graphics in scrollpanel.
            self.updateMaskOverlayGraphics();
            
        end
        
        
        function updatePointCloud(self,varargin)
            % updatePointCloud - Updates the 2D point cloud when sliders
            % are moved. Set TF = true when a new projection is created and
            % you need to reset the axes limits
            
            % Find handles to objects
            hPanel = findobj(self.hFigCurrent, 'tag', 'RightPanel');
            hScat = findobj(hPanel,'Tag','ScatterPlot');
            
            % Set axes limit modes
            hScat.Parent.XLimMode = 'Manual';
            hScat.Parent.YLimMode = 'Manual';
            
            % Get data for point cloud
            BW = self.sliderMask(:);
            im = getappdata(hPanel,'TransformedCDataForCluster');
            xData = im(:,1);
            yData = im(:,2);
            
            % Reset axes limits for new projection
            if nargin > 1
                hScat.Parent.XLim = varargin{1};
                hScat.Parent.YLim = varargin{2};
            end
            
            % Remove points that are false in the slider mask
            xData = xData(BW);
            yData = yData(BW);
            
            % Remove points from the color data that are false in the
            % slider mask
            cData1 = self.imRGB(:,:,1);
            cData2 = self.imRGB(:,:,2);
            cData3 = self.imRGB(:,:,3);
            cData1 = cData1(self.sliderMask);
            cData2 = cData2(self.sliderMask);
            cData3 = cData3(self.sliderMask);
            cData = [cData1 cData2 cData3];
            
            set(hScat,'XData',xData,'YData',yData,'CData',cData);
            
        end
        
        function hidePointCloud(self)
            
            if self.hHidePointCloud.Value
                self.hPointCloudBackgroundSlider.Enabled = false;
                % Get handles to all valid figures
                validHandles = self.FigureHandles(ishandle(self.FigureHandles));
                % Update histogram panels for each figure based on the
                % color space
                for ii = 1:numel(validHandles)
                    hRightPanel = findobj(validHandles(ii), 'tag', 'RightPanel');
                    if ~isempty(hRightPanel) % Camera document has no RightPanel
                        if strcmp(hRightPanel.Parent.Tag,'HSV')
                            handleH = findobj(hRightPanel,'tag','H');
                            handleS = findobj(hRightPanel,'tag','S');
                            handleV = findobj(hRightPanel,'tag','V');
                            layoutPosition = getappdata(hRightPanel,'layoutPosition');
                            % H Panel
                            set(handleH,'Position',layoutPosition{4});
                            % S Panel
                            set(handleS,'Position',layoutPosition{5});
                            % V Panel
                            set(handleV,'Position',layoutPosition{6});
                        else
                            histHandles = findobj(hRightPanel,'tag','SlidersContainer');
                            arrayfun(@(h) set(h,'Position',[0 0 1 1]),histHandles);
                        end
                        % Hide point cloud panels
                        projHandles = findobj(hRightPanel,'tag','ColorProj','-or','tag','proj3dpanel');
                        arrayfun(@(h) set(h,'Visible','off'),projHandles);
                    end
                end
                self.updateClusterMask()
            else
                self.hPointCloudBackgroundSlider.Enabled = true;
                % Get handles to all valid figures
                validHandles = self.FigureHandles(ishandle(self.FigureHandles));
                % Update histogram panels for each figure based on the
                % color space
                for ii = 1:numel(validHandles)
                    hRightPanel = findobj(validHandles(ii), 'tag', 'RightPanel');
                    if ~isempty(hRightPanel) % Camera document has no RightPanel
                        if strcmp(hRightPanel.Parent.Tag,'HSV')
                            handleH = findobj(hRightPanel,'tag','H');
                            handleS = findobj(hRightPanel,'tag','S');
                            handleV = findobj(hRightPanel,'tag','V');
                            layoutPosition = getappdata(hRightPanel,'layoutPosition');
                            % H Panel
                            set(handleH,'Position',layoutPosition{1});
                            % S Panel
                            set(handleS,'Position',layoutPosition{2});
                            % V Panel
                            set(handleV,'Position',layoutPosition{3});
                        else
                            histHandles = findobj(hRightPanel,'tag','SlidersContainer');
                            arrayfun(@(h) set(h,'Position',[0 0.6 1 0.4]),histHandles);
                        end
                        % Show point cloud panels
                        if iptui.internal.hasValidROIs(validHandles(ii), self.hPolyROIs)
                            projHandles = findobj(hRightPanel,'tag','ColorProj');
                        else
                            projHandles = findobj(hRightPanel,'tag','proj3dpanel');
                        end
                        set(projHandles,'Visible','on');
                    end
                end
                
                if iptui.internal.hasValidROIs(self.hFigCurrent, self.hPolyROIs)
                    self.is3DView = false;
                else
                    self.is3DView = true;
                end
                
                self.updatePointCloud();
                self.applyClusterROIs();
            end
            
            
        end
        
        
        function updateMaskOverlayGraphics(self)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if self.hShowBinaryButton.Value
                set(hIm,'CData',self.mask);
            else
                alphaData = ones(size(self.mask,1),size(self.mask,2));
                alphaData(~self.mask) = 1-self.hMaskOpacitySlider.Value/100;
                set(hIm,'AlphaData',alphaData);
            end
            
        end
        
        
        function self = setTSButtonIconFromImage(self,ButtonObj,im)
            % This method allows an image matrix IM to be set as the icon
            % of a Button. There is no direct support for setting a
            % Button icon from a image buffer in memory in the toolstrip
            % API.

            iconImage = im2java(im2uint8(im));
            icon = javax.swing.ImageIcon(iconImage);
            icon = matlab.ui.internal.toolstrip.Icon(icon);
            ButtonObj.Icon = icon;
            
        end
        
        
        function manageControlsOnNewColorspace(self)
            % This method puts the Show Binary, Invert mask, and Opacity
            % Slider back to their default state whenever a new image is
            % loaded or a new colorspace document is created.
            self.hShowBinaryButton.Value = false;
            self.hInvertMaskButton.Value = false;
            self.hMaskOpacitySlider.Value  = 100;
            
        end
        
        
        function manageControlsOnImageLoad(self)
            % We can reuse logic from manageControlsOnNewColorspace, but we also have to disable
            % and re-enable listeners that are coupled to existence of
            % scrollpanel, because scrollpanel is blown away and recreated
            % when you load a new image.
            
            % Disable listeners
            self.binaryButonStateChangedListener.Enabled = false;
            self.invertMaskItemStateChangedListener.Enabled = false;
            self.sliderMovedListener.Enabled = false;
            
            self.manageControlsOnNewColorspace();
            
            % Additionally, we want to reset zoom and background color space
            % when we load a new image
            self.hZoomInButton.Value = false;
            self.hZoomOutButton.Value = false;
            self.hPanButton.Value = false;
            
            % This drawnow is necessary to allow state of buttons to settle before
            % re-enabling the listeners.
            drawnow;
            
            % Enable listeners
            self.binaryButonStateChangedListener.Enabled = true;
            self.invertMaskItemStateChangedListener.Enabled = true;
            self.sliderMovedListener.Enabled = true;
            
        end
        
        
        function setControlsEnabled(self,TF)
            % This button manages the enabled/disabled state of UIControls
            % in the toolstrip based on whether or not an image has been
            % loaded into the app.
            for i = 1:length( self.hChangeUIComponentHandles )
                self.hChangeUIComponentHandles{i}.Enabled = TF;
            end
            
        end
        
        
    end
    
    % The following methods gets called from ImageCaptureTab Class.
    methods (Access = public)
        
        function importImageData(self,im)
            
            if isfloat(im)
                [self,im] = normalizeDoubleDataDlg(self,im);
                if isempty(im)
                    return;
                end
            end
            
            % If there is a color space selection figure already open,
            % remove it before you initialize the app with the new figure
            if self.hasCurrentValidMontageInstance()
                self.hColorSpaceMontageView.delete();
            end
            
            self.initializeAppWithRGBImage(im);
            
            [m,n,~] = size(im);
            self.imSize = m*n;
            
            % Set Live Updates on if image is small
            if self.imSize > 1e6
                self.isLiveUpdate.Value = false;
            else
                self.isLiveUpdate.Value = true;
            end
            
            % Bring up colorspace montage view
            self.compareColorSpaces();
            
        end
        
        function TF = hasCurrentValidMontageInstance(self)
            TF = isa(self.hColorSpaceMontageView,'iptui.internal.ColorSpaceMontageView') &&...
                isvalid(self.hColorSpaceMontageView);
        end
        
        function TF = validColorspaceFiguresInApp(self)
            
            TF = self.hToolGroup.isClientShowing('RGB') ||...
                self.hToolGroup.isClientShowing('HSV') ||...
                self.hToolGroup.isClientShowing('YCbCr') ||...
                self.hToolGroup.isClientShowing('L*a*b*');
            
        end
        
        function TF = isCameraPreviewInApp(self)
            TF = self.hToolGroup.isClientShowing(getString(message('images:colorSegmentor:MainPreviewFigure')));
        end
        
        function toolGroup = getToolGroup(self)
            toolGroup = self.hToolGroup;
        end
        
        function tabGroup = getTabGroup(self)
            tabGroup = self.hTabGroup;
        end
        
        % Method is used by both import from file and import from workspace
        % callbacks.
        function user_canceled = showImportingDataWillCauseDataLossDlg(self, msg, msgTitle)
            
            user_canceled = false;
            
            if self.validColorspaceFiguresInApp()
                
                buttonName = questdlg(msg, msgTitle, ...
                    getString(message('images:commonUIString:yes')),...
                    getString(message('images:commonUIString:cancel')),...
                    getString(message('images:commonUIString:cancel')));
                
                if strcmp(buttonName,getString(message('images:commonUIString:yes')))
                    
                    % Each time a new colorspace document is added, we want to
                    % revert the Show Binary, Invert Mask, and Mask Opacity ui
                    % controls back to their initialized state.
                    self.manageControlsOnImageLoad();
                    self.hColorSpacesButton.Enabled = false;
                    
                    validFigHandles = ishandle(self.FigureHandles);
                    if ismember(getString(message('images:colorSegmentor:MainPreviewFigure')), get(self.FigureHandles(validFigHandles), 'Name')) % do not remove camera document tab.
                        % Remove Camera figure handle from valid list of
                        % figure handles.
                        validFigHandles(1) = 0;
                        close(self.FigureHandles(validFigHandles));
                        self.FigureHandles = self.FigureHandles(1);
                    else
                        close(self.FigureHandles(validFigHandles));
                        self.FigureHandles = [];
                    end
                    if self.hasCurrentValidMontageInstance()
                        self.hColorSpaceMontageView.delete();
                    end
                else
                    user_canceled = true;
                end
                
            end
        end
        
    end
    % Methods used to create each color space segmentation figure/document
    methods (Access = private)
        
        
        function hFig = createColorspaceSegmentationView(self,im,csname,tMat,camPosition,camVector)
            
            % We don't want creation of a new figure in the ToolGroup to
            % trigger the ClientAction callback as the new figure is
            % enabled. Temporarily disable listener as we add new figure to
            % the ToolGroup.
            self.ClientActionListener.Enabled = false;
            
            if isempty(im) % We are in preview/camera mode.
                if isempty(self.ImagePreviewDisplay)
                    self.ImagePreviewDisplay = ...
                        iptui.internal.ImagePreview;
                    self.FigureHandles(end+1) = self.ImagePreviewDisplay.Fig;
                    self.hToolGroup.addFigure(self.ImagePreviewDisplay.Fig);
                end
                hFig = self.ImagePreviewDisplay.Fig;
            else
                
                tabName = self.getFigName(csname);
                
                hFig = figure('NumberTitle', 'off',...
                    'Name',tabName,'Colormap',gray(2),...
                    'IntegerHandle','off','Tag',csname);
                
                % Set the WindowKeyPressFcn to a non-empty function. This is
                % effectively a no-op that executes everytime a key is pressed
                % when the App is in focus. This is done to prevent focus from
                % shifting to the MATLAB command window when a key is typed.
                hFig.WindowKeyPressFcn = @(~,~)[];
                hFig.WindowButtonDownFcn = @(~,~) self.buttonClicked(true);
                hFig.WindowButtonUpFcn = @(~,~) self.buttonClicked(false);
                
                self.FigureHandles(end+1) = hFig;
                self.hToolGroup.addFigure(hFig);
            end
            
            % Unregister image in drag and drop gestures when figures are
            % docked in toolgroup.
            self.hToolGroup.getFiguresDropTargetHandler.unregisterInterest(hFig);
            
            iptPointerManager(hFig);
            
            if ~isempty(im)
                hLeftPanel  = uipanel('Parent',hFig,'Position',[0 0 0.6 1],'BorderType','none','tag','LeftPanel');
                hRightPanel = uipanel('Parent',hFig,'Position',[0.6 0 0.4 1],'BorderType','none','tag','RightPanel');
                
                layoutInteractiveColorProjection(self,hRightPanel,im,csname,tMat);
                layoutScrollpanel(self,hLeftPanel);
                
                layoutInteractiveHistograms(self,hRightPanel,im,csname);
                
                histHandles = getappdata(hRightPanel,'HistPanelHandles');
                
                % Initialize masks
                [m,n,~] = size(im);
                self.sliderMask = true([m,n]);
                self.clusterMask = true([m,n]);
                self.updateMask(im,histHandles{:});
                self.updateClusterMask();
                
                % Prevent MATLAB graphics from being drawn in figures docked
                % within app.
                set(hFig,'HandleVisibility','callback');
                
                % Now that we are done setting up new color space figure,
                % Enable client action listener to manage state as user
                % switches between existing figures.
                self.ClientActionListener.Enabled = true;
                
                self.hFigCurrent = hFig;
                
                self.getClusterProjection(camPosition,camVector)
                
                if self.hHidePointCloud.Value
                    self.hidePointCloud()
                end
                
            else
                % Prevent MATLAB graphics from being drawn in figures docked
                % within app.
                set(hFig,'HandleVisibility','callback');
                
                % Now that we are done setting up new color space figure,
                % Enable client action listener to manage state as user
                % switches between existing figures.
                self.ClientActionListener.Enabled = true;
                
                self.hFigCurrent = hFig;
                
            end
            
        end
        
        
        function layoutScrollpanel(self,hLeftPanel)
            
            if isempty(self.hScrollpanel) || ~ishandle(self.hScrollpanel)
                
                hAx   = axes('Parent',hLeftPanel);
                
                % Figure will be docked before imshow is invoked. We want
                % to avoid warning about fit mag in context of a docked
                % figure.
                warnState = warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
                hIm  = imshow(self.imRGB,'Parent',hAx);
                warning(warnState);
                
                self.hScrollpanel = imscrollpanel(hLeftPanel,hIm);
                set(self.hScrollpanel,'Units','normalized',...
                    'Position',[0 0 1 1])
                
                % We need to ensure that graphics objects related to the
                % scrollpanel are constructed before we set the
                % magnification of the tool.
                drawnow; drawnow
                
                api = iptgetapi(self.hScrollpanel);
                api.setMagnification(api.findFitMag());
                
                % Turn on axes visibility
                hAx = findobj(self.hScrollpanel,'type','axes');
                set(hAx,'Visible','on');
                
                % Initialize Overlay color by setting axes color.
                set(hAx,'Color',self.maskColor);
                
                % Turn off axes gridding
                set(hAx,'XTick',[],'YTick',[]);
                
                % Hide axes border
                set(hAx,'XColor','none','YColor','none');
                
                hFree = uicontrol('Style','togglebutton','Parent',self.hScrollpanel,'Units','Normalized','Position',[0.01, 0.945, 0.04, 0.045],...
                    'Tag','SelectButton','Callback',@(~,~) self.lassoRegion(),'CData',self.freeIcon,...
                    'TooltipString',getString(message('images:colorSegmentor:addRegionTooltip')));
                
                iptSetPointerBehavior(hFree,@(hObj,evt) set(hObj,'Pointer','hand'));
                
            else
                % If scrollpanel has already been created, we simply want
                % to reparent it to the current figure that is being
                % created/in view.
                set(self.hScrollpanel,'Parent',hLeftPanel);
            end
            
        end
        
        
        function [hChan1Hist,hChan2Hist,hChan3Hist] = layoutInteractiveHistograms(self,hPanel,im,csname)
            
            import iptui.internal.InteractiveHistogram;
            import iptui.internal.InteractiveHistogramHue;
            
            margin = 5;
            hFigFlowSliders = uiflowcontainer('v0',...
                'Parent', hPanel,...
                'FlowDirection', 'TopDown', ...
                'Position',[0 0.6 1 0.4],...
                'Margin', margin,...
                'Tag','SlidersContainer');
            
            switch csname
                
                case 'RGB'
                    hChan1Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,1), 'ramp', {[0 0 0], [1 0 0]}, 'R');
                    hChan2Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,2), 'ramp', {[0 0 0], [0 1 0]}, 'G');
                    hChan3Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,3), 'ramp', {[0 0 0], [0 0 1]}, 'B');
                    
                case 'HSV'
                    ratios = [1 0.5 0.5];
                    drawnow; drawnow; drawnow %TODO: This is probably overkill. - jmather, 18 Sept 2013
                    [hPanelTop, hPanelMiddle, hPanelBottom, layoutPosition] = iptui.internal.createThreePanels(hPanel, ratios, margin);
                    setappdata(hPanel,'layoutPosition',layoutPosition);
                    hChan1Hist = InteractiveHistogramHue(hPanelTop, im(:,:,1));
                    hChan2Hist = InteractiveHistogram(hPanelMiddle, im(:,:,2), 'saturation');
                    hChan3Hist = InteractiveHistogram(hPanelBottom, im(:,:,3), 'BlackToWhite', 'V');
                    
                case 'L*a*b*'
                    hChan1Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,1), 'LStar', 'L*');
                    hChan2Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,2), 'aStar');
                    hChan3Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,3), 'bStar');
                    
                case 'YCbCr'
                    hChan1Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,1), 'BlackToWhite', 'Y');
                    hChan2Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,2), 'Cb');
                    hChan3Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,3), 'Cr');
                    
                otherwise
                    hChan1Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,1));
                    hChan2Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,2));
                    hChan3Hist = InteractiveHistogram(hFigFlowSliders, im(:,:,3));
                    
            end
            
            addlistener(hChan1Hist,'currentSelection', 'PostSet',...
                @(~,~) updateClusterDuringSliderDrag(self, im, hChan1Hist, hChan2Hist, hChan3Hist));
            
            addlistener([hChan2Hist,hChan3Hist],'currentSelection', 'PostSet',...
                @(~,~) updateClusterDuringSliderDrag(self, im, hChan1Hist, hChan2Hist, hChan3Hist));
            
            histograms = {hChan1Hist, hChan2Hist, hChan3Hist};
            
            setappdata(hPanel,'HistPanelHandles',histograms);
            setappdata(hPanel,'ColorspaceCData',im);
            
        end
        
        
        function resetSliders(self)
            
            % Remove freehand ROIs from image
            self.clearFreehands()
            
            % Get histograms for current figure
            hRightPanel = findobj(self.hFigCurrent, 'tag', 'RightPanel');
            histHandles = getappdata(hRightPanel, 'HistPanelHandles');
            
            % Apply maximum values to current celection for each color
            % channel and update each histogram
            for ii = 1:3
                histHandles{ii}.currentSelection = histHandles{ii}.histRange;
                histHandles{ii}.updateHistogram()
            end
            
            % Trigger event to update mask after resetting sliders.
            notify(self.hFigCurrent,'WindowMouseRelease')
            
        end
        
        
        function updateClusterDuringSliderDrag(self, im, hChan1Hist, hChan2Hist, hChan3Hist)
            % updateClusterDuringSliderDrag - If image is small, update
            % mask and point cloud as the slider is dragged.
            
            % If image is large, update mask after finishing a drag. If
            % image is small, update mask as you drag
            if self.isLiveUpdate.Value
                self.updateCluster(im, hChan1Hist, hChan2Hist, hChan3Hist)
            elseif isempty(self.hSliderMovedListener)
                self.hSliderMovedListener = addlistener(self.hFigCurrent,'WindowMouseRelease',@(hObj,evt) self.updateClusterAfterSliderDrag(hObj, evt, im, hChan1Hist, hChan2Hist, hChan3Hist));
            end
            
        end
        
        function updateClusterAfterSliderDrag(self, ~, ~, im, hChan1Hist, hChan2Hist, hChan3Hist)
            % updateClusterAfterSliderDrag - Triggered after mouse is
            % released for large images. Update the mask and point cloud
            delete(self.hSliderMovedListener);
            self.hSliderMovedListener = [];
            self.updateCluster(im, hChan1Hist, hChan2Hist, hChan3Hist)
            
        end
        
        function updateCluster(self,im, hChan1Hist, hChan2Hist, hChan3Hist)
            % Update Mask
            if ~self.isFreehandApplied
                self.clearFreehands()
            end
            self.updateMask(im, hChan1Hist, hChan2Hist, hChan3Hist);
            if self.hHidePointCloud.Value
                return;
            end
            % Update Point Cloud
            if self.is3DView
                self.hColorSpaceProjectionView.updatePointCloud(self.sliderMask);
            else
                self.updatePointCloud();
            end
            
        end
        
        function hColorProj = layoutInteractiveColorProjection(self,hPanel,im,csname,tMat)
            
            RGB = self.imRGB;
            
            m = size(RGB,1);
            n = size(RGB,2);
            
            % Move colorData and RGB data into Mx3 feature vector representation
            im = reshape(im,[m*n 3]);
            RGB = reshape(RGB,[m*n 3]);
            
            im = double(im);
            
            % Change coordinates for given colorspace
            switch (csname)
                case 'HSV'
                    Xcoord = im(:,2).*im(:,3).*cos(2*pi*im(:,1));
                    Ycoord = im(:,2).*im(:,3).*sin(2*pi*im(:,1));
                    im(:,1) = Xcoord;
                    im(:,2) = Ycoord;
                case {'L*a*b*','YCbCr'}
                    temp = im(:,1);
                    im(:,1) = im(:,2);
                    im(:,2) = im(:,3);
                    im(:,3) = temp;
            end
            
            % Compute and apply transformation matrix for PCA. This is the
            % default projection that is applied when the user selects a
            % new colorspace and the third vector is used to define the
            % default projection
            shiftVec = mean(im,1);
            im = bsxfun(@minus, im, shiftVec); % Mean shift feature vector
            
            setappdata(hPanel,'ColorspaceCDataForCluster',im);
            setappdata(hPanel,'TransformationMat',tMat);
            setappdata(hPanel,'ShiftVector',shiftVec);
            
            tMat = tMat(1:2,:);
            im = [im ones(size(im,1),1)]';
            colorDataPCA = (tMat*im)';
            
            setappdata(hPanel,'TransformedCDataForCluster',colorDataPCA);
            
            hColorProj = uipanel('Parent',hPanel,'BorderType','none','Units','Normalized','Position',[0,0,1,0.6],'Tag','ColorProj');
            set(hColorProj,'Visible','off','BackgroundColor',self.pointCloudColor);
            hAx = axes('Parent',hColorProj);
            scatter(hAx,colorDataPCA(:,1),colorDataPCA(:,2),6,im2double(RGB),'.','Tag','ScatterPlot');
            set(hAx,'XTick',[],'YTick',[],'Color',self.pointCloudColor,'Box','off','Units','normalized','Position',[0.01,0.01,0.98,0.98]);
            set(hAx,'Visible','off');
            
            hPoly = uicontrol('Style','togglebutton','Parent',hColorProj,'Units','Normalized','Position',[0.01, 0.915, 0.06, 0.075],...
                'Tag','PolyButton','Callback',@(hobj,evt) self.polyRegionForClusters(hobj,evt),'CData',self.polyIcon,...
                'TooltipString',getString(message('images:colorSegmentor:polygonButtonTooltip')));
            
            iptSetPointerBehavior(hPoly,@(hObj,evt) set(hObj,'Pointer','hand'));
            
            hClose = uicontrol('Style','pushbutton','Parent',hColorProj,'Units','Normalized','Position',[0.07, 0.915, 0.06, 0.075],...
                'Tag','RotateButton','Callback',@(~,~) self.show3DViewState(),'CData',self.rotateIcon,...
                'TooltipString',getString(message('images:colorSegmentor:rotateButtonTooltip')));
            
            iptSetPointerBehavior(hClose,@(hObj,evt) set(hObj,'Pointer','hand'));
            
            self.showStatusBar();
            
        end
        
        
    end
    
    % Methods used to layout each section of app
    methods (Access = private)
        
        function loadAppIcons(self)
            
            self.LoadImageIcon = matlab.ui.internal.toolstrip.Icon.IMPORT_24;
            self.newColorspaceIcon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/NewColorSpace_24.png'));
            self.hidePointCloudIcon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/HidePointCloud_16.png'));
            self.liveUpdateIcon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/LiveUpdate_24.png'));
            self.invertMaskIcon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/InvertMask_24px.png'));
            self.resetButtonIcon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/Reset_24.png'));
            self.zoomInIcon = matlab.ui.internal.toolstrip.Icon.ZOOM_IN_16;
            self.zoomOutIcon = matlab.ui.internal.toolstrip.Icon.ZOOM_OUT_16;
            self.panIcon = matlab.ui.internal.toolstrip.Icon.PAN_16;
            self.showBinaryIcon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/ShowBinary_24px.png'));
            self.createMaskIcon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/CreateMask_24px.png'));
            self.freeIcon = setUIControlIcon(fullfile(matlabroot,'/toolbox/images/icons/DrawFreehand_16.png'));
            self.polyIcon = setUIControlIcon(fullfile(matlabroot,'/toolbox/images/icons/DrawPolygon_16.png'));
            self.rotateIcon = setUIControlIcon(fullfile(matlabroot,'/toolbox/images/icons/Rotate3D_16.png'));
            % Import rotate pointer
            mousePointer = load(fullfile(matlabroot,'/toolbox/images/icons/rotatePointer.mat'));
            self.rotatePointer = mousePointer.rotatePointer;
            
        end
        
        
        function layoutLoadImageSection(self)
            
            % Load Image Button
            loadImageButton = matlab.ui.internal.toolstrip.SplitButton(getString(message('images:colorSegmentor:loadImageSplitButtonTitle')), ...
                self.LoadImageIcon);
            loadImageButton.Tag = 'btnLoadImage';
            loadImageButton.Description = getString(message('images:colorSegmentor:loadImageTooltip'));
            
            % Drop down list
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:loadImageFromFile')));
            sub_item1.Icon = matlab.ui.internal.toolstrip.Icon.IMPORT_16;
            sub_item1.ShowDescription = false;
            addlistener(sub_item1, 'ItemPushed', @self.loadImageFromFile);
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:loadImageFromWorkspace')));
            sub_item2.Icon = matlab.ui.internal.toolstrip.Icon.IMPORT_16;
            sub_item2.ShowDescription = false;
            addlistener(sub_item2, 'ItemPushed', @self.loadImageFromWorkspace);
            
            sub_item3 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:loadImageFromCamera')));
            sub_item3.Icon = matlab.ui.internal.toolstrip.Icon(...
                fullfile(matlabroot, 'toolbox', 'images', 'icons', 'color_thresholder_load_camera_16.png'));
            sub_item3.ShowDescription = false;
            addlistener(sub_item3, 'ItemPushed', @self.loadImageFromCamera);
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            sub_popup.add(sub_item3);
            
            loadImageButton.Popup = sub_popup;
            loadImageButton.Popup.Tag = 'Load Image Popup';
            addlistener(loadImageButton, 'ButtonPushed', @self.loadImageFromFile);
            
            c = self.LoadImageSection.addColumn();
            c.add(loadImageButton);
            
            self.lassoSensitiveComponentHandles{end+1} = loadImageButton;
            
        end
        
        function layoutColorSpacesSection(self)
            
            self.hColorSpacesButton = matlab.ui.internal.toolstrip.Button(getString(message('images:colorSegmentor:newColorspace')), ...
                self.newColorspaceIcon);
            self.hColorSpacesButton.Tag = 'btnChooseColorSpace';
            self.hColorSpacesButton.Description = getString(message('images:colorSegmentor:addNewColorspaceTooltip'));
            addlistener(self.hColorSpacesButton, 'ButtonPushed', @(~,~) self.compareColorSpaces() );
            
            c = self.ColorSpacesSection.addColumn();
            c.add(self.hColorSpacesButton);
            
            self.lassoSensitiveComponentHandles{end+1} = self.hColorSpacesButton;
            
        end
        
        function layoutChooseProjectionSection(self)
            
            self.hPointCloudBackgroundSlider = matlab.ui.internal.toolstrip.Slider([0,100],6);
            self.hPointCloudBackgroundSlider.Ticks = 0;
            self.hPointCloudBackgroundSlider.Description = getString(message('images:colorSegmentor:pointCloudSliderTooltip'));
            self.pointCloudSliderMovedListener = addlistener(self.hPointCloudBackgroundSlider,'ValueChanged',@(hobj,evt) pointCloudSliderMoved(self,hobj,evt) );
            self.hPointCloudBackgroundSlider.Tag = 'sliderPointCloudBackground';
            
            pointCloudColorLabel = matlab.ui.internal.toolstrip.Label(getString(message('images:colorSegmentor:pointCloudSlider')));
            pointCloudColorLabel.Tag = 'labelPointCloudOpacity';
            
            self.hHidePointCloud = matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:hidePointCloud')),self.hidePointCloudIcon);
            self.hHidePointCloud.Tag = 'btnHidePointCloud';
            self.hHidePointCloud.Description = getString(message('images:colorSegmentor:hidePointCloudTooltip'));
            addlistener(self.hHidePointCloud, 'ValueChanged', @(~,~) self.hidePointCloud() );

            c = self.ChooseProjectionSection.addColumn('HorizontalAlignment','center','Width',80);
            c.add(pointCloudColorLabel);
            c.add(self.hPointCloudBackgroundSlider);
            c2 = self.ChooseProjectionSection.addColumn();
            c2.add(self.hHidePointCloud);
            
            self.hChangeUIComponentHandles{end+1} = self.hPointCloudBackgroundSlider;
            self.lassoSensitiveComponentHandles{end+1} = self.hHidePointCloud;
            self.hChangeUIComponentHandles{end+1} = self.hHidePointCloud;
            
        end
        
        
        function layoutManualSelectionSection(self)
            
            self.isLiveUpdate = matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:liveUpdate')),self.liveUpdateIcon);
            self.isLiveUpdate.Description = getString(message('images:colorSegmentor:liveUpdateTooltip'));
            self.isLiveUpdate.Tag = 'btnLiveUpdate';
            
            c = self.ManualSelectionSection.addColumn();
            c.add(self.isLiveUpdate);

            self.hChangeUIComponentHandles{end+1} = self.isLiveUpdate;
            
        end
        
        function layoutThresholdControlsSection(self)
            
            self.hInvertMaskButton = matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:invertMask')),...
                self.invertMaskIcon);
            self.hInvertMaskButton.Tag = 'btnInvertMask';
            self.hInvertMaskButton.Description = getString(message('images:colorSegmentor:invertMaskTooltip'));
            self.invertMaskItemStateChangedListener = addlistener(self.hInvertMaskButton, 'ValueChanged', @self.invertMaskButtonPress);
            
            % Add reset button to reset slider positions
            resetButton = matlab.ui.internal.toolstrip.Button(getString(message('images:colorSegmentor:resetButton')), self.resetButtonIcon);
            resetButton.Tag = 'btnResetSliders';
            resetButton.Description = getString(message('images:colorSegmentor:resetButtonTooltip'));
            addlistener(resetButton, 'ButtonPushed', @(~,~) self.resetSliders());
            
            c = self.ThresholdControlsSection.addColumn();
            c.add(self.hInvertMaskButton);
            c2 = self.ThresholdControlsSection.addColumn();
            c2.add(resetButton);

            self.hChangeUIComponentHandles{end+1} = self.hInvertMaskButton;
            self.hChangeUIComponentHandles{end+1} = resetButton;
            self.lassoSensitiveComponentHandles{end+1} = resetButton;
            
        end
        
        function layoutPanZoomSection(self)
            
            self.hZoomInButton = matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:commonUIString:zoomInTooltip')),...
                self.zoomInIcon);
            addlistener(self.hZoomInButton, 'ValueChanged', @self.zoomIn);
            self.hChangeUIComponentHandles{end+1} = self.hZoomInButton;
            self.hZoomInButton.Tag = 'btnZoomIn';
            self.hZoomInButton.Description = getString(message('images:commonUIString:zoomInTooltip'));
            
            self.hZoomOutButton = matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:commonUIString:zoomOutTooltip')),...
                self.zoomOutIcon);
            addlistener(self.hZoomOutButton, 'ValueChanged', @self.zoomOut);
            self.hChangeUIComponentHandles{end+1} = self.hZoomOutButton;
            self.hZoomOutButton.Tag = 'btnZoomOut';
            self.hZoomOutButton.Description = getString(message('images:commonUIString:zoomOutTooltip'));
            
            self.hPanButton = matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:pan')),...
                self.panIcon);
            addlistener(self.hPanButton, 'ValueChanged', @self.panImage);
            self.hChangeUIComponentHandles{end+1} = self.hPanButton;
            self.hPanButton.Tag = 'btnPan';
            self.hPanButton.Description = getString(message('images:colorSegmentor:pan'));

            c = self.PanZoomSection.addColumn();
            c.add(self.hZoomInButton);
            c.add(self.hZoomOutButton);
            c.add(self.hPanButton);
            
            self.lassoSensitiveComponentHandles{end+1} = self.hZoomInButton;
            self.lassoSensitiveComponentHandles{end+1} = self.hZoomOutButton;
            self.lassoSensitiveComponentHandles{end+1} = self.hPanButton;
            
        end
        
        function layoutViewSegmentationSection(self)
            
            self.hShowBinaryButton = matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:showBinary')),...
                self.showBinaryIcon);
            self.binaryButonStateChangedListener = addlistener(self.hShowBinaryButton, 'ValueChanged', @self.showBinaryPress);
            self.hChangeUIComponentHandles{end+1} = self.hShowBinaryButton;
            self.hShowBinaryButton.Tag = 'btnShowBinary';
            self.hShowBinaryButton.Description = getString(message('images:colorSegmentor:viewBinaryTooltip'));
            
            self.hMaskOpacitySlider = matlab.ui.internal.toolstrip.Slider([0,100],100);
            self.hMaskOpacitySlider.Ticks = 0;
            self.sliderMovedListener = addlistener(self.hMaskOpacitySlider,'ValueChanged',@self.opacitySliderMoved);
            self.hChangeUIComponentHandles{end+1} = self.hMaskOpacitySlider;
            self.hMaskOpacitySlider.Tag = 'sliderMaskOpacity';
            self.hMaskOpacitySlider.Description = getString(message('images:colorSegmentor:sliderTooltip'));
            
            overlayColorLabel   = matlab.ui.internal.toolstrip.Label(getString(message('images:colorSegmentor:backgroundColor')));
            overlayColorLabel.Tag = 'labelOverlayColor';
            overlayOpacityLabel = matlab.ui.internal.toolstrip.Label(getString(message('images:colorSegmentor:backgroundOpacity')));
            overlayOpacityLabel.Tag = 'labelOverlayOpacity';
            
            % There is no MCOS interface to set the icon of a TSButton
            % directly from a uint8 buffer.
            self.hOverlayColorButton = matlab.ui.internal.toolstrip.Button();
            self.setTSButtonIconFromImage(self.hOverlayColorButton,zeros(16,16,'uint8'));
            addlistener(self.hOverlayColorButton,'ButtonPushed',@self.chooseOverlayColor);
            self.hChangeUIComponentHandles{end+1} = self.hOverlayColorButton;
            self.hOverlayColorButton.Tag = 'btnOverlayColor';
            self.hOverlayColorButton.Description = getString(message('images:colorSegmentor:backgroundColorTooltip'));

            c = self.ViewSegmentationSection.addColumn('HorizontalAlignment','right');
            c.add(overlayColorLabel);
            c.add(overlayOpacityLabel);
            c2 = self.ViewSegmentationSection.addColumn('Width',80);
            c2.add(self.hOverlayColorButton);
            c2.add(self.hMaskOpacitySlider);
            c3 = self.ViewSegmentationSection.addColumn();
            c3.add(self.hShowBinaryButton);
            
        end
        
        function layoutExportSection(self)

            %Export Button
            exportButton = matlab.ui.internal.toolstrip.SplitButton(getString(message('images:colorSegmentor:export')), ...
                self.createMaskIcon);
            exportButton.Tag = 'btnExport';
            exportButton.Description = getString(message('images:colorSegmentor:exportButtonTooltip'));

            % Drop down list
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:exportImages')));
            sub_item1.Icon = matlab.ui.internal.toolstrip.Icon(...
                    fullfile(matlabroot,'/toolbox/images/icons/CreateMask_16px.png'));
            sub_item1.ShowDescription = false;
            addlistener(sub_item1, 'ItemPushed', @(~,~) self.exportDataToWorkspace);
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:exportFunction')));
            sub_item2.Icon = matlab.ui.internal.toolstrip.Icon(...
                    fullfile(matlabroot,'/toolbox/images/icons/GenerateMATLABScript_Icon_16px.png'));
            sub_item2.ShowDescription = false;
            addlistener(sub_item2, 'ItemPushed', @(~,~) iptui.internal.generateColorSegmentationCode(self));
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            
            exportButton.Popup = sub_popup;
            exportButton.Popup.Tag = 'Export Popup';
            addlistener(exportButton, 'ButtonPushed', @(~,~) self.exportDataToWorkspace());
            
            %Layout
            c = self.ExportSection.addColumn();
            c.add(exportButton);
            
            self.hChangeUIComponentHandles{end+1} = exportButton;
            self.lassoSensitiveComponentHandles{end+1} = exportButton;
            
        end
        
    end
    
    % Region selection functionality
    methods (Access = private)
        
        %------------------------------------------------------------------
        function lassoRegion(self)
            % lassoRegion - Add freehand ROI to current colorspace figure.
            
            % If cluster selection tool has already been selected then exit out
            if ~isempty(self.polyManager)
                self.disablePolyRegion()
                self.polyManager = [];
                hPanel = findobj(self.hFigCurrent, 'Tag', 'RightPanel');
                PolyButton = findobj(hPanel,'Tag','PolyButton');
                PolyButton.Value = 0;
            end
            
            % If Select Colors tool has already been selected then delete
            if ~isempty(self.freehandManager)
                self.resetLassoTool()
                self.freehandManager = [];
            end
            
            SelectButton = findobj(self.hScrollpanel,'Tag','SelectButton');
            SelectButton.Value = 1;
            
            % Keep track of the state of the toolstrip buttons, and disable
            % tools that could interfere with region selection.
            self.preLassoPanZoomState = self.getStateOfPanZoomMode();
            self.preLassoToolstripState = self.getStateOfLassoSensitiveTools();
            self.setStateOfPanZoomMode('off')
            self.disableLassoSensitiveTools()
            
            hAx = findobj(self.hScrollpanel, 'type', 'axes');
            self.freehandManager = iptui.internal.ImfreehandModeContainer(hAx);
            self.freehandManager.enableInteractivePlacement()
            
            self.hFreehandListener = addlistener(self.freehandManager, 'hROI', 'PostSet', ...
                @(obj,evt) self.freehandedAdded(obj, evt) );
            
        end
        
        function polyRegionForClusters(self,varargin)
            % polyRegionForClusters - Add impoly ROI to current colorspace
            % figure.
            
            % If cluster selection tool has already been selected
            if ~isempty(self.polyManager)
                self.disablePolyRegion()
                self.polyManager = [];
            end
            
            % If Select Colors tool has already been selected then delete
            if ~isempty(self.freehandManager)
                self.resetLassoTool()
                self.freehandManager = [];
                SelectButton = findobj(self.hScrollpanel,'Tag','SelectButton');
                SelectButton.Value = 0;
            end
            
            varargin{2}.Source.Value = 1;
            
            % Keep track of the state of the toolstrip buttons, and disable
            % tools that could interfere with region selection.
            self.preLassoPanZoomState = self.getStateOfPanZoomMode();
            self.preLassoToolstripState = self.getStateOfLassoSensitiveTools();
            self.setStateOfPanZoomMode('off')
            self.disableLassoSensitiveTools()
            self.clearStatusBar();
            % Get axes and set xlim and ylim to manual the user cannot
            % change limits accidentally
            hScat = findobj(self.hFigCurrent, 'Type','Scatter','Tag', 'ScatterPlot');
            hScat.Parent.XLimMode = 'Manual';
            hScat.Parent.YLimMode = 'Manual';
            self.polyManager = iptui.internal.ImpolyModeContainer(hScat.Parent);
            self.polyManager.enableInteractivePlacement()
            
            self.hPolyListener = addlistener(self.polyManager, 'hROI', 'PostSet', ...
                @(obj,evt) self.polygonAddedForClusters(obj, evt) );
            
        end
        
        %------------------------------------------------------------------
        function freehandedAdded(self, ~, ~)
            % freehandedAdded - Callback that fires when a hROI changes.
            
            SelectButton = findobj(self.hScrollpanel,'Tag','SelectButton');
            SelectButton.Value = 0;
            
            self.resetLassoTool()
            
            % If image is large, update mask after finishing a drag. If
            % Image is small, update mask as you drag
            self.freehandManager.hROI.addNewPositionCallback(@(~,~) self.updateThresholdDuringROIDrag());
            
            hFree = self.freehandManager.hROI;
            self.freehandManager = [];
            
            self.addFreehandROIHandleToCollection(hFree)
            origDeleteFcn = get(hFree, 'DeleteFcn');
            set(hFree, 'DeleteFcn', @(obj,evt) newFreehandDeleteFcn(self, obj, evt, origDeleteFcn) )
            
            self.applyROIs()
            
        end
        
        %------------------------------------------------------------------
        function polygonAddedForClusters(self, ~, ~)
            % polygonAddedForClusters - Callback that fires when a hROI
            % changes.
            
            hPanel = findobj(self.hFigCurrent, 'Tag', 'RightPanel');
            PolyButton = findobj(hPanel,'Tag','PolyButton');
            PolyButton.Value = 0;
            
            self.disablePolyRegion()
            
            % If image is large, update mask after finishing a drag. If
            % Image is small, update mask as you drag
            self.polyManager.hROI.addNewPositionCallback(@(~,~) self.updateClusterDuringROIDrag());
            
            hScat = findobj(self.hFigCurrent, 'Type','Scatter','Tag', 'ScatterPlot');
            fcn = makeConstrainToRectFcn('impoly',get(hScat.Parent,'XLim'),get(hScat.Parent,'YLim'));
            self.polyManager.hROI.setPositionConstraintFcn(fcn);
            
            hFree = self.polyManager.hROI;
            self.polyManager = [];
            
            if size(hFree.getPosition,1) > 1
                self.addPolyROIHandleToCollection(hFree)
                origDeleteFcn = get(hFree, 'DeleteFcn');
                set(hFree, 'DeleteFcn', @(obj,evt) newPolyDeleteFcn(self, obj, evt, origDeleteFcn) )
            else
                hFree.delete()
            end
            
            self.applyClusterROIs()
            
        end
        
        function updateClusterDuringROIDrag(self)
            
            % If image is large, update mask after finishing a drag. If
            % Image is small, update mask as you drag
            if self.isLiveUpdate.Value || ~self.isFigClicked
                self.applyClusterROIs()
            elseif isempty(self.hPolyMovedListener)
                % Check if listener has already been added for when the mouse
                % will be released
                self.hPolyMovedListener = addlistener(self.hFigCurrent,'WindowMouseRelease',@(~,~) self.updateClusterAfterROIDrag());
            end
            
        end
        
        function updateClusterAfterROIDrag(self)
            
            % Delete listener and update mask
            delete(self.hPolyMovedListener);
            self.hPolyMovedListener = [];
            self.applyClusterROIs();
            
        end
        
        function updateThresholdDuringROIDrag(self)
            
            % If image is large, update mask after finishing a drag. If
            % Image is small, update mask as you drag
            if self.isLiveUpdate.Value
                self.applyROIs()
            elseif isempty(self.hFreehandMovedListener)
                % Check if listener has already been added for when the mouse
                % will be released
                self.hFreehandMovedListener = addlistener(self.hFigCurrent,'WindowMouseRelease',@(~,~) self.updateThresholdAfterROIDrag());
            end
            
        end
        
        function updateThresholdAfterROIDrag(self)
            
            % Delete listener and update mask
            delete(self.hFreehandMovedListener);
            self.hFreehandMovedListener = [];
            self.applyROIs();
            
        end
        
        %------------------------------------------------------------------
        function disablePolyRegion(self)
            
            self.polyManager.disableInteractivePlacement()
            self.enableLassoSensitiveTools(self.preLassoToolstripState)
            self.setStateOfPanZoomMode(self.preLassoPanZoomState)
            delete(self.hPolyListener);
            self.hPolyListener = [];
            
        end
        
        function resetLassoTool(self)
            
            self.freehandManager.disableInteractivePlacement()
            self.enableLassoSensitiveTools(self.preLassoToolstripState)
            self.setStateOfPanZoomMode(self.preLassoPanZoomState)
            self.hFreehandListener = [];
            
        end
        
        %------------------------------------------------------------------
        function newFreehandDeleteFcn(self, obj, evt, origDeleteFcn)
            % newFreehandDeleteFcn - Delete ROI and remove from collection.
            % (1) Call the original delete function.
            if isgraphics(obj) && ~isempty(origDeleteFcn)
                origDeleteFcn(obj, evt);
            end
            
            if ~isvalid(self)
                % App is being destroyed...
                return
            end
            
            % (2) Remove the handle from the collection of imfreehand objects.
            % *Find the row in the table.
            figuresWithROIs = [self.hFreehandROIs{:,1}];
            idx = find(figuresWithROIs == self.hFigCurrent, 1);
            if isempty(idx)
                return
            end
            % Remove the handle from the row (or the whole row if the
            % figure is being deleted).
            if ~isvalid(self.hFigCurrent) || strcmpi(self.hFigCurrent.Name, getString(message('images:colorSegmentor:MainPreviewFigure')))
                self.hFreehandROIs(idx,:) = [];
                return
            end
            currentROIs = self.hFreehandROIs{idx,2};
            idxArray = arrayfun(@(h) isequal(get(h, 'BeingDeleted'), 'on'), currentROIs);
            currentROIs(idxArray) = [];
            self.hFreehandROIs{idx,2} = currentROIs;
            
            % If ROI was manually deleted, reapply any remainig ROIs if
            % applicable and update the mask. If ROI was programmatically
            % deleted (via resetThresholder or clearFreehands), do not
            % apply ROIs and update the mask
            if self.isManualDelete
                self.applyROIs()
            end
            
        end
        
        %------------------------------------------------------------------
        function newPolyDeleteFcn(self, obj, evt, origDeleteFcn)
            % newPolyDeleteFcn - Delete poly ROI and remove from collection.
            % (1) Call the original delete function.
            if isgraphics(obj) && ~isempty(origDeleteFcn)
                origDeleteFcn(obj, evt);
            end
            
            if ~isvalid(self)
                % App is being destroyed...
                return
            end
            
            % (2) Remove the handle from the collection of imfreehand objects.
            % *Find the row in the table.
            figuresWithROIs = [self.hPolyROIs{:,1}];
            idx = find(figuresWithROIs == self.hFigCurrent, 1);
            if isempty(idx)
                return
            end
            % Remove the handle from the row (or the whole row if the
            % figure is being deleted).
            if ~isvalid(self.hFigCurrent) || strcmpi(self.hFigCurrent.Name, getString(message('images:colorSegmentor:MainPreviewFigure')))
                self.hPolyROIs(idx,:) = [];
                return
            end
            currentROIs = self.hPolyROIs{idx,2};
            % Check for invalid polygons. These can happen by deleting each
            % vertex one at a time
            idxArray = arrayfun(@(h) ~isvalid(h), currentROIs);
            % If all polygons are valid, then find the one being deleted
            if isempty(idxArray)
                idxArray = arrayfun(@(h) isequal(get(h, 'BeingDeleted'), 'on'), currentROIs);
            end
            currentROIs(idxArray) = [];
            self.hPolyROIs{idx,2} = currentROIs;
            % Update mask for clustering if figure still exists
            if isvalid(self.hFigCurrent) && ~self.isProjectionApplied
                self.applyClusterROIs()
            end
            
        end
        
        %------------------------------------------------------------------
        function addPolyROIHandleToCollection(self, newROIHandle)
            % addPolyROIHandleToCollection - Keep track of the new ROI.
            % Special case for first ROI of the app.
            if isempty(self.hPolyROIs)
                self.hPolyROIs = {self.hFigCurrent, newROIHandle};
                return
            end
            % Add this ROI's handle to a new or existing row in the table.
            idx = iptui.internal.findFigureIndexInCollection(self.hFigCurrent,self.hPolyROIs);
            if isempty(idx)
                self.hPolyROIs(end+1,:) = {self.hFigCurrent, newROIHandle};
            else
                self.hPolyROIs{idx,2} = [self.hPolyROIs{idx,2}, newROIHandle];
            end
            
        end
        
        %------------------------------------------------------------------
        function addFreehandROIHandleToCollection(self, newROIHandle)
            % addFreehandROIHandleToCollection - Keep track of the new ROI.
            % Special case for first ROI of the app.
            if isempty(self.hFreehandROIs)
                self.hFreehandROIs = {self.hFigCurrent, newROIHandle};
                return
            end
            % Add this ROI's handle to a new or existing row in the table.
            idx = iptui.internal.findFigureIndexInCollection(self.hFigCurrent,self.hFreehandROIs);
            if isempty(idx)
                self.hFreehandROIs(end+1,:) = {self.hFigCurrent, newROIHandle};
            else
                self.hFreehandROIs{idx,2} = [self.hFreehandROIs{idx,2}, newROIHandle];
            end
            
        end
        
        %------------------------------------------------------------------
        function applyROIs(self)
            
            self.isFreehandApplied = true;
            
            % Get the handles to the histograms.
            hRightPanel = findobj(self.hFigCurrent, 'tag', 'RightPanel');
            histHandles = getappdata(hRightPanel, 'HistPanelHandles');
            
            if ~iptui.internal.hasValidROIs(self.hFigCurrent,self.hFreehandROIs)
                self.resetSliders()
                self.isFreehandApplied = false;
                return
            end
            
            % Get the new selection from the ROI values.
            cData = getappdata(hRightPanel, 'ColorspaceCData');
            [lim1, lim2, lim3] = colorStats(self, cData);
            
            if (isempty(lim1) || isempty(lim2) || isempty(lim3))
                self.isFreehandApplied = false;
                return
            end
            
            % Update the histograms' current selection and mask.
            histHandles{1}.currentSelection = lim1;
            histHandles{1}.updateHistogram();
            histHandles{2}.currentSelection = lim2;
            histHandles{2}.updateHistogram();
            histHandles{3}.currentSelection = lim3;
            histHandles{3}.updateHistogram();
            
            
            if ~self.isLiveUpdate.Value
                delete(self.hSliderMovedListener);
                self.hSliderMovedListener = [];
                self.updateMask(cData, histHandles{:})
            end
            
            if ~self.hHidePointCloud.Value
                self.applyClusterROIs();
            end
            
            self.isFreehandApplied = false;
            
        end
        
        %------------------------------------------------------------------
        function applyClusterROIs(self)
            % applyClusterROIs - Apply all polygons drawn on 2D projection
            % to the mask
            
            % Get the handles to the Right Panel and point cloud
            hRightPanel = findobj(self.hFigCurrent, 'tag', 'RightPanel');
            im = getappdata(hRightPanel,'TransformedCDataForCluster');
            
            % Get the new selection from the ROI values
            if ~iptui.internal.hasValidROIs(self.hFigCurrent,self.hPolyROIs)
                self.updateClusterMask();
                if self.is3DView
                    self.hColorSpaceProjectionView.updatePointCloud(self.sliderMask);
                else
                    self.updatePointCloud();
                end
                return
            end
            
            % Get all ROIs for this figure
            hROIs = iptui.internal.findROIs(self.hFigCurrent,self.hPolyROIs);
            
            imgSize = size(self.imRGB);
            bw = false(imgSize(1:2));
            
            % Apply each valid ROI to mask
            for p = 1:numel(hROIs)
                % If polygon has 1-2 points, do not apply to mask
                if isvalid(hROIs(p))
                    hPoints = hROIs(p).getPosition;
                    % Handle polygon edge cases
                    if size(hPoints,1) == 1
                        % Don't allow any 1-vertex polygon.
                        delete(hROIs(p));
                        return
                    end
                    % Find points inside polygon and apply them to mask
                    in = images.internal.inpoly(im(:,1),im(:,2),hPoints(:,1),hPoints(:,2));
                    in = reshape(in,size(bw));
                    bw = bw | in;
                end
            end
            
            % Update mask with new mask created here
            self.updateClusterMask(bw);
            self.updatePointCloud();
            
        end
        
        %------------------------------------------------------------------
        function [lim1, lim2, lim3] = colorStats(self, cData)
            % colorStats - Compute limits of colors within ROIs
            
            % Create a mask of pixels under the ROIs.
            hROIs = iptui.internal.findROIs(self.hFigCurrent,self.hFreehandROIs);
            
            imgSize = size(cData);
            bw = false(imgSize(1:2));
            
            for p = 1:numel(hROIs)
                if isvalid(hROIs(p))
                    bw = bw | hROIs(p).createMask;
                end
            end
            
            % Compute color min and max for pixels under the mask.
            samplesInROI = samplesUnderMask(cData, bw);
            
            lim1 = computeHLim(samplesInROI(:,1));
            lim2 = [min(samplesInROI(:,2)), max(samplesInROI(:,2))];
            lim3 = [min(samplesInROI(:,3)), max(samplesInROI(:,3))];
            
        end
        
        %------------------------------------------------------------------
        function hideOtherROIs(self)
            % hideOtherROIs - Hide ROIs not attached to current figure.
            
            % Hide ROIs that aren't part of the current figure.
            if ~isempty(self.hFreehandROIs)
                figuresWithROIs = [self.hFreehandROIs{:,1}];
                idx = figuresWithROIs == self.hFigCurrent;
                hROIs = self.hFreehandROIs(~idx,2);
                for p = 1:numel(hROIs)
                    tmp = hROIs{p};
                    for q = 1:numel(tmp)
                        if isvalid(tmp(q))
                            set(tmp(q), 'Visible', 'off')
                            set(findall(tmp(q)), 'HitTest', 'off')
                        end
                    end
                end
                hROIs = self.hFreehandROIs(idx,2);
                for p = 1:numel(hROIs)
                    tmp = hROIs{p};
                    for q = 1:numel(tmp)
                        if isvalid(tmp(q))
                            set(tmp(q), 'Visible', 'on')
                            set(findall(tmp(q)), 'HitTest', 'on')
                        end
                    end
                end
            end
            
        end
        
        %------------------------------------------------------------------
        function stateVec = getStateOfLassoSensitiveTools(self)
            vecLength = numel(self.lassoSensitiveComponentHandles);
            stateVec = false(1, vecLength);
            
            for idx = 1:vecLength
                stateVec(idx) = self.lassoSensitiveComponentHandles{idx}.Enabled;
            end
        end
        
        %------------------------------------------------------------------
        function disableLassoSensitiveTools(self)
            vecLength = numel(self.lassoSensitiveComponentHandles);
            
            for idx = 1:vecLength
                self.lassoSensitiveComponentHandles{idx}.Enabled = false;
            end
        end
        
        %------------------------------------------------------------------
        function enableLassoSensitiveTools(self, stateVec)
            vecLength = numel(self.lassoSensitiveComponentHandles);
            
            for idx = 1:vecLength
                self.lassoSensitiveComponentHandles{idx}.Enabled = stateVec(idx);
            end
        end
        
        %------------------------------------------------------------------
        function panZoomState = getStateOfPanZoomMode(self)
            %getStateOfPanZoomMode  Determine state of pan/zoom tools.
            
            panZoomState = {...
                self.hZoomInButton,   self.hZoomInButton.Value
                self.hZoomOutButton,  self.hZoomOutButton.Value
                self.hPanButton,      self.hPanButton.Value};
        end
        
        %------------------------------------------------------------------
        function setStateOfPanZoomMode(self, panZoomState)
            %setPanZoomState  Adjust state of pan/zoom tools.
            
            if isequal(panZoomState, 'off')
                self.hZoomInButton.Value = false;
                self.hZoomOutButton.Value = false;
                self.hPanButton.Value = false;
            else
                for idx=1:size(panZoomState,1)
                    obj = panZoomState{idx,1};
                    obj.Value = panZoomState{idx,2};
                end
            end
        end
    end
    
    % Callback functions used by uicontrols in colorSegmentor app
    methods (Access = private)
        
        function loadImageFromFile(self,varargin)
            
            user_canceled_import = ...
                self.showImportingDataWillCauseDataLossDlg(...
                getString(message('images:colorSegmentor:loadingNewImageMessage')), ...
                getString(message('images:colorSegmentor:loadingNewImageTitle')));
            if ~user_canceled_import
                
                % Remove the Camera tab if exist.
                if isCameraPreviewInApp(self)
                    % Close the preview window.
                    self.ImageCaptureTab.closePreviewWindowCallback;
                end
                
                filename = imgetfile();
                if ~isempty(filename)
                    
                    im = imread(filename);
                    if ~iptui.internal.ColorSegmentationTool.isValidRGBImage(im)
                        hdlg = errordlg(getString(message('images:colorSegmentor:nonTruecolorErrorDlgText')),...
                            getString(message('images:colorSegmentor:nonTruecolorErrorDlgTitle')),'modal');
                        % We need error dlg to be blocking, otherwise
                        % loadImageFromFile() is invoked before dlg
                        % finishes setting itself up and becomes modal.
                        uiwait(hdlg);
                        % Drawnow is necessary so that imgetfile dialog will
                        % enforce modality in next call to imgetfile that
                        % arrises from recursion.
                        drawnow
                        self.loadImageFromFile();
                        return;
                    end
                    
                    self.importImageData(im);
                    
                end
            end
        end
        
        
        function loadImageFromWorkspace(self,varargin)
            
            user_canceled_import = ...
                self.showImportingDataWillCauseDataLossDlg(...
                getString(message('images:colorSegmentor:loadingNewImageMessage')), ...
                getString(message('images:colorSegmentor:loadingNewImageTitle')));
            
            if ~user_canceled_import
                
                % Remove the Camera tab if exist.
                if isCameraPreviewInApp(self)
                    % Close the preview window.
                    self.ImageCaptureTab.closePreviewWindowCallback;
                end
                
                [im,~,~,~,user_canceled_dlg] = iptui.internal.imgetvar([],true);
                if ~user_canceled_dlg
                    self.importImageData(im);
                end
                
            end
            
        end
        
        
        function loadImageFromCamera(self, varargin)
            
            if isCameraPreviewInApp(self)
                existingTabs = self.hToolGroup.TabNames;
                
                % If image capture tab is not in the toolgroup, add it and bring
                % focus to it.
                if ~any(strcmp(existingTabs, getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                    % Add the tab to tool group.
                    add(self.hTabGroup, getToolTab(self.ImageCaptureTab), 2);
                end
                
                % Create Preview Figure - pass an empty image.
                self.createColorspaceSegmentationView([], getString(message('images:colorSegmentor:MainPreviewFigure')));
                
                self.hTabGroup.SelectedTab = getToolTab(self.ImageCaptureTab);
                
                % Set it as the current figure.
                self.hFigCurrent = self.FigureHandles(1);
                
                return;
            end
            
            user_canceled_import = ...
                self.showImportingDataWillCauseDataLossDlg(...
                getString(message('images:colorSegmentor:takingNewSnapshotMessage')), ...
                getString(message('images:colorSegmentor:takeNewSnapshotTitle')));
            
            if ~user_canceled_import
                existingTabs = self.hToolGroup.TabNames;
                
                % If image capture tab is not in the toolgroup, add it and bring
                % focus to it.
                if ~any(strcmp(existingTabs, getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                    % Create the contextual tab.
                    self.ImageCaptureTab = iptui.internal.ImageCaptureTab(self);
                    if (~self.ImageCaptureTab.LoadTab)
                        self.ImageCaptureTab = [];
                        return;
                    end
                    % Add the tab to tool group.
                    add(self.hTabGroup, getToolTab(self.ImageCaptureTab), 2);
                end
                
                % Create Preview Figure - pass an empty image.
                self.createColorspaceSegmentationView([], getString(message('images:colorSegmentor:MainPreviewFigure')));
                
                % Create the device and launch preview.
                self.ImageCaptureTab.createDevice;
                
                self.hTabGroup.SelectedTab = getToolTab(self.ImageCaptureTab);
                
                % Show camera preview.
                self.ImagePreviewDisplay.makeFigureVisible();
            end
        end
        
        
        function compareColorSpaces(self)
            
            % Manage settings for Choose Color Space tab
            self.manageControlsOnNewColorspace();
            self.setControlsEnabled(false);
            self.hColorSpacesButton.Enabled = false;
            
            % Enable button to change background color
            self.hPointCloudBackgroundSlider.Enabled = true;
            
            % Check if current montage view already exists
            if self.hasCurrentValidMontageInstance()
                self.hColorSpaceMontageView.bringToFocusInSpecifiedPosition();
            else
                self.hColorSpaceMontageView = iptui.internal.ColorSpaceMontageView(self.hToolGroup,self.imRGB,self.pointCloudColor,self.rotatePointer);
                
                % We maintain the reference to a listener for
                % SelectedColorSpace PostSet in ColorSegmentationTool to create
                % a new document tab when the color space is selected
                self.colorspaceSelectedListener = event.proplistener(self.hColorSpaceMontageView,...
                    self.hColorSpaceMontageView.findprop('SelectedColorSpace'),...
                    'PostSet',@(hobj,evt) self.colorSpaceSelectedCallback(evt));
            end
            
        end
        
        function getClusterProjection(self,camPosition,camVector)
            
            % Get data needed for ColorSpaceProjectionView object
            csname = self.hFigCurrent.Tag;
            hPanel = findobj(self.hFigCurrent, 'tag', 'RightPanel');
            isHidden = self.hHidePointCloud.Value;
            
            hProjectionView = iptui.internal.ColorSpaceProjectionView(hPanel,self.hFigCurrent,self.imRGB,csname,camPosition,camVector,self.pointCloudColor,isHidden);
            
            hApply = uicontrol('Style','togglebutton','Parent',hProjectionView.hPanels,'Units','Normalized','Position',[0.01, 0.915, 0.06, 0.075],...
                'Tag','ProjectButton','Callback',@(hobj,evt) self.applyTransformation(hobj,evt),'CData',self.polyIcon,...
                'TooltipString',getString(message('images:colorSegmentor:polygonButtonTooltip')));
            
            iptSetPointerBehavior(hApply,@(hObj,evt) set(hObj,'Pointer','hand'));
            
            setappdata(hPanel,'ProjectionView',hProjectionView);
            self.hColorSpaceProjectionView = hProjectionView;
            
            % Update icon for Hide Point Cloud button
            hAx = findobj(hProjectionView.hPanels,'type','axes');
            
            iptSetPointerBehavior(hAx,@(hObj,evt) set(hObj,'Pointer','custom','PointerShapeCData',self.rotatePointer));
            
        end
        
        function changeViewState(self)
            
            % Change view state of 2D Panel
            hPanel = findobj(self.hFigCurrent,'Tag','ColorProj');
            if strcmp(get(hPanel,'Visible'),'off')
                set(hPanel,'Visible','on')
            else
                set(hPanel,'Visible','off')
            end
            
            % Change view state of 3D Panel
            self.hColorSpaceProjectionView.view3DPanel()
            
        end
        
        function colorSpaceSelectedCallback(self,evt)
            
            % Add another segmentation document to toolgroup
            selectedColorSpace = evt.AffectedObject.SelectedColorSpace;
            tMat = evt.AffectedObject.tMat;
            camPosition = evt.AffectedObject.camPosition;
            camVector = evt.AffectedObject.camVector;
            
            self.is3DView = true;
            
            selectedColorspaceData = self.computeColorspaceRepresentation(selectedColorSpace);
            self.createColorspaceSegmentationView(selectedColorspaceData,selectedColorSpace,tMat,camPosition,camVector);
            
            % Enable UI controls
            self.setControlsEnabled(true);
            self.hColorSpacesButton.Enabled = true;
            self.hPointCloudBackgroundSlider.Enabled = ~self.hHidePointCloud.Value;
            
            % Each time a new colorspace document is added, we want to
            % revert the Show Binary, Invert Mask, and Mask Opacity ui
            % controls back to their initialized state.
            self.manageControlsOnNewColorspace();
            
            % Hide currently visible ROIs.
            self.hideOtherROIs()
            
        end
        
        function invertMaskButtonPress(self,~,~)
            
            self.mask = ~self.mask;
            
            % Now update graphics in scrollpanel.
            self.updateMaskOverlayGraphics();
            
        end
        
        function zoomIn(self,hToggle,~)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if hToggle.Value
                self.hZoomOutButton.Value = false;
                self.hPanButton.Value = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                zoomInFcn = imuitoolsgate('FunctionHandle', 'imzoomin');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',zoomInFcn);
                glassPlus = setptr('glassplus');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,glassPlus{:}));
                
            else
                if ~(self.hZoomOutButton.Value || self.hPanButton.Value)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                end
            end
            
        end
        
        function zoomOut(self,hToggle,~)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if hToggle.Value
                self.hZoomInButton.Value = false;
                self.hPanButton.Value    = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                zoomOutFcn = imuitoolsgate('FunctionHandle', 'imzoomout');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',zoomOutFcn);
                glassMinus = setptr('glassminus');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,glassMinus{:}));
            else
                if ~(self.hZoomInButton.Value || self.hPanButton.Value)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                end
            end
            
        end
        
        function panImage(self,hToggle,~)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if hToggle.Value
                self.hZoomOutButton.Value = false;
                self.hZoomInButton.Value = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                panFcn = imuitoolsgate('FunctionHandle', 'impan');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',panFcn);
                handCursor = setptr('hand');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,handCursor{:}));
            else
                if ~(self.hZoomInButton.Value || self.hZoomOutButton.Value)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                end
            end
            
        end
        
        function showBinaryPress(self,hobj,~)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if hobj.Value
                set(hIm,'AlphaData',1);
                self.updateMaskOverlayGraphics();
                self.hMaskOpacitySlider.Enabled = false;
            else
                set(hIm,'CData',self.imRGB);
                self.updateMaskOverlayGraphics();
                self.hMaskOpacitySlider.Enabled = true;
            end
            
        end
        
        function chooseOverlayColor(self,~,~)
            
            rgbColor = uisetcolor(getString(message('images:colorSegmentor:selectBackgroundColor')));
            
            colorSelectionCanceled = isequal(rgbColor, 0);
            if ~colorSelectionCanceled
                iconImage = zeros(16,16,3);
                iconImage(:,:,1) = rgbColor(1);
                iconImage(:,:,2) = rgbColor(2);
                iconImage(:,:,3) = rgbColor(3);
                iconImage = im2uint8(iconImage);
                
                self.setTSButtonIconFromImage(self.hOverlayColorButton,iconImage);
                
                % Set imscrollpanel axes color to apply chosen overlay color.
                set(findobj(self.hScrollpanel,'type','axes'),'Color',rgbColor);
                self.maskColor = rgbColor;
                
            end
            
        end
        
        function pointCloudSliderMoved(self,~,~)
            
            self.pointCloudColor = 1 - repmat(self.hPointCloudBackgroundSlider.Value,1,3)/100;
            validHandles = self.FigureHandles(ishandle(self.FigureHandles));
            for ii = 1:numel(validHandles)
                % Use arrayfun to set background color for every client
                scatterPlots = findall(validHandles(ii),'Type','Scatter');
                arrayfun( @(h) set(h.Parent,'Color',self.pointCloudColor), scatterPlots);
                
                projHandles = findobj(validHandles(ii),'tag','ColorProj','-or','tag','proj3dpanel');
                arrayfun(@(h) set(h,'BackgroundColor',self.pointCloudColor),projHandles);
            end
            
            % Set background color for montage view if it exists
            if self.hasCurrentValidMontageInstance
                self.hColorSpaceMontageView.updateScatterBackground(self.pointCloudColor)
            end
            
        end
        
        function opacitySliderMoved(self,varargin)
            self.updateMaskOverlayGraphics();
        end
        
        % Used by exportMask button in export section
        function exportDataToWorkspace(self)
            
            maskedRGBImage = self.imRGB;
            
            % Set background pixels where BW is false to zero.
            maskedRGBImage(repmat(~self.mask,[1 1 3])) = 0;
            
            export2wsdlg({getString(message('images:colorSegmentor:binaryMask')),...
                getString(message('images:colorSegmentor:maskedRGBImage')), ...
                getString(message('images:colorSegmentor:inputRGBImage'))}, ...
                {'BW','maskedRGBImage', 'inputImage'},{self.mask, maskedRGBImage, self.imRGB});
            
        end
        
    end
    
    % Methods used to position and customize view of toolstrip app
    methods (Access = private)
        
        function disableInteractiveTiling(self)
            
            % Needs to be called before tool group is opened.
            g = self.hToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_USER_TILE, false);
            
        end
        
        %------------------------------------------------------------------
        function removeViewTab(self)
            
            group = self.hToolGroup.Peer.getWrappedComponent;
            % Group without a View tab (needs to be called before t.open)
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB, false);
        end
        
        %------------------------------------------------------------------
        function removeQuickAccessBar(self)
            
            % Set the QAB filter property BEFORE opening the UI
            group = self.hToolGroup.Peer.getWrappedComponent;
            filter = com.mathworks.toolbox.images.QuickAccessFilter.getFilter();
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.QUICK_ACCESS_TOOL_BAR_FILTER, filter)
        end
        
        %------------------------------------------------------------------
        function disableDragDropOnToolGroup(self)
            
            % Disable drag-drop gestures on ToolGroup.
            group = self.hToolGroup.Peer.getWrappedComponent;
            dropListener = com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER, dropListener);
        end
        
    end
    
    methods (Static)
        
        function deleteAllTools
            imageslib.internal.apputil.manageToolInstances('deleteAll', 'colorThresholder');
        end
        
        function TF = isValidRGBImage(im)
            
            supportedDataType = isa(im,'uint8') || isa(im,'uint16') || isfloat(im);
            supportedAttributes = isreal(im) && all(isfinite(im(:))) && ~issparse(im);
            supportedDimensionality = (ndims(im) == 3) && size(im,3) == 3;
            
            TF = supportedDataType && supportedAttributes && supportedDimensionality;
            
        end
        
    end
    
    methods
        
        function tabName = getFigName(self,csname)
            
            validHandles = self.FigureHandles(ishandle(self.FigureHandles));
            names = arrayfun(@(h) get(h,'Name'),validHandles,'UniformOutput',false);
            
            idx = strcmpi(csname,names);
            
            if ~any(idx)
                tabName = csname;
            else
                inc = 2;
                while any(idx)
                    newname = [csname ' ' num2str(inc)];
                    idx = strcmpi(newname,names);
                    inc = inc+1;
                end
                tabName = newname;
            end
            
        end
        
        function applyTransformation(self,~,evt)
            % applyTransformation - Apply current view to the 2D
            % projection
            
            % Catch double clicks
            if ~self.is3DView
                return
            end
            
            self.is3DView = false;
            
            hPanel = findobj(self.hFigCurrent, 'Tag', 'RightPanel');
            PolyButton = findobj(hPanel,'Tag','PolyButton');
            PolyButton.Value = 1;
            
            % Get new transformation matrix
            [tMat, xlim, ylim] = self.hColorSpaceProjectionView.customProjection();
            
            % Save new transformation matrix
            setappdata(hPanel,'TransformationMat',tMat);
            
            % Apply transformation matrix
            im = getappdata(hPanel,'ColorspaceCDataForCluster');
            tMat = tMat(1:2,:);
            im = [im ones(size(im,1),1)]';
            im = (tMat*im)';
            
            setappdata(hPanel,'TransformedCDataForCluster',im);
            
            % Update point cloud with new projection
            self.updatePointCloud(xlim, ylim);
            
            self.changeViewState()
            
            self.polyRegionForClusters()
            
            evt.Source.Value = 0;
            
        end
        
        function show3DViewState(self)
            
            if iptui.internal.hasValidROIs(self.hFigCurrent,self.hPolyROIs)
                % Add dialog box to ensure user wants to remove polygons
                buttonName = questdlg(getString(message('images:colorSegmentor:rotateColorSpaceMessage')),...
                    'Remove polygons?', ...
                    getString(message('images:commonUIString:yes')),...
                    getString(message('images:commonUIString:cancel')),...
                    getString(message('images:commonUIString:cancel')));
                
                if strcmp(buttonName,getString(message('images:commonUIString:yes')))
                    self.isProjectionApplied = true;
                    % Find the old ROIs for this figure and remove them
                    figuresWithROIs = [self.hPolyROIs{:,1}];
                    idx = find(figuresWithROIs == self.hFigCurrent, 1);
                    currentROIs = self.hPolyROIs{idx,2};
                    % Remove the handle from the row
                    currentROIs(1:end).delete();
                    self.isProjectionApplied = false;
                else
                    return
                end
            end
            
            self.is3DView = true;
            
            if ~isempty(self.polyManager)
                self.disablePolyRegion()
                self.polyManager = [];
            end
            
            hPanel = findobj(self.hFigCurrent, 'Tag', 'RightPanel');
            PolyButton = findobj(hPanel,'Tag','ProjectButton');
            PolyButton.Value = 0;
            
            % Update mask and point clouds
            self.updateClusterMask()
            self.hColorSpaceProjectionView.updatePointCloud(self.sliderMask);
            self.changeViewState()
            
        end
        
        function showStatusBar(self)
            % Show busy message in status bar
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f = md.getFrameContainingGroup(self.hToolGroup.Name);
            javaMethodEDT('setStatusText', f, getString(message('images:colorSegmentor:polygonHintMessage')));
        end
        
        function clearStatusBar(self)
            % Clear busy message in status bar
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f = md.getFrameContainingGroup(self.hToolGroup.Name);
            javaMethodEDT('setStatusText', f, '');
        end
        
        function clearFreehands(self)
            % Clear all freehand ROIs
            % Turn isManualDelete off so the freehand delete function knows
            % to not update the sliders and mask
            self.isManualDelete = false;
            if iptui.internal.hasValidROIs(self.hFigCurrent,self.hFreehandROIs)
                figuresWithROIs = [self.hFreehandROIs{:,1}];
                idx = figuresWithROIs == self.hFigCurrent;
                hROIs = self.hFreehandROIs(idx,2);
                numFreehands = numel(hROIs);
                for p = 1:numFreehands
                    hFree = hROIs{numFreehands-p+1};
                    hFree.delete();
                end
            end
            self.isManualDelete = true;
            
        end
        
        function buttonClicked(self, TF)
            self.isFigClicked = TF;
        end
        
    end
    
end

%--------------------------------------------------------------------------
function triples = samplesUnderMask(img, mask)

triples = zeros([nnz(mask) 3], 'like', img);

for channel=1:3
    theChannel = img(:,:,channel);
    triples(:,channel) = theChannel(mask);
end
end

%--------------------------------------------------------------------------
function hLim = computeHLim(hValues)

% Divide the problem space in half and use some heuristics to decide
% whether there is one region or if it's split around the discontinuity at
% zero.

switch (class(hValues))
    case {'single', 'double'}
        lowerRegion = hValues(hValues < 0.5);
        upperRegion = hValues(hValues >= 0.5);
        
        if isempty(lowerRegion) || isempty(upperRegion)
            bimodal = false;
        elseif (min(lowerRegion) > 0.04) || (max(upperRegion) < 0.96)
            bimodal = false;
        elseif (min(upperRegion) - max(lowerRegion)) > 1/3
            bimodal = true;
        else
            bimodal = false;
        end
        
    case {'uint8'}
        lowerRegion = hValues(hValues < 128);
        upperRegion = hValues(hValues >= 128);
        
        if isempty(lowerRegion) || isempty(upperRegion)
            bimodal = false;
        elseif (min(lowerRegion) > 10) || (max(upperRegion) < 245)
            bimodal = false;
        elseif (min(upperRegion) - max(lowerRegion)) > 255/3
            bimodal = true;
        else
            bimodal = false;
        end
        
    case {'uint16'}
        lowerRegion = hValues(hValues < 32896);
        upperRegion = hValues(hValues >= 32896);
        
        if isempty(lowerRegion) || isempty(upperRegion)
            bimodal = false;
        elseif (min(lowerRegion) > 2570) || (max(upperRegion) < 62965)
            bimodal = false;
        elseif (min(upperRegion) - max(lowerRegion)) > 65535/3
            bimodal = true;
        else
            bimodal = false;
        end
        
    otherwise
        assert('Data type not supported');
end

if (bimodal)
    hLim = [min(upperRegion), max(lowerRegion)];
else
    hLim = [min(hValues), max(hValues)];
end
end

%------------------------------------------------------------------
function polyIcon = setUIControlIcon(filename)

% Set CData for uicontrol button from icon
[polyIcon,~,transparency] = imread(filename);
polyIcon = double(polyIcon)/255;
transparency = double(transparency)/255;
% 0.94 corresponds to the default background color for uicontrol buttons
polyIcon(:,:,1) = polyIcon(:,:,1) + (0.94-polyIcon(:,:,1)).*(1-transparency);
polyIcon(:,:,2) = polyIcon(:,:,2) + (0.94-polyIcon(:,:,2)).*(1-transparency);
polyIcon(:,:,3) = polyIcon(:,:,3) + (0.94-polyIcon(:,:,3)).*(1-transparency);
polyIcon(transparency == 0) = NaN;

end