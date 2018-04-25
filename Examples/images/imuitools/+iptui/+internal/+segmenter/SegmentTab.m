classdef SegmentTab < handle
    
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
        hToolstrip
        hApp
    end
    
    %%UI Controls
    properties
        LoadImageSection
        LoadImageButton
        LoadMaskButton
        
        NewSegmentationSection
        NewSegmentationButton
        CloneSegmentationButton
        
        TextureSection
        TextureMgr
        KmeansButton
        
        MaskSection
        AddMaskSection
        RefineMaskSection
        DrawButton
        RectangleButton
        EllipseButton
        PolygonButton
        GrabCutButton
        ThresholdButton
        GraphCutButton
        FindCirclesButton
        FloodFillButton
        MorphologyButton
        ActiveContoursButton
        ClearBorderButton
        FillHolesButton
        InvertMaskButton
        
        CreateGallery
        AddGallery
        RefineGallery
        
        PanZoomSection
        PanZoomMgr
        
        ViewSection
        ViewMgr
        
        ExportSection
        ExportButton
        ExportButtonIsEnabled
        
        ShowBinaryButtonListener
        OpacitySliderListener
    end
    
    %%Draw Mode Containers
    properties
        FreeHandContainer
        PolygonContainer
        RectangleContainer
        EllipseContainer
    end
    
    %%Code generation
    properties
        IsDataNormalized
        IsInfNanRemoved
    end
    
    %%Public API
    methods
        function self = SegmentTab(toolGroup, tabGroup, theToolstrip, theApp, varargin)
            
            if (nargin == 3)
                self.hTab = iptui.internal.segmenter.createTab(tabGroup,'segmentationTab');
            else
                self.hTab = iptui.internal.segmenter.createTab(tabGroup,'segmentationTab', varargin{:});
            end
            
            self.hToolGroup = toolGroup;
            self.hTabGroup = tabGroup;
            self.hToolstrip = theToolstrip;
            self.hApp = theApp;
            
            self.layoutTab()
        end
        
        function show(self)
            self.hTabGroup.add(self.hTab)
        end
        
        function hide(self)
            self.hTabGroup.remove(self.hTab)
        end
        
        function makeActive(self)
            self.hTabGroup.SelectedTab = self.hTab;
        end
        
        function setMode(self, mode)
            import iptui.internal.segmenter.AppMode;

            switch (mode)
            case AppMode.NoImageLoaded
                self.disableAllButtons()
                self.LoadImageButton.Enabled = true;

            case {AppMode.ImageLoaded, AppMode.NoMasks}
                
                %If the app enters a state with no mask, make sure we set
                %the state back to unshow binary.
                if self.ViewMgr.ShowBinaryButton.Value
                    self.reactToUnshowBinary();
                    self.hApp.unshowBinary()
                    self.hToolstrip.setMode(AppMode.UnshowBinary)
                    % This is needed to ensure that state is settled after
                    % unshow binary. 
                    drawnow;
                end
                
                self.handleTextureState()
                self.enableNoMaskButtons()
                self.updateToolTipsForMaskControls(false)
                self.ExportButton.Enabled = false;
                self.ExportButtonIsEnabled = false;
                
            case {AppMode.ThresholdImage,...
                  AppMode.ActiveContoursIterationsDone,...
                  AppMode.FloodFillTabOpened, AppMode.MorphImage,...
                  AppMode.MorphTabOpened, AppMode.ActiveContoursTabOpened,...
                  AppMode.ActiveContoursNoMask, AppMode.GraphCutOpened,...
                  AppMode.FindCirclesOpened, AppMode.GrabCutOpened}
                self.updateToolTipsForMaskControls(true)

            case AppMode.MasksExist
                self.enableMaskButtons()
                self.updateToolTipsForMaskControls(true)

            case {AppMode.Drawing, AppMode.ActiveContoursRunning, AppMode.FloodFillSelection}
                self.disableAllButtons()
                self.PanZoomMgr.Enabled = false;

            case {AppMode.DrawingDone, AppMode.ActiveContoursDone,...
                  AppMode.FloodFillDone, AppMode.ThresholdDone,...
                  AppMode.MorphologyDone, AppMode.GraphCutDone,...
                  AppMode.FindCirclesDone, AppMode.GrabCutDone}
                maskIsEmpty = self.checkIfMaskIsEmpty();
                if maskIsEmpty
                    self.setMode(AppMode.NoMasks)
                else
                    self.enableMaskButtons()
                end
                self.ExportButton.Enabled = self.ExportButtonIsEnabled;

            case AppMode.OpacityChanged
                self.reactToOpacityChange()

            case AppMode.ShowBinary
                self.reactToShowBinary()

            case AppMode.UnshowBinary
                self.reactToUnshowBinary()

            case AppMode.HistoryIsEmpty
                self.ExportButton.Enabled = false;
                self.ExportButtonIsEnabled = false;

            case AppMode.HistoryIsNotEmpty
                self.ExportButton.Enabled = true;
                self.ExportButtonIsEnabled = true;
                
            case AppMode.ToggleTexture
                    self.TextureMgr.updateTextureState(self.hApp.Session.UseTexture);

            otherwise
                assert(false, 'Unrecognized mode')
            end
        end
        
        function opacity = getOpacity(self)
            opacity = self.ViewMgr.Opacity / 100;
        end
        
        function TF = importImageData(self,im)
            
            TF = true;
            %Normalize image if it's floating point. Inform the user via a
            %dialog.
            if isfloat(im)
                [self,im] = normalizeFloatDataDlg(self,im);
                if isempty(im)
                    TF = false;
                    return;
                end
            end
            
            self.hApp.createSessionFromImage(im, self.IsDataNormalized, self.IsInfNanRemoved);
            
            self.hApp.updateImageMagnification();
        end
    end
    
    %%Layout
    methods (Access = private)
        function layoutTab(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            % Add Sections to Segment Tab
            self.LoadImageSection           = self.hTab.addSection(getMessageString('loadImage'));
            self.LoadImageSection.Tag       = 'loadImage';
            self.NewSegmentationSection     = self.hTab.addSection(getMessageString('newSegmentation'));
            self.NewSegmentationSection.Tag = 'newSegmentation';
            self.TextureSection             = self.addTextureSection();
            self.MaskSection                = self.hTab.addSection(getMessageString('createSection'));
            self.MaskSection.Tag            = 'createSection';
            self.AddMaskSection             = self.hTab.addSection(getMessageString('addSection'));
            self.AddMaskSection.Tag         = 'addSection';
            self.RefineMaskSection          = self.hTab.addSection(getMessageString('refineSection'));
            self.RefineMaskSection.Tag      = 'refineSection';
            self.PanZoomSection             = self.addPanZoomSection();
            self.ViewSection                = self.addViewSection();
            self.ExportSection              = self.hTab.addSection(getMessageString('Export'));
            self.ExportSection.Tag          = 'Export';
            
            self.layoutLoadImageSection()
            self.layoutNewSegmentationSection()
            self.layoutMaskSection()
            self.layoutAddMaskSection()
            self.layoutRefineMaskSection()
            self.layoutExportSection()
        end
        
        function layoutLoadImageSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            
            %Load Image Button
            self.LoadImageButton = matlab.ui.internal.toolstrip.SplitButton(getString(message('images:imageSegmenter:loadImageSplitButtonTitle')), ...
                matlab.ui.internal.toolstrip.Icon.IMPORT_24);
            self.LoadImageButton.Tag = 'btnLoadImage';
            self.LoadImageButton.Description = getString(message('images:imageSegmenter:loadImageTooltip'));

            % Drop down list
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:imageSegmenter:loadImageFromFile')));
            sub_item1.Icon = matlab.ui.internal.toolstrip.Icon.IMPORT_16;
            sub_item1.ShowDescription = false;
            addlistener(sub_item1, 'ItemPushed', @self.loadImageFromFile);
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:imageSegmenter:loadImageFromWorkspace')));
            sub_item2.Icon = matlab.ui.internal.toolstrip.Icon.IMPORT_16;
            sub_item2.ShowDescription = false;
            addlistener(sub_item2, 'ItemPushed', @self.loadImageFromWorkspace);
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            
            self.LoadImageButton.Popup = sub_popup;
            self.LoadImageButton.Popup.Tag = 'Load Image Popup';
            addlistener(self.LoadImageButton, 'ButtonPushed', @(hobj,evt) self.loadImageFromFile(hobj,evt));
            
            %Load Mask Button
            self.LoadMaskButton = matlab.ui.internal.toolstrip.Button(getMessageString('loadMask'), Icon.LOADMASK_24);
            self.LoadMaskButton.Tag = 'btnLoadMask';
            self.LoadMaskButton.Description = getMessageString('maskTooltip');
            addlistener(self.LoadMaskButton, 'ButtonPushed', @(~,~) self.loadMaskFromWorkspace());
            
            %Layout
            c = self.LoadImageSection.addColumn();
            c.add(self.LoadImageButton);
            c2 = self.LoadImageSection.addColumn();
            c2.add(self.LoadMaskButton);
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
            
            self.OpacitySliderListener = addlistener(self.ViewMgr.OpacitySlider, 'ValueChanged', @(~,~)self.opacitySliderMoved());
            self.ShowBinaryButtonListener = addlistener(self.ViewMgr.ShowBinaryButton, 'ValueChanged', @(hobj,~)self.showBinaryPress(hobj));
        end
        
        function layoutExportSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            
            %Load Image Button
            self.ExportButton = matlab.ui.internal.toolstrip.SplitButton(getString(message('images:imageSegmenter:Export')), ...
                Icon.CREATE_MASK_24);
            self.ExportButton.Tag = 'btnExport';
            self.ExportButton.Description = getString(message('images:imageSegmenter:exportButtonTooltip'));

            % Drop down list
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:imageSegmenter:exportImages')));
            sub_item1.Icon = Icon.CREATE_MASK_16;
            sub_item1.ShowDescription = false;
            addlistener(sub_item1, 'ItemPushed', @self.exportDataToWorkspace);
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:imageSegmenter:exportFunction')));
            sub_item2.Icon = Icon.GENERATE_MATLAB_SCRIPT_16;
            sub_item2.ShowDescription = false;
            addlistener(sub_item2, 'ItemPushed', @self.generateCode);
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            
            self.ExportButton.Popup = sub_popup;
            self.ExportButton.Popup.Tag = 'Export Popup';
            addlistener(self.ExportButton, 'ButtonPushed', @(~,~) self.exportDataToWorkspace());
            
            %Layout
            c = self.ExportSection.addColumn();
            c.add(self.ExportButton);

        end
        
        function layoutNewSegmentationSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            
            %Load Image Button
            self.NewSegmentationButton = matlab.ui.internal.toolstrip.SplitButton(getString(message('images:imageSegmenter:newSegmentation')), ...
                matlab.ui.internal.toolstrip.Icon.NEW_24);
            self.NewSegmentationButton.Tag = 'btnNewSegmentation';
            self.NewSegmentationButton.Description = getString(message('images:imageSegmenter:newSegmentationTooltip'));

            % Drop down list
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:imageSegmenter:newSegmentation')));
            sub_item1.Icon = matlab.ui.internal.toolstrip.Icon.NEW_16;
            sub_item1.ShowDescription = false;
            addlistener(sub_item1, 'ItemPushed', @self.newSegmentation);
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getString(message('images:imageSegmenter:cloneSegmentation')));
            sub_item2.Icon = matlab.ui.internal.toolstrip.Icon.NEW_16;
            sub_item2.ShowDescription = false;
            addlistener(sub_item2, 'ItemPushed', @self.cloneSegmentation);
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            
            self.NewSegmentationButton.Popup = sub_popup;
            self.NewSegmentationButton.Popup.Tag = 'New Segmentation Popup';
            addlistener(self.NewSegmentationButton, 'ButtonPushed', @(hobj,evt) self.newSegmentation(hobj,evt));
            
            %Layout
            c = self.NewSegmentationSection.addColumn();
            c.add(self.NewSegmentationButton);
            
        end
        
        function layoutMaskSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            import matlab.ui.internal.toolstrip.*;
            
            featureCategory = GalleryCategory('Create Mask');
            featureCategory.Tag = 'CreateCategory';
            topCol = self.MaskSection.addColumn();
            
            popup = GalleryPopup();
            popup.Tag = 'CreateGalleryPopup';
            popup.add(featureCategory); 
            
            %Threshold Button
            self.ThresholdButton = GalleryItem(getMessageString('thresholdButtonTitle'), Icon.THRESHOLD_24);
            self.ThresholdButton.Tag = 'btnThreshold';
            self.ThresholdButton.Description = getMessageString('thresholdTooltip');
            addlistener(self.ThresholdButton, 'ItemPushed', @(~,~) self.showThresholdTab());
            featureCategory.add(self.ThresholdButton);
            
            % Graph Cut Button
            self.GraphCutButton = GalleryItem(getMessageString('graphCutTitle'), Icon.GRAPHCUT_24);
            self.GraphCutButton.Tag = 'btnGraphCut';
            self.GraphCutButton.Description = getMessageString('graphCutTooltip');
            addlistener(self.GraphCutButton, 'ItemPushed', @(~,~) self.showGraphCutTab());
            featureCategory.add(self.GraphCutButton);
            
            % k-means Clustering
            self.KmeansButton = GalleryItem(getMessageString('kmeans'), Icon.AUTOCLUSTER_24);
            self.KmeansButton.Tag = 'btnKmeans';
            self.KmeansButton.Description = getMessageString('kmeansTooltip');
            addlistener(self.KmeansButton, 'ItemPushed', @(~,~) self.classifyKmeans());
            
            % Check for stats toolbox license
            statsCheck = license('test','Statistics_Toolbox');
            if statsCheck
                featureCategory.add(self.KmeansButton);
            end
            
            % Find Circles Button
            self.FindCirclesButton = GalleryItem(getMessageString('findCirclesTitle'), Icon.FINDCIRCLES_24);
            self.FindCirclesButton.Tag = 'btnFindCircles';
            self.FindCirclesButton.Description = getMessageString('findCirclesTooltip');
            addlistener(self.FindCirclesButton, 'ItemPushed', @(~,~) self.showFindCirclesTab());
            featureCategory.add(self.FindCirclesButton);
            
            self.CreateGallery = Gallery(popup,'MaxColumnCount', 2, 'MinColumnCount', 1);
            self.CreateGallery.Tag = 'createMaskGallery';
            topCol.add(self.CreateGallery);
            
        end
        
        function layoutAddMaskSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            import matlab.ui.internal.toolstrip.*;
            
            featureCategory = GalleryCategory('Add to Mask');
            featureCategory.Tag = 'AddFeatureCategory';
            topCol = self.AddMaskSection.addColumn();
            
            popup = GalleryPopup();
            popup.Tag = 'AddGalleryPopup';
            popup.add(featureCategory);
            
            self.GrabCutButton = GalleryItem(getMessageString('grabcut'), Icon.GRABCUT_24);
            self.GrabCutButton.Tag = 'btnGrabCut';
            self.GrabCutButton.Description = getString(message('images:imageSegmenter:grabcutTooltip'));
            featureCategory.add(self.GrabCutButton);
            addlistener(self.GrabCutButton, 'ItemPushed', @(~,~) self.showGrabCutTab());
            
            self.FloodFillButton = GalleryItem(getMessageString('floodFillButtonTitle'), Icon.FLOODFILL_24);
            self.FloodFillButton.Tag = 'btnFloodFill';
            self.FloodFillButton.Description = getMessageString('floodFillTooltip');
            featureCategory.add(self.FloodFillButton);
            addlistener(self.FloodFillButton, 'ItemPushed', @(~,~) self.showFloodFillTab());
            
            self.DrawButton = GalleryItem(getString(message('images:imageSegmenter:drawFreeHand')), Icon.FREEHAND_24);
            self.DrawButton.Tag = 'btnDrawFreehand';
            self.DrawButton.Description = getString(message('images:imageSegmenter:addFreehandTooltip'));
            featureCategory.add(self.DrawButton);
            addlistener(self.DrawButton, 'ItemPushed', @self.drawFreehand);
            
            self.RectangleButton = GalleryItem(getString(message('images:imageSegmenter:addRectangle')), Icon.RECTANGLE_24);
            self.RectangleButton.Tag = 'btnDrawRectangle';
            self.RectangleButton.Description = getString(message('images:imageSegmenter:addRectangleTooltip'));
            featureCategory.add(self.RectangleButton);
            addlistener(self.RectangleButton, 'ItemPushed', @self.drawRectangle);
            
            self.EllipseButton = GalleryItem(getString(message('images:imageSegmenter:addEllipse')), Icon.ELLIPSE_24);
            self.EllipseButton.Tag = 'btnDrawEllipse';
            self.EllipseButton.Description = getString(message('images:imageSegmenter:addEllipseTooltip'));
            featureCategory.add(self.EllipseButton);
            addlistener(self.EllipseButton, 'ItemPushed', @self.drawEllipse);
            
            self.PolygonButton = GalleryItem(getString(message('images:imageSegmenter:addPolygon')), Icon.POLYGON_24);
            self.PolygonButton.Tag = 'btnDrawPolygon';
            self.PolygonButton.Description = getString(message('images:imageSegmenter:addPolygonTooltip'));
            featureCategory.add(self.PolygonButton);
            addlistener(self.PolygonButton, 'ItemPushed', @self.drawPolygon);
            
            self.AddGallery = Gallery(popup,'MaxColumnCount', 2, 'MinColumnCount', 1);
            self.AddGallery.Tag = 'addToMaskGallery';
            topCol.add(self.AddGallery);

        end
        
        function layoutRefineMaskSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            import matlab.ui.internal.toolstrip.*;
            
            featureCategory = GalleryCategory('Refine Mask');
            featureCategory.Tag = 'RefineFeatureCategory';
            topCol = self.RefineMaskSection.addColumn();
            
            popup = GalleryPopup();
            popup.Tag = 'RefineGalleryPopup';
            popup.add(featureCategory); 
            
            %Morphology Button
            self.MorphologyButton = GalleryItem(getMessageString('morphologyButtonTitle'), Icon.MORPHOLOGY_24);
            self.MorphologyButton.Tag = 'btnMorphology';
            self.MorphologyButton.Description = getMessageString('morphologyTooltip');
            addlistener(self.MorphologyButton, 'ItemPushed', @(~,~) self.showMorphologyTab());
            featureCategory.add(self.MorphologyButton);
            
            %Active Contours Button
            self.ActiveContoursButton = GalleryItem(getMessageString('activeContourButtonTitle'), Icon.ACTIVECONTOURS_24);
            self.ActiveContoursButton.Tag = 'btnActiveContours';
            self.ActiveContoursButton.Description = getMessageString('activeContoursTooltip');
            addlistener(self.ActiveContoursButton,'ItemPushed', @(~,~)self.showActiveContoursTab());
            featureCategory.add(self.ActiveContoursButton);
            
            %Clear Border Button
            self.ClearBorderButton = GalleryItem(getMessageString('clearBorder'), Icon.CLEARBORDER_16);
            self.ClearBorderButton.Tag = 'btnClearBorder';
            self.ClearBorderButton.Description = getMessageString('clearBorderTooltip');
            addlistener(self.ClearBorderButton, 'ItemPushed', @(~,~)self.clearBorder());
            featureCategory.add(self.ClearBorderButton);
            
            %Fill Holes Button
            self.FillHolesButton = GalleryItem(getMessageString('fillHoles'), Icon.FILLHOLES_16);
            self.FillHolesButton.Tag = 'btnFillHoles';
            self.FillHolesButton.Description = getMessageString('fillHolesTooltip');
            addlistener(self.FillHolesButton, 'ItemPushed', @(~,~)self.fillHoles());
            featureCategory.add(self.FillHolesButton);
            
            %Invert Mask Button
            self.InvertMaskButton = GalleryItem(getMessageString('invertMask'), Icon.INVERT_MASK_16);
            self.InvertMaskButton.Tag = 'btnInvertMask';
            self.InvertMaskButton.Description = getMessageString('invertMaskTooltip');
            addlistener(self.InvertMaskButton, 'ItemPushed', @(~,~)self.invertMask());
            featureCategory.add(self.InvertMaskButton);
            
            self.RefineGallery = Gallery(popup,'MaxColumnCount', 2, 'MinColumnCount', 1);
            self.RefineGallery.Tag = 'refineMaskGallery';
            topCol.add(self.RefineGallery);

        end
    end
    
    %%Callbacks
    methods (Access = private)
        
        function loadImageFromFile(self, ~, ~)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            
            user_cancelled_import = self.showImportingDataWillCauseDataLossDlg();
            if ~user_cancelled_import
                
                filename = imgetfile();
                if ~isempty(filename)
                    try
                        %Ignore all reader warnings
                        warnstate = warning('off','all');
                        resetWarningObj = onCleanup(@()warning(warnstate));
                        
                        if isdicom(filename)
                            im = dicomread(filename);
                        else
                            im = imread(filename);
                        end
                    catch ALL
                        errdlg = errordlg(ALL.message, getMessageString('unableToReadTitle'), 'modal');
                        % We need the error dialog to be blocking, otherwise
                        % loadImageFromFile() is invoked before the dialog finishes
                        % setting itself up and becomes modal.
                        uiwait(errdlg);
                        % Drawnow is necessary so that imgetfile dialog will
                        % enforce modality in next call to imgetfile that
                        % arrises from recursion.
                        drawnow
                        self.loadImageFromFile();
                        return;
                    end
                    
                    isValidType = iptui.internal.segmenter.Session.isValidImageType(im);
                    
                    wasRGB = ndims(im)==3 && size(im,3)==3;
                    isValidDim = ismatrix(im);
                    
                    if ~isValidType || (~wasRGB && ~isValidDim)
                        errdlg = errordlg(getMessageString('nonGrayErrorDlgMessage'), getMessageString('nonGrayErrorDlgTitle'), 'modal');
                        % We need the error dialog to be blocking, otherwise
                        % loadImageFromFile() is invoked before the dialog finishes
                        % setting itself up and becomes modal.
                        uiwait(errdlg);
                        % Drawnow is necessary so that imgetfile dialog will
                        % enforce modality in next call to imgetfile that
                        % arrises from recursion.
                        drawnow;
                        self.loadImageFromFile();
                        return;
                        
                    elseif isValidType && (wasRGB || isValidDim)
                        self.hApp.wasRGB = wasRGB;
                        self.hApp.Session.WasRGB = wasRGB;
                        self.importImageData(im);
                    else
                        assert(false, 'Internal error: Invalid image');
                    end
                else %No file was selected and imgetfile returned an empty string. User hit Cancel.
                end
            end
        end
        
        function loadImageFromWorkspace(self,varargin)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            isRepeatAttempt = nargin > 1 && islogical(varargin{1}) && varargin{1};
            if ~isRepeatAttempt
                user_canceled_import = self.showImportingDataWillCauseDataLossDlg();
            else
                user_canceled_import = false;
            end
            
            if ~user_canceled_import
                 
                [im,~,~,~,user_canceled_dlg] = iptui.internal.imgetvar([],0);
                if ~user_canceled_dlg
                    % While loading from workspace, image has to be
                    % grayscale.
                    isValidType = iptui.internal.segmenter.Session.isValidImageType(im);                   
                    isValidDim = ismatrix(im);
                    wasRGB = ndims(im)==3 && size(im,3)==3;
                    if ~isValidType || (~wasRGB && ~isValidDim)
                        errdlg = errordlg(getMessageString('nonGrayErrorDlgMessage'), getMessageString('nonGrayErrorDlgTitle'), 'modal');

                        uiwait(errdlg);

                        drawnow;
                        isRepeatAttempt = true;
                        self.loadImageFromWorkspace(isRepeatAttempt);
                        return;
                    else
                        self.hApp.wasRGB = wasRGB;
                        self.hApp.Session.WasRGB = wasRGB;
                        self.importImageData(im);
                    end
                else%No variable was selected and imgetvar returned an empty string. User hit Cancel.
                end
                
            end
        end
        
        function loadMaskFromWorkspace(self,varargin)
            
            import iptui.internal.segmenter.getMessageString;
            import iptui.internal.segmenter.blowAwaySegmentationDialog;
            
            self.unselectPanZoomTools()
            isRepeatAttempt = nargin > 1 && islogical(varargin{1}) && varargin{1};
            if ~isRepeatAttempt
                mask = self.hApp.getCurrentMask;
                if any(mask(:))
                    user_load_mask = blowAwaySegmentationDialog();
                else
                    user_load_mask = true;
                end
            else
                user_load_mask = true;
            end
            
            if user_load_mask
                 
                [mask,~,~,~,user_canceled_dlg] = iptui.internal.imgetvar([],3);
                if ~user_canceled_dlg
                    % While loading from workspace, image has to be
                    % grayscale.
                    isValidType = islogical(mask);
                    sz = size(self.hApp.getImage());
                    isValidDim = ismatrix(mask) && (isequal(size(mask,1),sz(1)) && isequal(size(mask,1),sz(1)));

                    if ~isValidType || ~isValidDim
                        errdlg = errordlg(getMessageString('invalidMaskDlgText'), getMessageString('invalidMaskDlgTitle'), 'modal');

                        uiwait(errdlg);

                        drawnow;
                        isRepeatAttempt = true;
                        self.loadMaskFromWorkspace(isRepeatAttempt);
                        return;
                    else
                        self.hApp.setTemporaryHistory(mask, ...
                            'Load Mask', {'BW = MASK;'});
                        self.hApp.setCurrentMask(mask);
                        self.hApp.addToHistory(mask,'Load Mask',{'BW = MASK;'});
                    end
                else%No variable was selected and imgetvar returned an empty string. User hit Cancel.
                end
                
            end
        end
        
        function newSegmentation(self, ~, ~)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            newIndex = self.hApp.Session.newSegmentation(self.hApp);
            self.hApp.Session.ActiveSegmentationIndex = newIndex;
            self.hApp.associateSegmentationWithBrowsers(newIndex)
            
            theSegmentation = self.hApp.Session.CurrentSegmentation();
            self.hApp.updateScrollPanelCommitted(theSegmentation.getMask())
            self.hApp.updateUndoRedoButtons()
            
            self.hToolstrip.setMode(AppMode.NoMasks)
            
            self.hApp.scrollSegmentationBrowserToEnd()
        end
        
        function cloneSegmentation(self, ~, ~)
            
            self.unselectPanZoomTools()
            
            newIndex = self.hApp.Session.cloneCurrentSegmentation();
            self.hApp.Session.ActiveSegmentationIndex = newIndex;
            self.hApp.associateSegmentationWithBrowsers(newIndex)
            
            self.hApp.scrollSegmentationBrowserToEnd()
        end

        %%Mask 
        function drawFreehand(self, ~, ~)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            self.hToolstrip.setMode(AppMode.Drawing)
            self.hApp.DrawingROI = true;
            
            hAx = self.hApp.getScrollPanelAxes();
            self.FreeHandContainer = iptui.internal.ImfreehandModeContainer(hAx);
            self.FreeHandContainer.enableInteractivePlacement();
            
            addlistener(self.FreeHandContainer,'hROI','PostSet',@(~,evt)self.onDrawMouseUp(evt));
        end
        
        function drawRectangle(self, ~, ~)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            self.hToolstrip.setMode(AppMode.Drawing)
            self.hApp.DrawingROI = true;
            
            hAx = self.hApp.getScrollPanelAxes();
            self.RectangleContainer = iptui.internal.ImrectModeContainer(hAx);
            self.RectangleContainer.enableInteractivePlacement();
            
            addlistener(self.RectangleContainer,'hROI','PostSet',@(~,evt)self.onDrawMouseUp(evt));
        end
        
        function drawEllipse(self, ~, ~)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            self.hToolstrip.setMode(AppMode.Drawing)
            self.hApp.DrawingROI = true;
            
            hAx = self.hApp.getScrollPanelAxes();
            self.EllipseContainer = iptui.internal.ImellipseModeContainer(hAx);
            self.EllipseContainer.enableInteractivePlacement();
            
            addlistener(self.EllipseContainer,'hROI','PostSet',@(~,evt)self.onDrawMouseUp(evt));
        end
        
        function drawPolygon(self, ~, ~)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            self.hToolstrip.setMode(AppMode.Drawing)
            self.hApp.DrawingROI = true;
            
            hAx = self.hApp.getScrollPanelAxes();
            self.PolygonContainer = iptui.internal.ImpolyModeContainer(hAx);
            self.PolygonContainer.enableInteractivePlacement();
            
            addlistener(self.PolygonContainer,'hROI','PostSet',@(~,evt)self.onDrawMouseUp(evt));
        end
        
        function onDrawMouseUp(self, evt)
            % Set color and opacity of ROI's to Foreground Color and
            % Opacity.
            
            import iptui.internal.segmenter.AppMode;
            
            src = evt.AffectedObject;
            % OR with current mask
            if ~isempty(src.hROI) && isvalid(src.hROI(end))
                roi = src.hROI(end);
                newMask = self.hApp.getCurrentMask() | roi.createMask();

                commandList = createDrawingCommand(src);
                
                self.hApp.addToHistory(newMask, ...
                    iptui.internal.segmenter.getMessageString('drawingComment', src.Kind), ...
                    commandList)
                self.hToolstrip.setMode(AppMode.DrawingDone);
            else
                self.hToolstrip.setMode(AppMode.DrawingDone);
            end
            
            % Disable interactive drawing
            src.disableInteractivePlacement()
            self.hApp.DrawingROI = false;
            
            % Delete container
            if isvalid(src)
                tools = src.hROI;
                tools = tools(isvalid(tools));
                for n = 1 : numel(tools)
                    delete(tools(n));
                end
            end
        end
        
        function classifyKmeans(self)
            
            self.hToolGroup.setWaiting(true);
            s = warning('off','stats:kmeans:FailedToConvergeRep');
            
            if self.hApp.Session.UseTexture
                im = self.hApp.Session.getTextureFeatures();
                sz = size(im);
                im = reshape(im,sz(1)*sz(2),[]);
            else
                im = single(self.hApp.getImage());
                sz = size(im);
                im = reshape(im,sz(1)*sz(2),[]);
                im = im - mean(im);
                im = im ./ std(im); % requires floating point data
            end

            % Save current rng state and reset to default rng to make
            % kmeans reproducible run to run
            rngState = rng;
            rng('default');
            
            L = kmeans(im,2,'Replicates',2);
            BW = L == 2;
            BW = reshape(BW,[sz(1) sz(2)]);
            
            % Restore previous rng state
            rng(rngState);
            
            if self.hApp.Session.UseTexture
                cmd{1} = 'sz = size(gaborX);';
                cmd{2} = 'im = reshape(gaborX,sz(1)*sz(2),[]);';
                cmd{3} = 's = rng;';
                cmd{4} = 'rng(''default'');';
                cmd{5} = 'L = kmeans(im,2,''Replicates'',2);';
                cmd{6} = 'rng(s);';
                cmd{7} = 'BW = L == 2;';
                cmd{8} = 'BW = reshape(BW,[sz(1) sz(2)]);';
                self.hApp.addToHistory(BW,iptui.internal.segmenter.getMessageString('kmeansTextureComment'),cmd)
            else
                cmd{1} = 'sz = size(X);';
                cmd{2} = 'im = single(reshape(X,sz(1)*sz(2),[]));';
                cmd{3} = 'im = im - mean(im);';
                cmd{4} = 'im = im ./ std(im);';
                cmd{5} = 's = rng;';
                cmd{6} = 'rng(''default'');';
                cmd{7} = 'L = kmeans(im,2,''Replicates'',2);';
                cmd{8} = 'rng(s);';
                cmd{9} = 'BW = L == 2;';
                cmd{10} = 'BW = reshape(BW,[sz(1) sz(2)]);';
                self.hApp.addToHistory(BW,iptui.internal.segmenter.getMessageString('kmeansComment'),cmd)
            end
            
            warning(s);
            self.hToolGroup.setWaiting(false);
            
        end
        
        function showThresholdTab(self)
            
            import iptui.internal.segmenter.AppMode;
            import iptui.internal.segmenter.blowAwaySegmentationDialog;
            
            self.unselectPanZoomTools()
            
            mask = self.hApp.getCurrentMask;
            if any(mask(:))
                openTab = blowAwaySegmentationDialog();
                
                if ~openTab
                    return;
                end
            end
            self.hToolstrip.showThresholdTab()
            self.hToolstrip.hideSegmentTab()
            self.hToolstrip.setMode(AppMode.ThresholdImage)
            
        end
        
        function showGraphCutTab(self)
            
            import iptui.internal.segmenter.AppMode;
            import iptui.internal.segmenter.blowAwaySegmentationDialog;
            
            self.unselectPanZoomTools()
            
            mask = self.hApp.getCurrentMask;
            if any(mask(:))
                openTab = blowAwaySegmentationDialog();
                
                if ~openTab
                    return;
                end
            end
            self.hToolstrip.showGraphCutTab()
            self.hToolstrip.hideSegmentTab()
            self.hToolstrip.setMode(AppMode.GraphCutOpened)
        end
        
        function showGrabCutTab(self)
            
            import iptui.internal.segmenter.AppMode;
            import iptui.internal.segmenter.blowAwaySegmentationDialog;
            
            self.unselectPanZoomTools()
            
            self.hToolstrip.showGrabCutTab()
            self.hToolstrip.hideSegmentTab()
            self.hToolstrip.setMode(AppMode.GrabCutOpened)
            
        end
        
        function showFindCirclesTab(self)
            
            import iptui.internal.segmenter.AppMode;
            import iptui.internal.segmenter.blowAwaySegmentationDialog;
            
            self.unselectPanZoomTools()
            
            mask = self.hApp.getCurrentMask;
            if any(mask(:))
                openTab = blowAwaySegmentationDialog();
                
                if ~openTab
                    return;
                end
            end
            self.hToolstrip.showFindCirclesTab()
            self.hToolstrip.hideSegmentTab()
            self.hToolstrip.setMode(AppMode.FindCirclesOpened)
        end
        
        function showFloodFillTab(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            self.hToolstrip.showFloodFillTab()
            self.hToolstrip.hideSegmentTab()
            self.hToolstrip.setMode(AppMode.FloodFillTabOpened)
        end
        
        function showMorphologyTab(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            self.hToolstrip.showMorphologyTab()
            self.hToolstrip.hideSegmentTab()
            self.hToolstrip.setMode(AppMode.MorphTabOpened);
        end
        
        function showActiveContoursTab(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            self.hToolstrip.showActiveContourTab()
            self.hToolstrip.hideSegmentTab()
            self.hToolstrip.setMode(AppMode.ActiveContoursTabOpened);
        end
        
        function clearBorder(self)
            
            self.unselectPanZoomTools()
            
            newMask = imclearborder(self.hApp.getCurrentMask());
            self.hApp.addToHistory(newMask, ...
                iptui.internal.segmenter.getMessageString('clearBorderComment'), ...
                {'BW = imclearborder(BW);'})
        end
        
        function fillHoles(self)
            
            self.unselectPanZoomTools()
            
            newMask = imfill(self.hApp.getCurrentMask(),'holes');
            self.hApp.addToHistory(newMask, ...
                iptui.internal.segmenter.getMessageString('fillHolesComment'), ...
                {'BW = imfill(BW, ''holes'');'}) 
        end
        
        function invertMask(self)
            
            self.unselectPanZoomTools()
            
            newMask = imcomplement(self.hApp.getCurrentMask());
            self.hApp.addToHistory(newMask, ...
                iptui.internal.segmenter.getMessageString('invertMaskComment'), ...
                {'BW = imcomplement(BW);'})
        end
        
        %%View
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
        
        function opacitySliderMoved(self)
            
            import iptui.internal.segmenter.AppMode;
            self.unselectPanZoomTools()
            
            newOpacity = self.ViewMgr.Opacity;
            self.hApp.updateScrollPanelOpacity(newOpacity)
            
            self.hToolstrip.setMode(AppMode.OpacityChanged)
        end
        
        %%Export
        function exportDataToWorkspace(self,~,~)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            
            maskedImage = self.hApp.Session.getImage(); % Get original RGB image
            if self.hApp.wasRGB
                maskedImage(repmat(~self.hApp.getCurrentMask(),[1 1 3])) = 0;
            else
                maskedImage(~self.hApp.getCurrentMask()) = 0;
            end
            
            checkBoxLabels = {getMessageString('finalSegmentation'), getMessageString('maskedImage')};
            defaultNames   = {'BW', 'maskedImage'};
            export2wsdlg(checkBoxLabels, defaultNames, {self.hApp.getCurrentMask(), maskedImage});
        end
        
        function generateCode(self,~,~)
            
            self.unselectPanZoomTools()
            
            self.hApp.generateCode()
        end
    end
    
    %%Helpers
    methods (Access = private)
        
        function unselectPanZoomTools(self)
            
            self.PanZoomMgr.unselectAll();
        end
        
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
        
        function handleTextureState(self)
            self.TextureMgr.Selected = self.hApp.Session.UseTexture;
        end
        
        function disableAllButtons(self)
            self.LoadImageButton.Enabled            = false;
            self.LoadMaskButton.Enabled             = false;
            self.NewSegmentationButton.Enabled      = false;
            self.CloneSegmentationButton.Enabled    = false;
            self.DrawButton.Enabled                 = false;
            self.EllipseButton.Enabled              = false;
            self.RectangleButton.Enabled            = false;
            self.PolygonButton.Enabled              = false;
            self.ThresholdButton.Enabled            = false;
            self.GraphCutButton.Enabled             = false;
            self.GrabCutButton.Enabled              = false;
            self.FloodFillButton.Enabled            = false;
            self.MorphologyButton.Enabled           = false;
            self.ActiveContoursButton.Enabled       = false;
            self.ClearBorderButton.Enabled          = false;
            self.FillHolesButton.Enabled            = false;
            self.InvertMaskButton.Enabled           = false;
            self.PanZoomMgr.Enabled                 = false;
            self.ViewMgr.Enabled                    = false;
            self.ExportButton.Enabled               = false;
            self.FindCirclesButton.Enabled          = false;
            self.TextureMgr.Enabled                 = false;
            self.KmeansButton.Enabled               = false;
        end
        
        function enableNoMaskButtons(self)
            self.LoadImageButton.Enabled            = true;
            self.LoadMaskButton.Enabled             = true;
            self.NewSegmentationButton.Enabled      = true;
            self.CloneSegmentationButton.Enabled    = true;
            self.DrawButton.Enabled                 = true;
            self.EllipseButton.Enabled              = true;
            self.RectangleButton.Enabled            = true;
            self.PolygonButton.Enabled              = true;
            self.GrabCutButton.Enabled              = true;
            self.GraphCutButton.Enabled             = true;
            self.FloodFillButton.Enabled            = true;
            self.MorphologyButton.Enabled           = false;
            self.ActiveContoursButton.Enabled       = false;
            self.ClearBorderButton.Enabled          = false;
            self.FillHolesButton.Enabled            = false;
            self.InvertMaskButton.Enabled           = false;
            self.PanZoomMgr.Enabled                 = true;
            self.ViewMgr.Enabled                    = false;
            self.ExportButton.Enabled               = false;
            self.FindCirclesButton.Enabled          = true;
            self.TextureMgr.Enabled                 = true;
            self.KmeansButton.Enabled               = true;
            self.handleThresholdState();
        end
        
        function enableMaskButtons(self)
            self.LoadImageButton.Enabled            = true;
            self.LoadMaskButton.Enabled             = false;
            self.NewSegmentationButton.Enabled      = true;
            self.CloneSegmentationButton.Enabled    = true;
            self.DrawButton.Enabled                 = true;
            self.EllipseButton.Enabled              = true;
            self.RectangleButton.Enabled            = true;
            self.PolygonButton.Enabled              = true;
            self.GrabCutButton.Enabled              = true;
            self.GraphCutButton.Enabled             = false;
            self.FloodFillButton.Enabled            = true;
            self.MorphologyButton.Enabled           = true;
            self.ActiveContoursButton.Enabled       = true;
            self.ClearBorderButton.Enabled          = true;
            self.FillHolesButton.Enabled            = true;
            self.InvertMaskButton.Enabled           = true;
            self.PanZoomMgr.Enabled                 = true;
            self.ViewMgr.Enabled                    = true;
            self.ExportButton.Enabled               = true;
            self.FindCirclesButton.Enabled          = false;
            self.TextureMgr.Enabled                 = true;
            self.KmeansButton.Enabled               = false;
            self.ThresholdButton.Enabled            = false;
        end
        
        function enableAllButtons(self)
            self.LoadImageButton.Enabled            = true;
            self.LoadMaskButton.Enabled             = true;
            self.NewSegmentationButton.Enabled      = true;
            self.CloneSegmentationButton.Enabled    = true;
            self.DrawButton.Enabled                 = true;
            self.EllipseButton.Enabled              = true;
            self.RectangleButton.Enabled            = true;
            self.PolygonButton.Enabled              = true;
            self.GrabCutButton.Enabled              = true;
            self.GraphCutButton.Enabled             = true;
            self.FloodFillButton.Enabled            = true;
            self.MorphologyButton.Enabled           = true;
            self.ActiveContoursButton.Enabled       = true;
            self.ClearBorderButton.Enabled          = true;
            self.FillHolesButton.Enabled            = true;
            self.InvertMaskButton.Enabled           = true;
            self.PanZoomMgr.Enabled                 = true;
            self.ViewMgr.Enabled                    = true;
            self.ExportButton.Enabled               = true;
            self.FindCirclesButton.Enabled          = true;
            self.TextureMgr.Enabled                 = true;
            self.KmeansButton.Enabled               = true;
            self.handleThresholdState();
        end
        
        function handleThresholdState(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            if self.hApp.Session.WasRGB
                self.ThresholdButton.Enabled        = false;
                self.ThresholdButton.Description    = getMessageString('thresholdColorTooltip');
            else
                self.ThresholdButton.Enabled        = true;
                self.ThresholdButton.Description    = getMessageString('thresholdMethodTooltip');
            end           
        end
        
        function user_canceled = showImportingDataWillCauseDataLossDlg(self)
            
            user_canceled = false;
            
            if self.hToolGroup.isClientShowing('Segmentation')
                buttonName = questdlg(iptui.internal.segmenter.getMessageString('loadingNewImageMessage'),...
                    iptui.internal.segmenter.getMessageString('loadingNewImageTitle'),...
                    getString(message('images:commonUIString:yes')),...
                    getString(message('images:commonUIString:cancel')),...
                    getString(message('images:commonUIString:cancel')));
                
                if strcmp(buttonName, getString(message('images:commonUIString:yes')))
                    % TODO: Clean up existing image/figure handles.
                else
                    user_canceled = true;
                end
            end
        end
        
        function TF = checkIfMaskIsEmpty(self)
            mask = self.hApp.getCurrentMask();
            TF = ~any(mask(:));
        end
        
        function [self,im] = normalizeFloatDataDlg(self,im)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.IsDataNormalized = false;
            self.IsInfNanRemoved  = false;
            
            % Check if image has NaN,Inf or -Inf valued pixels.
            finiteIdx       = isfinite(im(:));
            hasNansInfs     = ~all(finiteIdx);
            
            % Check if image pixels are outside [0,1].
            isOutsideRange  = any(im(finiteIdx)>1) || any(im(finiteIdx)<0);
            
            % Offer the user the option to normalize and clean-up data if
            % either of these conditions is true.
            if isOutsideRange || hasNansInfs
                
                buttonname = questdlg(getMessageString('normalizeDataDlgMessage'),...
                    getMessageString('normalizeDataDlgTitle'),...
                    getMessageString('normalizeData'),...
                    getString(message('images:commonUIString:cancel')),...
                    getMessageString('normalizeData'));
                
                if strcmp(buttonname,getMessageString('normalizeData'))
                    
                    % First clean-up data by removing NaN's and Inf's.
                    if hasNansInfs
                        % Replace nan pixels with 0.
                        im(isnan(im)) = 0;
                        
                        % Replace inf pixels with 1.
                        im(im == Inf) = 1;
                        
                        % Replace -inf pixels with 0.
                        im(im == -Inf) = 0;
                        
                        self.IsInfNanRemoved = true;
                    end
                    
                    % Normalize data in [0,1] if outside range.
                    if isOutsideRange
                        imMax = max(im(:));
                        imMin = min(im(:));                       
                        if isequal(imMax,imMin)
                            % If imMin equals imMax, the scaling will return
                            % an image of all NaNs. Replace with zeros;
                            im = 0*im;
                        else
                            if hasNansInfs
                                % Only normalize the pixels that were finite.
                                im(finiteIdx) = (im(finiteIdx) - imMin) ./ (imMax - imMin);
                            else
                                im = (im-imMin) ./ (imMax - imMin);
                            end
                        end
                        self.IsDataNormalized = true;
                    end
                    
                else
                    im = [];
                end
                
            end
        end
        
        function updateToolTipsForMaskControls(self,maskIsPresent)
            
            import iptui.internal.segmenter.getMessageString;
            
            if ~maskIsPresent
                % Refine Section
                msgstr = getMessageString('noMaskTooltip');
                self.MorphologyButton.Description = msgstr;
                self.ActiveContoursButton.Description = msgstr;
                self.ClearBorderButton.Description = msgstr;
                self.FillHolesButton.Description = msgstr;
                self.InvertMaskButton.Description = msgstr;
                
                % Create Section
                if self.hApp.Session.WasRGB
                    self.ThresholdButton.Description = getMessageString('thresholdColorTooltip');
                else
                    self.ThresholdButton.Description = getMessageString('thresholdTooltip');
                end
                self.GraphCutButton.Description = getMessageString('graphCutTooltip');
                self.FindCirclesButton.Description = getMessageString('findCirclesTooltip');
                self.KmeansButton.Description = getMessageString('kmeansTooltip');
            else
                % Create Section
                msgstr = getMessageString('yesMaskTooltip');
                if self.hApp.Session.WasRGB
                    self.ThresholdButton.Description = getMessageString('thresholdColorTooltip');
                else
                    self.ThresholdButton.Description = msgstr;
                end
                self.GraphCutButton.Description = msgstr;
                self.FindCirclesButton.Description = msgstr;
                self.KmeansButton.Description = msgstr;
                
                % Refine Section
                self.MorphologyButton.Description = getMessageString('morphologyTooltip');
                self.ActiveContoursButton.Description = getMessageString('activeContoursTooltip');
                self.ClearBorderButton.Description = getMessageString('clearBorderTooltip');
                self.FillHolesButton.Description = getMessageString('fillHolesTooltip');
                self.InvertMaskButton.Description = getMessageString('invertMaskTooltip');
            end
            
        end
        
    end
    
end

function commandList = createDrawingCommand(modeContainer)

[X, Y] = modeContainer.getPolygonPoints();
[X, Y] = removeSequentiallyRepeatedPoints(X, Y);

xString = sprintf('%0.4f ', X);
xString(end) = '';
commandList{1} = sprintf('xPos = [%s];', xString);

yString = sprintf('%0.4f ', Y);
yString(end) = '';
commandList{2} = sprintf('yPos = [%s];', yString);

commandList{3} = 'm = size(BW, 1);';
commandList{4} = 'n = size(BW, 2);';
commandList{5} = 'addedRegion = poly2mask(xPos, yPos, m, n);';
commandList{6} = 'BW = BW | addedRegion;';

end

function [X, Y] = removeSequentiallyRepeatedPoints(X, Y)

xDiff = abs(diff(X));
yDiff = abs(diff(Y));

sameAsNext = ((xDiff + yDiff) == 0);
sameAsNext(end+1) = false;

X(sameAsNext) = [];
Y(sameAsNext) = [];

end
