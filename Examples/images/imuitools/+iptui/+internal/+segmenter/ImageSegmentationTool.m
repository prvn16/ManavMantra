classdef ImageSegmentationTool < handle
    
    % Copyright 2014-2017, The MathWorks, Inc.
    
    properties
        ToolGroup
        DataBrowser
        ScrollPanel
        Session
        wasRGB
        MessagePane
    end
        
    properties (Access = private)
        jProgressLabel
        UndoActionListener
        jUndoActionHandler
        RedoActionListener
        jRedoActionHandler
        HelpActionListener
        jHelpActionHandler
        Toolstrip
    end
    
    properties (Dependent = true)
        CurrentSegmentation
    end

    properties
        ActiveContoursIsRunning = false;
        DrawingROI = false;
    end
    
    methods
        function self = ImageSegmentationTool(varargin)
            
            import iptui.internal.segmenter.*;

            self.ToolGroup = matlab.ui.internal.desktop.ToolGroup(...
                iptui.internal.segmenter.getMessageString('appName'));
                        
            self.createToolstrip()
            self.createDataBrowser()
            self.DataBrowser.addToToolGroup(self.ToolGroup)
            self.Toolstrip.setMode(AppMode.NoImageLoaded)
            
            self.setupDocumentArea()
            
            if (nargin > 0)
                im = varargin{1};
                
                if nargin>1
                    self.wasRGB = varargin{2};
                end
                imageLoadSuccess = self.Toolstrip.loadImageInSegmentTab(im);
                if imageLoadSuccess
                    self.Toolstrip.setMode(AppMode.ImageLoaded)
                else
                    self.Session = [];
                end
                
            else
                self.Session = [];
            end
            
            % We want to destroy the current app instance if a user
            % interactively closes the toolgroup associated with this
            % instance.
            addlistener(self.ToolGroup, 'GroupAction', ...
                @(~,ed) doClosingSession(self,ed));
            
        end
                
        function delete(self)
            if isa(self.ScrollPanel,'TwoMaskScrollPanel')
                delete(self.ScrollPanel);
            end
            % Remove timers from find circles and active contour
            self.Toolstrip.deleteTimers();
            delete(self.Toolstrip);
            delete(self.ToolGroup);
            delete(self);
        end
        
        function createSessionFromImage(self, im, isDataNormalized, isInfNanRemoved)
            
            import iptui.internal.segmenter.*;
            
            if isempty(self.wasRGB)
                self.Session = iptui.internal.segmenter.Session(im, self);
            else
                self.Session = iptui.internal.segmenter.Session(im, self, self.wasRGB);
            end
            
            self.Session.WasNormalized = isDataNormalized;
            self.Session.HadInfNanRemoved = isInfNanRemoved;
                        
            self.buildScrollPanel(im);
            self.ScrollPanel.AlphaMaskOpacity = self.Toolstrip.getOpacity();

            self.associateSegmentationWithBrowsers(self.Session.ActiveSegmentationIndex)
            self.addUndoRedoKeyListeners()
            drawnow;
            self.Toolstrip.setMode(AppMode.ImageLoaded)
            self.Toolstrip.setMode(AppMode.NoMasks)
        end
        
        function im = getImage(self)
            if self.wasRGB
                im = self.Session.getLabImage();
            else
                im = self.Session.getImage();
            end
        end
        
        function im = getRGBImage(self)
            im = self.Session.getImage();
        end
        
        function mask = getCurrentMask(self)
            activeSegmentation = self.Session.CurrentSegmentation();
            mask = activeSegmentation.getMask();
        end
        
        function setCurrentMask(self, newMask)
            activeSegmentation = self.Session.CurrentSegmentation();
            activeSegmentation.setCurrentMask_(newMask)
            self.ScrollPanel.updatePreviewMask(newMask)

        end
        
        function updateStatusBarText(self, text)
            if isvalid(self)
                self.jProgressLabel.setText(text);
            end
        end
        
        function hAx = getScrollPanelAxes(self)
            hAx = self.ScrollPanel.Axes;
        end
        
        function hFig = getScrollPanelFigure(self)
            hFig = self.ScrollPanel.hFig;
        end
        
        function hIm = getScrollPanelImage(self)
            hIm = self.ScrollPanel.hIm;
        end
        
        function hPreview = getScrollPanelPreview(self)
            hPreview = self.ScrollPanel.PreviewMask;
        end
        
        function hCommitted = getScrollPanelCommitted(self)
            hCommitted = self.ScrollPanel.CommittedMask;
        end
        
        function showLegend(self)
            if ~isempty(self.ScrollPanel) && isvalid(self.ScrollPanel)
                self.ScrollPanel.addLegend();
            end
        end
        
        function hideLegend(self)
            if ~isempty(self.ScrollPanel) && isvalid(self.ScrollPanel)
                self.ScrollPanel.removeLegend();
            end
        end
        
        function showBinary(self)
            self.ScrollPanel.showBinary()
        end
        
        function unshowBinary(self)
            self.ScrollPanel.unshowBinary()
        end
        
        function opacity = getScrollPanelOpacity(self)
            opacity = self.ScrollPanel.AlphaMaskOpacity;
        end
        
        function updateScrollPanelPreview(self, newMask)
            if (~isempty(self.ScrollPanel))
                self.ScrollPanel.updatePreviewMask(newMask)
                self.ScrollPanel.resetCommittedMask()
            end
        end
        
        function updateScrollPanelCommitted(self, newMask)
            if (~isempty(self.ScrollPanel))
                self.ScrollPanel.updateCommittedMask(newMask)
                self.ScrollPanel.resetPreviewMask()
            end
        end
        
        function updateScrollPanelOpacity(self, newPercentage)
            self.ScrollPanel.AlphaMaskOpacity = newPercentage/100;
        end
        
        function current = get.CurrentSegmentation(self)
            current = self.Session.CurrentSegmentation();
        end
        
        function updateImageMagnification(self) 
            if ~isempty(self.ScrollPanel)
                self.ScrollPanel.updateImageMagnification()
            end
        end
        
        function generateCode(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            generator = iptui.internal.CodeGenerator();
            
            % Add items from the history.
            activeSegmentation = self.Session.CurrentSegmentation();
            serializedHistory = activeSegmentation.export();
            
            % Check for Load Mask
            idx = strcmpi(serializedHistory(:,1),'Load Mask');
            if any(idx)
                wasMaskLoaded = true;
            else
                wasMaskLoaded = false;
            end
            
            % Add function definition and help.
            self.addFunctionDeclaration(generator,wasMaskLoaded)
            generator.addReturn()
            generator.addHeader('imageSegmenter');
            
            if (self.Session.WasRGB)
                var = 'RGB';
            else
                var = 'X';
            end
            
            % Add code to remove Infs/NaNs if needed.
            if (self.Session.HadInfNanRemoved)
                if (self.Session.WasNormalized)
                    generator.addComment('Get linear indices to finite valued data')
                    generator.addLine(sprintf('finiteIdx = isfinite(%s(:));',var))
                end
                
                generator.addComment('Replace nan values with 0');
                generator.addLine(sprintf('%s(isnan(%s)) = 0;',var,var));
                
                generator.addComment('Replace inf values with 1');
                generator.addLine(sprintf('%s(%s==Inf) = 1;',var,var));
                
                generator.addComment('Replace -inf values with 0');
                generator.addLine(sprintf('%s(%s==-Inf) = 0;',var,var));
            end
            
            % Add code to normalize image if needed.
            if (self.Session.WasNormalized)
                generator.addComment('Normalize input data to range in [0,1].')
                generator.addLine(sprintf('%smin = min(%s(:));',var,var))
                generator.addLine(sprintf('%smax = max(%s(:));',var,var))
                generator.addLine(sprintf('if isequal(%smax,%smin)',var,var))
                generator.addLine(sprintf('    %s = 0*%s;',var,var))
                generator.addLine('else')
                if self.Session.HadInfNanRemoved
                    generator.addLine(sprintf('    %s(finiteIdx) = (%s(finiteIdx) - %smin) ./ (%smax - %smin);',var,var,var,var,var))
                else
                    generator.addLine(sprintf('    %s = (%s - %smin) ./ (%smax - %smin);',var,var,var,var,var))
                end
                generator.addLine('end')
            end
            
            % Add code to convert to Lab if needed.
            if (self.Session.WasRGB)
                generator.addComment('Convert RGB image into L*a*b* color space.')
                generator.addLine('X = rgb2lab(RGB);')
            end
            
            
            
            % Add items from the history.
            activeSegmentation = self.Session.CurrentSegmentation();
            serializedHistory = activeSegmentation.export();
            
            numHistoryItems = size(serializedHistory, 1);
            thresholdString = 'Threshold image';
            isGaborNeeded = false;
            
            for idx = 2:numHistoryItems
                isGaborNeeded = isGaborNeeded | any(strcmp(serializedHistory{idx,1},...
                    {getMessageString('graphCutTextureComment'),getMessageString('kmeansTextureComment'),...
                    getMessageString('floodFillTextureComment'),getMessageString('activeContoursTextureComment')}));
            end
            
            if isGaborNeeded
                generator.addLine('gaborX = createGaborFeatures(X);')
            end
            
            isPreallocationNeeded = ~any(strcmp(serializedHistory{2,1},...
                {getMessageString('findCirclesComment'),getMessageString('graphCutComment'),...
                getMessageString('graphCutTextureComment'),getMessageString('kmeansComment'),...
                getMessageString('kmeansTextureComment')})) && ...
                ~strncmp(serializedHistory{2,1},thresholdString,numel(thresholdString));
            
            isGraphCutAppliedOnRGB = self.Session.WasRGB && (any(cellfun(@(x) strcmp(x,getMessageString('graphCutComment')),serializedHistory(:,1))) || ...
                any(cellfun(@(x) strcmp(x,getMessageString('grabcutComment')),serializedHistory(:,1))));
            
            % Add function to create initial mask.
            if isPreallocationNeeded
                generator.addComment('Create empty mask.')
                generator.addLine('BW = false(size(X,1),size(X,2));')
            end
            
            for operationIndex = 2:numHistoryItems
                description = serializedHistory{operationIndex, 1};
                commands = serializedHistory{operationIndex, 2};
                
                generator.addComment(description)

                numberOfCommands = numel(commands);
                for commandIndex = 1:numberOfCommands
                    generator.addLine(commands{commandIndex})
                end
            end
            
            % Create masked image.
            generator.addComment('Create masked image.')
            if (self.Session.WasRGB)
                generator.addLine('maskedImage = RGB;')
                generator.addLine('maskedImage(repmat(~BW,[1 1 3])) = 0;')
            else
                generator.addLine('maskedImage = X;')
                generator.addLine('maskedImage(~BW) = 0;')
            end
            
            generator.addLine('end')
            generator.addReturn()
            
            if isGaborNeeded
                addGaborSubfunction(generator);
            end
            
            if isGraphCutAppliedOnRGB || isGaborNeeded
                addPrepLabSubfunction(generator);
            end
            
            generator.addReturn()
            generator.putCodeInEditor()
        end
        
        function returnToSegmentTab(self)
            idx = self.Toolstrip.findVisibleTabs();
            self.Toolstrip.closeTab(idx)
        end
        
        function applyCurrentTabSettings(self)
            idx = self.Toolstrip.findVisibleTabs();
            self.Toolstrip.applyCurrentSettings(idx)
        end
        
        function discardCurrentTabSettings(self)
            idx = self.Toolstrip.findVisibleTabs();
            self.Toolstrip.closeTab(idx)
        end
        
        function updateModeOnSegmentationChange(self)
            
            activeSegmentation = self.CurrentSegmentation;
            if (activeSegmentation.CurrentMaskIsEmpty)
                self.Toolstrip.setMode(iptui.internal.segmenter.AppMode.NoMasks)
            else
                self.Toolstrip.setMode(iptui.internal.segmenter.AppMode.MasksExist)
            end
        end
        
        function stopActiveContours(self)
            self.Toolstrip.stopActiveContours()
        end
        
        function buildMessagePane(self)
            
            import iptui.internal.utilities.*;
  
            if isempty(self.MessagePane) || ~isvalid(self.MessagePane)
                hFig = self.getScrollPanelFigure();
                self.MessagePane = addMessagePane(hFig,'');
                self.MessagePane.showPanel();
                self.MessagePane.setVisible(false);
            end
            
        end
        
    end
    
    % History-related
    methods
        function addToHistory(self, newMask, description, command)
            
            import iptui.internal.segmenter.AppMode;
            
            activeSegmentation = self.CurrentSegmentation;
            activeSegmentation.addToHistory_(newMask, description, command)
            
            self.clearTemporaryHistory()
            
            self.Toolstrip.setMode(AppMode.HistoryIsNotEmpty)
            
            self.updateScrollPanelCommitted(newMask)
            
            self.refreshSegmentationBrowserThumbnail(newMask)
            
            if (maskHasRegions(newMask))
                self.Toolstrip.setMode(AppMode.MasksExist)
            else
                self.Toolstrip.setMode(AppMode.NoMasks)
            end
            
            self.enableUndoActionQABButton(true)
            self.enableRedoActionQABButton(false)
        end
        
        function setTemporaryHistory(self, newMask, description, command)
            import iptui.internal.segmenter.AppMode;
            
            activeSegmentation = self.CurrentSegmentation;
            activeSegmentation.setTemporaryHistory_(newMask, description, command)
            
            self.ScrollPanel.updatePreviewMask(newMask)
        end
        
        function commitTemporaryHistory(self)
            activeSegmentation = self.CurrentSegmentation;
            [mask, description, command] = activeSegmentation.getTemporaryHistory_();
            self.addToHistory(mask.getMask(), description, command)
        end
        
        function clearTemporaryHistory(self)
            activeSegmentation = self.CurrentSegmentation;
            activeSegmentation.clearTemporaryHistory_()
            
            self.updateScrollPanelCommitted(self.getCurrentMask())
        end
        
        function updateUndoRedoButtons(self)
            activeSegmentation = self.CurrentSegmentation;
            self.enableUndoActionQABButton(activeSegmentation.HasUndoItems)
            self.enableRedoActionQABButton(activeSegmentation.HasRedoItems)            
        end
        
        function setCurrentHistoryItem(self, historyItemIndex)
            activeSegmentation = self.CurrentSegmentation;
            activeSegmentation.setCurrentHistoryItem(historyItemIndex)
            
            if (activeSegmentation.CurrentMaskIsEmpty)
                self.Toolstrip.setMode(iptui.internal.segmenter.AppMode.NoMasks)
            else
                self.Toolstrip.setMode(iptui.internal.segmenter.AppMode.MasksExist)
            end
            self.refreshSegmentationBrowserThumbnail(self.getCurrentMask())
            self.updateScrollPanelCommitted(self.getCurrentMask())
        end
        
        function undoHandler(self, ~, ~)
            activeSegmentation = self.CurrentSegmentation;
            if (activeSegmentation.HasUndoItems)
                hBrowser = self.getHistoryBrowser();
                hBrowser.stepBackward()
            end
        end
        
        function redoHandler(self, ~, ~)
            activeSegmentation = self.CurrentSegmentation;
            if (activeSegmentation.HasRedoItems)
                hBrowser = self.getHistoryBrowser();
                hBrowser.stepForward()
            end
        end
        
        function helpHandler(~, ~, ~)
            doc('imageSegmenter');
        end
    end
    
    % Data Browser-related
    methods
        function hBrowser = getHistoryBrowser(self)
            hBrowser = self.DataBrowser.getHistoryBrowser();
        end
        
        function hBrowser = getSegmentationBrowser(self)
            hBrowser = self.DataBrowser.getSegmentationBrowser();
        end
        
        function initializeHistoryBrowser(self, im)
            activeSegmentation = self.CurrentSegmentation;
            activeSegmentation.addToHistory_(false(size(im)), ...
                iptui.internal.segmenter.getMessageString('loadImage'), '')
        end
        
        function initializeSegmentationBrowser(self, ~)
            %TODO: These next items shouldn't need to happen.
            activeSegmentation = self.CurrentSegmentation;
            activeSegmentation.Name = 'Segmentation 1';
            
            theBrowser = self.getSegmentationBrowser();
            theBrowser.setSelection(1)
            self.refreshSegmentationBrowser()
        end
        
        function associateSegmentationWithBrowsers(self, segmentationIndex)
            segmentationDetailsCell = self.Session.convertToDetailsCell();
            
            theSegmentationBrowser = self.getSegmentationBrowser();
            theSegmentationBrowser.setContent(segmentationDetailsCell, ...
                segmentationIndex)
        end
        
        function refreshHistoryBrowser(self)
            activeSegmentation = self.Session.CurrentSegmentation();
            activeSegmentation.refreshHistoryBrowser()
        end
        
        function scrollHistoryBrowserToEnd(self)
            hBrowser = self.getHistoryBrowser();
            hBrowser.scrollToEnd()
        end
        
        function scrollSegmentationBrowserToEnd(self)
            hBrowser = self.getSegmentationBrowser();
            hBrowser.scrollToEnd()
        end
    end
    
    methods (Static)
        function deleteAllTools(~)
            imageslib.internal.apputil.manageToolInstances('deleteAll', 'imageSegmenter');
            T1 = timerfindall('Tag','ImageSegmenterFindCirclesTimer');
            T2 = timerfindall('Tag','ImageSegmenterActiveContourTimer');
            delete(T1);
            delete(T2);
        end
    end
    
    methods (Access = private)
        
        function createToolstrip(self)
            self.Toolstrip = iptui.internal.segmenter.Toolstrip(self.ToolGroup, self);
            self.Toolstrip.hideActiveContourTab()
            self.Toolstrip.hideFloodFillTab()
            self.Toolstrip.hideMorphologyTab()
            self.Toolstrip.hideThresholdTab()
            self.Toolstrip.hideGraphCutTab()
            self.Toolstrip.hideFindCirclesTab()
            self.Toolstrip.hideGrabCutTab()
        end
        
        function createDataBrowser(self)
            self.DataBrowser = iptui.internal.segmenter.DataBrowser(self);
        end
        
        function setupDocumentArea(self)
            
            group = self.ToolGroup.Peer.getWrappedComponent;
            
            % Remove View tab
            group.putGroupProperty(...
                com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB,...
                false);
            
            % Remove Document bar
            group.putGroupProperty(...
                com.mathworks.widgets.desk.DTGroupProperty.SHOW_SINGLE_ENTRY_DOCUMENT_BAR, false);
            
            % Disable hide document tabs
            group.putGroupProperty(...
                com.mathworks.widgets.desk.DTGroupProperty.PERMIT_DOCUMENT_BAR_HIDE, false);
            
            % Disable user tiling
            group.putGroupProperty(...
                com.mathworks.widgets.desk.DTGroupProperty.PERMIT_USER_TILE, false);
            
            % Disable drag-drop
            dropListener = com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER, dropListener);
            
            self.addUndoRedoCallbacksToQAB()
            
            % Position App
            [x,y,width,height] = imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition();
            self.ToolGroup.setPosition(x,y,width,height);
            self.ToolGroup.open();

            imageslib.internal.apputil.manageToolInstances('add', 'imageSegmenter', self);
            
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            
            % Setup space to report progress
            frame = md.getFrameContainingGroup(self.ToolGroup.Name);
            sb = javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
            javaMethodEDT('setSharedStatusBar', frame, sb)
            self.jProgressLabel = javaObjectEDT('javax.swing.JLabel','');
            self.jProgressLabel.setName('progressLabel');
            sb.add(self.jProgressLabel);
            
        end
        
        function buildScrollPanel(self, im)
            self.ScrollPanel = iptui.internal.segmenter.TwoMaskScrollPanel(im);
            self.updateScrollPanelOpacity(self.Toolstrip.getOpacity)
            self.ScrollPanel.updateCommittedMask(false([size(im,1) size(im,2)]))
            self.ScrollPanel.addToApp(self.ToolGroup);
            self.ScrollPanel.Visible = 'on';
            % Build message pane for scroll panel
            self.buildMessagePane();
        end
        
        function doClosingSession(self, event)
            if strcmp(event.EventData.EventType, 'CLOSING')
                imageslib.internal.apputil.manageToolInstances('remove', 'imageSegmenter', self);
                delete(self);
            end
        end
        
        function addUndoRedoCallbacksToQAB(self)
            undoAction = com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Undo', javax.swing.ImageIcon);
            javaMethodEDT('setEnabled', undoAction, false); % Initially disabled
            self.UndoActionListener = addlistener(undoAction.getCallback, ...
                'delayed', @self.undoHandler);
            
            redoAction = com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Redo', javax.swing.ImageIcon);
            javaMethodEDT('setEnabled', redoAction, false); % Initially disabled
            self.RedoActionListener = addlistener(redoAction.getCallback, ...
                'delayed', @self.redoHandler);
            
            helpAction = com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('My Help', javax.swing.ImageIcon);
            javaMethodEDT('setEnabled', helpAction, true); % Initially enabled
            self.HelpActionListener = addlistener(helpAction.getCallback, ...
                'delayed', @self.helpHandler);
            
            % Register the actions with the Undo/Redo buttons on QAB
            ctm = com.mathworks.toolstrip.factory.ContextTargetingManager;
            ctm.setToolName(undoAction, 'undo')
            ctm.setToolName(redoAction, 'redo')
            ctm.setToolName(helpAction, 'help')
            
            % Set the context actions BEFORE opening the ToolGroup
            ja = javaArray('javax.swing.Action', 1);
            ja(1) = undoAction;
            ja(2) = redoAction;
            ja(3) = helpAction;
            c = self.ToolGroup.Peer.getWrappedComponent;
            c.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.CONTEXT_ACTIONS, ja);
            
            self.jUndoActionHandler = undoAction;
            self.jRedoActionHandler = redoAction;
            self.jHelpActionHandler = helpAction;
        end
        
        function addUndoRedoKeyListeners(self)
            hFig = self.getScrollPanelFigure();
            set(hFig, 'WindowKeyPressFcn', @self.keypressHandler)
        end
        
        function keypressHandler(self, ~, evt)
            if numel(evt.Modifier) ~= 1
                return
            end
            
            switch (evt.Modifier{1})
            case 'control'
                switch (evt.Key)
                case {'z', 'Z'}
                    self.undoHandler()
                case {'y', 'Y'}
                    self.redoHandler()
                otherwise
                    return
                end
                
            otherwise
                return
            end
        end
        
        function enableUndoActionQABButton(self, tf)
            javaMethodEDT('setEnabled', self.jUndoActionHandler, tf);
        end
        
        function enableRedoActionQABButton(self, tf)
            javaMethodEDT('setEnabled', self.jRedoActionHandler, tf);
        end
        
        function refreshSegmentationBrowser(self)
            numSegmentations = self.Session.NumberOfSegmentations;
            segmentationListCell = cell(numSegmentations, 2);
            
            for i = 1:numSegmentations
                thisSegmentation = self.Session.getSegmentationByIndex(i);
                
                theMask = thisSegmentation.getMask();
                segmentationListCell{i, 1} = iptui.internal.segmenter.createThumbnail(theMask);
                segmentationListCell{i, 2} = thisSegmentation.Name;
            end
            
            theBrowser = self.getSegmentationBrowser();
            theBrowser.setContent(segmentationListCell, theBrowser.getSelection())
        end
        
        function refreshSegmentationBrowserThumbnail(self, theMask)
            newThumbnailFilename = iptui.internal.segmenter.createThumbnail(theMask);
            hBrowser = self.getSegmentationBrowser();
            hBrowser.updateActiveThumbnail(newThumbnailFilename)
        end
        
        function addFunctionDeclaration(self, generator, wasMaskLoaded)
            fcnName = 'segmentImage';
            if (self.Session.WasRGB)
                inputs = {'RGB'};
            else
                inputs = {'X'};
            end
            if (wasMaskLoaded)
                inputs{2} = 'MASK'; 
            end
            
            outputs = {'BW', 'maskedImage'};
            
            h1Line  = 'Segment image using auto-generated code from imageSegmenter app';
            
            description = [sprintf('segments image %s using auto-generated code ',inputs{1}) ...
                'from the imageSegmenter app. The final segmentation is ', ...
                'returned in BW, and a masked image is returned in MASKEDIMAGE.'];
            
            generator.addFunctionDeclaration(fcnName, inputs, outputs, h1Line);
            generator.addSyntaxHelp(fcnName, description, inputs, outputs);
        end
    end
end

function addGaborSubfunction(generator)

generator.addLine('function gaborFeatures = createGaborFeatures(im)');
generator.addReturn()
generator.addLine('if size(im,3) == 3');
generator.addLine('    im = prepLab(im);');
generator.addLine('end');
generator.addReturn()
generator.addLine('im = im2single(im);');
generator.addReturn()
generator.addLine('imageSize = size(im);');
generator.addLine('numRows = imageSize(1);');
generator.addLine('numCols = imageSize(2);');
generator.addReturn()
generator.addLine('wavelengthMin = 4/sqrt(2);');
generator.addLine('wavelengthMax = hypot(numRows,numCols);');
generator.addLine('n = floor(log2(wavelengthMax/wavelengthMin));');
generator.addLine('wavelength = 2.^(0:(n-2)) * wavelengthMin;');
generator.addReturn()
generator.addLine('deltaTheta = 45;');
generator.addLine('orientation = 0:deltaTheta:(180-deltaTheta);');
generator.addReturn()
generator.addLine('g = gabor(wavelength,orientation);');
generator.addLine('gabormag = imgaborfilt(im(:,:,1),g);');
generator.addReturn()
generator.addLine('for i = 1:length(g)');
generator.addLine('    sigma = 0.5*g(i).Wavelength;');
generator.addLine('    K = 3;');
generator.addLine('    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K*sigma);');
generator.addLine('end');
generator.addComment('Increases liklihood that neighboring pixels/subregions are segmented together');
generator.addLine('X = 1:numCols;');
generator.addLine('Y = 1:numRows;');
generator.addLine('[X,Y] = meshgrid(X,Y);');
generator.addLine('featureSet = cat(3,gabormag,X);');
generator.addLine('featureSet = cat(3,featureSet,Y);');
generator.addLine('featureSet = reshape(featureSet,numRows*numCols,[]);');
generator.addComment('Normalize feature set');
generator.addLine('featureSet = featureSet - mean(featureSet);');
generator.addLine('featureSet = featureSet ./ std(featureSet);');
generator.addReturn()
generator.addLine('gaborFeatures = reshape(featureSet,[numRows,numCols,size(featureSet,2)]);');
generator.addComment('Add color/intensity into feature set');
generator.addLine('gaborFeatures = cat(3,gaborFeatures,im);');
generator.addReturn()
generator.addLine('end');
generator.addReturn()
end

function addPrepLabSubfunction(generator)

generator.addLine('function out = prepLab(in)');
generator.addComment('Convert L*a*b* image to range [0,1]');
generator.addLine('out = in;');
generator.addLine('out(:,:,1)   = in(:,:,1) / 100;  % L range is [0 100].');
generator.addLine('out(:,:,2:3) = (in(:,:,2:3) + 100) / 200;  % a* and b* range is [-100,100].');
generator.addReturn()
generator.addLine('end');

end

function TF = maskHasRegions(mask)

TF = any(mask(:));

end
