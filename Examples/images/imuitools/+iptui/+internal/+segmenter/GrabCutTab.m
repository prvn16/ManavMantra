classdef GrabCutTab < iptui.internal.segmenter.GraphCutBaseTab
    
    % Copyright 2017 The MathWorks, Inc.
    
    %%UI Controls
    properties
        ROISection
        ROIStyleLabel
        ROIStyleButton
        ROIButton
        
        ROIStyle = 'Rectangle'
        isGrabCutInitialized

        LastCommittedMask
        
    end
    
    %%Public API
    methods
        function self = GrabCutTab(toolGroup, tabGroup, theToolstrip, theApp, varargin)

            % Call base class constructor
            self@iptui.internal.segmenter.GraphCutBaseTab(toolGroup, tabGroup, theToolstrip, theApp, 'grabcutTab', varargin{:})
            self.HideDataBrowser = false;
        end
        
        function setMode(self, mode)
            import iptui.internal.segmenter.AppMode;
            
            switch (mode)
            case AppMode.GrabCutOpened
                
                self.initializeGraphCut();
                self.MarkerSize = 1 + round(mean(self.imSize(1:2))/100);
                self.hGraphCutMaskOverlay = iptui.internal.segmenter.BoundaryMaskOverlay(self.hApp.getScrollPanelAxes(),self.imSize);
                self.hGraphCutMaskOverlay.redrawBoundary(self.Boundaries);                
                self.disableApply();
                self.hApp.hideLegend();
                self.LastCommittedMask = self.hApp.getCurrentMask();
                
                % Message Panes
                self.MessageStatus = true;
                self.showMessagePane();
                
                % Set tool to start marking
                clearAll(self)         
                self.showSuperpixelBoundaries();
                
                drawnow;
                self.createTutorialDialog()
                
            case AppMode.GrabCutDone
                self.removePointer();
                
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
                  AppMode.FindCirclesOpened,...
                  AppMode.FindCirclesDone,...
                  AppMode.GraphCutOpened,...
                  AppMode.GraphCutDone,...
                  AppMode.ToggleTexture}
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
                
            case AppMode.ImageLoaded
                self.updateImageProperties()

            case AppMode.OpacityChanged
                self.reactToOpacityChange()
            case AppMode.ShowBinary
                self.reactToShowBinary()
            case AppMode.UnshowBinary
                self.reactToUnshowBinary()
            end
            
        end
        
        function onApply(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            
            currentMask = self.GraphCutter.Mask | self.LastCommittedMask;
            self.hApp.setCurrentMask(currentMask);
            self.LastCommittedMask = self.hApp.getCurrentMask();
            
            self.ApplyCloseMgr.ApplyButton.Enabled = false;
            self.hApp.addToHistory(currentMask,getMessageString('grabcutComment'),self.getCommandsForHistory());
            
            self.clearAll();
        end
        
        function onClose(self)
            
            import iptui.internal.segmenter.AppMode;
            self.hApp.clearTemporaryHistory()
            
            self.unselectPanZoomTools()
            
            % This ensures that zoom tools have settled down before the
            % marker pointer is removed.
            drawnow;
            
            self.hideMessagePane()
            self.clearForegroundMask()
            self.clearBackgroundMask()
            
            self.hGraphCutMaskOverlay.delete()
            self.hGraphCutMaskOverlay = [];
            
            delete(self.ROI);
            self.ROI = [];
            
            self.hToolstrip.showSegmentTab()
            self.hToolstrip.hideGrabCutTab()
            self.disableAllButtons();
            self.hToolstrip.setMode(AppMode.GrabCutDone);
        end
        
    end
    
    %%Layout
    methods (Access = protected)
        
        function layoutTab(self)
            
            import iptui.internal.segmenter.getMessageString;

            self.ROISection        = self.hTab.addSection(getMessageString('roi'));
            self.ROISection.Tag    = 'ROI Tools';
            self.DrawSection        = self.hTab.addSection(getMessageString('markerTools'));
            self.DrawSection.Tag    = 'Draw Tools';
            self.ClearSection       = self.hTab.addSection(getMessageString('clearTools'));
            self.ClearSection.Tag   = 'Clear Markings';
            self.SuperpixelSection  = self.hTab.addSection(getMessageString('superpixelSettings'));
            self.SuperpixelSection.Tag  = 'Superpixel Settings';
            self.PanZoomSection     = self.addPanZoomSection();
            self.ViewSection        = self.addViewSection();
            self.ApplyCloseSection  = self.addApplyCloseSection();
            
            self.layoutROISection();
            self.layoutDrawSection();
            self.layoutClearSection();
            self.layoutSuperpixelSection();
            
        end
        
        function layoutROISection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            
            % ROI Style Label
            self.ROIStyleLabel = matlab.ui.internal.toolstrip.Label(getMessageString('roiStyle'));
            
            % ROI Style Button
            self.ROIStyleButton = matlab.ui.internal.toolstrip.DropDownButton(getMessageString('rectangle'));
            self.ROIStyleButton.Tag = 'btnROIStyle';
            self.ROIStyleButton.Description = getMessageString('drawROITooltip');
            
            %Method Dropdown
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getMessageString('rectangle'));
            sub_item1.Description = getMessageString('rectangleTooltip');
            addlistener(sub_item1, 'ItemPushed', @(~,~) self.setRectangleStyleSelection());
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getMessageString('polygon'));
            sub_item2.Description =  getMessageString('polygonTooltip');
            addlistener(sub_item2, 'ItemPushed', @(~,~) self.setPolygonStyleSelection());
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            
            self.ROIStyleButton.Popup = sub_popup;
            self.ROIStyleButton.Popup.Tag = 'popupROIStyleList';
            
            self.ROIButton = matlab.ui.internal.toolstrip.ToggleButton(getMessageString('drawROI'),Icon.DRAWROI_24);
            self.ROIButton.Tag = 'btnROIButton';
            self.ROIButton.Description = getMessageString('drawROITooltip');
            addlistener(self.ROIButton, 'ValueChanged', @(~,~) self.drawROI());
            
            c = self.ROISection.addColumn('width',90,...
                'HorizontalAlignment','center');
            c.add(self.ROIStyleLabel);
            c.add(self.ROIStyleButton);
            c2 = self.ROISection.addColumn();
            c2.add(self.ROIButton);
            
        end
        
        function section = addApplyCloseSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            tabName = getMessageString('grabcutTab');
            
            useApplyAndClose = false;
            self.ApplyCloseMgr = iptui.internal.ApplyCloseManager(self.hTab, tabName, useApplyAndClose);
            section = self.ApplyCloseMgr.Section;
            
            addlistener(self.ApplyCloseMgr.ApplyButton,'ButtonPushed',@(~,~)self.onApply());
            addlistener(self.ApplyCloseMgr.CloseButton,'ButtonPushed',@(~,~)self.onClose());
        end
    end
    
    %%Algorithm
    methods (Access = protected)
        
        function applyGraphCut(self)      
            
            import iptui.internal.segmenter.getMessageString;
                       
            % Default parameters
            conn = 8; % node connectivity
            maxIters = 5; % maximum iterations
            
            self.hApp.updateStatusBarText(getMessageString('applyingGraphCut'));
            self.showAsBusy()
                     
            if ~self.isGraphBuilt
                % If the graph must be rebuilt, then grabcut must also be
                % initialized below
                self.isGrabCutInitialized = false;
                if self.hApp.wasRGB
                self.GraphCutter = images.graphcut.internal.grabcut(prepLab(self.hApp.getImage()), ...
                    self.SuperpixelLabelMatrix,self.NumSuperpixels,conn,maxIters);
                else
                self.GraphCutter = images.graphcut.internal.grabcut(self.hApp.getImage(), ...
                    self.SuperpixelLabelMatrix,self.NumSuperpixels,conn,maxIters);
                end
            end
            
            if ~self.isGrabCutInitialized
                roiMask = createMask(self.ROI,self.imSize(1),self.imSize(2));
                self.GraphCutter = self.GraphCutter.addHardConstraints(self.ForegroundInd,self.BackgroundInd);
                self.GraphCutter = self.GraphCutter.addBoundingBox(roiMask);

            elseif (self.NumSuperpixels > 1)
                self.GraphCutter = self.GraphCutter.addHardConstraints(self.ForegroundInd,self.BackgroundInd);
                self.GraphCutter = self.GraphCutter.segment();
                if (isempty(self.ForegroundInd) && isempty(self.BackgroundInd)) && max(self.GraphCutter.Mask(:)) == 0
                    % Special case when there are no foreground/background
                    % marks AND grabcut segmentation fails (resulting in
                    % what would be an empty mask).
                    roiMask = createMask(self.ROI,self.imSize(1),self.imSize(2));
                    self.GraphCutter = self.GraphCutter.addBoundingBox(roiMask);
                end
            end
            
            mask = self.GraphCutter.Mask;
            
            self.hApp.showLegend();
            
            commandForHistory = self.getCommandsForHistory();
            self.hApp.setTemporaryHistory(mask, ...
                 'Local Graph Cut', {commandForHistory});
                            
            self.isGraphBuilt = true;
            self.isGrabCutInitialized = true;
            
            self.enableApply();
            
            self.hApp.updateStatusBarText('');
            self.unshowAsBusy()
            
        end
        
        function TF = isGraphCutValid(self)
            TF = ~isempty(self.ROI) && self.ROI.Valid;
        end

    end
    
    %%Callbacks
    methods (Access = protected)
        
        function drawROI(self)
            
            self.ROIButton.Value = true;
            self.ForegroundButton.Value = false;
            self.BackgroundButton.Value = false;
            self.EraseButton.Value = false;
            self.EditMode = 'ROI';
            self.unselectPanZoomTools()
            self.updateScribbleInteraction();
            
        end
        
        function setRectangleStyleSelection(self)
            self.ROIStyle = 'Rectangle';
            self.ROIStyleButton.Text = iptui.internal.segmenter.getMessageString('rectangle');
        end
        
        function setPolygonStyleSelection(self)
            self.ROIStyle = 'Polygon';
            self.ROIStyleButton.Text = iptui.internal.segmenter.getMessageString('polygon');
        end
        
        function clearAll(self)
            
            self.unselectPanZoomTools()
            
            % This is necessary to allow any lines to finsh drawing before
            % they are deleted.
            drawnow;
            
            self.clearForegroundMask();
            self.clearBackgroundMask();
            delete(self.ROI);
            self.ROI = [];

            self.MessageStatus = true;
            self.isGrabCutInitialized = false;
            self.cleanupAfterClear();
            
            enableStartButtons(self);
            drawROI(self);
        end
        
        function cleanupAfterClear(self)
            
            if self.isGraphCutValid
                self.applyGraphCut();
            else
                self.hApp.ScrollPanel.resetPreviewMask();
                self.hApp.hideLegend();
                self.disableApply();
                self.showMessagePane();
            end
        end
        
        function drawROICallback(self)
            
            self.disableAllButtons();
            self.hApp.DrawingROI = true;
            hFig = self.hApp.getScrollPanelFigure();
            hFig.WindowButtonDownFcn = [];
            
            switch self.ROIStyle
                case 'Rectangle'
                    selectedROI = images.internal.drawingTools.Rectangle(self.hApp.getScrollPanelAxes());
                case 'Polygon'
                    selectedROI = images.internal.drawingTools.Polygon(self.hApp.getScrollPanelAxes());
                    selectedROI.MinimumNumberOfPoints = 3;
            end
            
            selectedROI.beginDrawing()
            
            if ~isvalid(self)
                return; % Case when app is closed during draw
            end
            
            self.hApp.DrawingROI = false;
            
            if selectedROI.Valid
                wireGrabCutListeners(self,selectedROI);
                self.isGrabCutInitialized = false;
                self.ROI = selectedROI;
                self.applyGraphCut();
                self.enableContinueButtons();
                self.ForegroundButton.Value = true;
                self.ROIButton.Value = false;
                self.addForegroundScribble();
            else
                % ROIs can be invalid when drawn interactively.
                delete(selectedROI);
                self.enableStartButtons();
                hFig.WindowButtonDownFcn = @(~,~) self.drawROICallback();
            end
            
        end
        
        function modifyROICallback(self)
            self.isGrabCutInitialized = false;
            self.applyGraphCut();
        end
        
        function wireGrabCutListeners(self,selectedROI)
            if strcmp(self.ROIStyle,'Polygon')
                addlistener(selectedROI, 'VertexAdded', @(~,~) self.modifyROICallback());
                addlistener(selectedROI, 'VertexRemoved', @(~,~) self.modifyROICallback());
            end
            addlistener(selectedROI, 'Deleted', @(~,~) self.clearAll());
            addlistener(selectedROI, 'Moved', @(~,~) self.modifyROICallback());
        end
        
    end
    
     %%Helpers
    methods (Access = protected)
        
        function installPointer(self)
            
            hIm  = self.hApp.getScrollPanelImage();
            hAx  = self.hApp.getScrollPanelAxes();
            hFig = self.hApp.getScrollPanelFigure();
            
            % Setup pointer manager for the figure
            iptPointerManager(hFig);
            
            switch self.EditMode
                case {'fore', 'back'}
                    myPointer = self.foreScribble;
                    % Install new pointer behavior
                    iptSetPointerBehavior(hAx,@(src,evt) set(src,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16 1]));
                    % Add listener to button down
                    hIm.ButtonDownFcn = [];
                    hFig.WindowButtonDownFcn = @(src,~) self.respondToClick(src);
                case 'erase'
                    myPointer = self.Eraser;
                    % Install new pointer behavior
                    iptSetPointerBehavior(hAx,@(src,evt) set(src,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[8 8]));
                    % Add listener to button down
                    hIm.ButtonDownFcn = [];
                    hFig.WindowButtonDownFcn = @(src,~) self.respondToClick(src);
                case 'ROI'
                    iptSetPointerBehavior(hAx,@(src,evt) set(src,'Pointer','crosshair'));
                    % Add listener to button down
                    hFig.WindowButtonDownFcn = @(~,~) self.drawROICallback();
                    hIm.ButtonDownFcn = [];
            end        

        end
        
        function enableStartButtons(self)

            self.PanZoomMgr.Enabled                             = true;
            self.TextureMgr.Enabled                             = true;
            self.ViewMgr.Enabled                                = true;
            self.ApplyCloseMgr.CloseButton.Enabled              = true;
            self.ForegroundButton.Enabled                       = false;
            self.BackgroundButton.Enabled                       = false;
            self.EraseButton.Enabled                            = false;
            self.MarkerSizeButton.Enabled                       = true;
            self.ClearButton.Enabled                            = false;
            self.ShowSuperpixelButton.Enabled                   = true;
            self.SuperpixelDensityButton.Enabled                = true;
            self.ROIButton.Enabled                              = true;
            self.ROIStyleButton.Enabled                         = true;
            
        end
        
        function enableContinueButtons(self)

            self.PanZoomMgr.Enabled                             = true;
            self.TextureMgr.Enabled                             = true;
            self.ViewMgr.Enabled                                = true;
            self.ApplyCloseMgr.CloseButton.Enabled              = true;
            self.ForegroundButton.Enabled                       = true;
            self.BackgroundButton.Enabled                       = true;
            self.EraseButton.Enabled                            = true;
            self.MarkerSizeButton.Enabled                       = true;
            self.ClearButton.Enabled                            = true;
            self.ShowSuperpixelButton.Enabled                   = true;
            self.SuperpixelDensityButton.Enabled                = true;
            self.ApplyCloseMgr.ApplyButton.Enabled              = true;
            self.ROIButton.Enabled                              = false;
            self.ROIStyleButton.Enabled                         = false;
            
        end
        
        function disableAllButtons(self)

            self.PanZoomMgr.Enabled                             = false;
            self.TextureMgr.Enabled                             = false;
            self.ViewMgr.Enabled                                = false;
            self.ApplyCloseMgr.ApplyButton.Enabled              = false;
            self.ApplyCloseMgr.CloseButton.Enabled              = false;
            self.ForegroundButton.Enabled                       = false;
            self.BackgroundButton.Enabled                       = false;
            self.EraseButton.Enabled                            = false;
            self.MarkerSizeButton.Enabled                       = false;
            self.ClearButton.Enabled                            = false;
            self.ShowSuperpixelButton.Enabled                   = false;
            self.SuperpixelDensityButton.Enabled                = false;
            self.ROIButton.Enabled                              = false;
            self.ROIStyleButton.Enabled                         = false;
            
        end 
        
        function commands = getCommandsForHistory(self)
            
            pos = self.ROI.Position;
            if strcmp(self.ROIStyle,'Rectangle')
                x = [pos(1), pos(1)+pos(3),pos(1)+pos(3),pos(1)];
                y = [pos(2), pos(2), pos(2)+pos(4), pos(2)+pos(4)];
            else
                x = pos(:,1)';
                y = pos(:,2)';
            end
            
            xString = sprintf('%0.4f ', x);
                yString = sprintf('%0.4f ', y);
                commands{1} = sprintf('xPos = [%s];',xString);
                commands{2} = sprintf('yPos = [%s];',yString);
                commands{3} = 'm = size(BW, 1);';
                commands{4} = 'n = size(BW, 2);';
                commands{5} = sprintf('ROI = poly2mask(xPos,yPos,m,n);');
            
            foreInd = self.ForegroundInd;
            backInd = self.BackgroundInd;
            fString = sprintf('%d ', foreInd);
            bString = sprintf('%d ', backInd);
            
            if isempty(foreInd)
                commands{6} = sprintf('foregroundInd = [];');
            elseif numel(foreInd) == 1
                commands{6} = sprintf('foregroundInd = %s;', fString);
            else
                commands{6} = sprintf('foregroundInd = [%s];', fString);
            end
            
            if isempty(backInd)
                commands{7} = sprintf('backgroundInd = [];');
            elseif numel(backInd) == 1
                commands{7} = sprintf('backgroundInd = %s;', bString);
            else
                commands{7} = sprintf('backgroundInd = [%s];', bString);
            end

            if self.hApp.wasRGB
                commands{8} = sprintf('L = superpixels(X,%d,''IsInputLab'',true);',self.NumRequestedSuperpixels);
                commands{9} = '';
                commands{10} = '% Convert L*a*b* range to [0 1]';
                commands{11} = 'scaledX = prepLab(X);';
                commands{12} = sprintf('BW = BW | grabcut(scaledX,L,ROI,foregroundInd,backgroundInd);');
            else
                commands{8} = sprintf('L = superpixels(X,%d);',self.NumRequestedSuperpixels);
                commands{9} = sprintf('BW = BW | grabcut(X,L,ROI,foregroundInd,backgroundInd);');
            end
            
        end
        
        function showMessagePane(~)
            % No-op
        end
        
        function hideMessagePane(self)
            if ~isempty(self.hApp.MessagePane) && isvalid(self.hApp.MessagePane)
                self.hApp.MessagePane.setVisible(false);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function createTutorialDialog()
            
            s = settings;
            
            messageStrings = {getString(message('images:imageSegmenter:grabcutTutorialStep1')),...
                getString(message('images:imageSegmenter:grabcutTutorialStep2')),...
                getString(message('images:imageSegmenter:grabcutTutorialStep3')),...
                getString(message('images:imageSegmenter:grabcutTutorialStep4'))};
            
            titleString = getString(message('images:imageSegmenter:grabcutTutorialTitle'));
            
            imagePaths = {fullfile(matlabroot,'toolbox','images','imuitools','+iptui','+internal','+segmenter','+images','GraphCut_1.png'),...
                fullfile(matlabroot,'toolbox','images','imuitools','+iptui','+internal','+segmenter','+images','GraphCut_2.png'),...
                fullfile(matlabroot,'toolbox','images','imuitools','+iptui','+internal','+segmenter','+images','GraphCut_3.png'),...
                fullfile(matlabroot,'toolbox','images','imuitools','+iptui','+internal','+segmenter','+images','GraphCut_4.png')};
            
            images.internal.app.TutorialDialog(imagePaths,messageStrings,titleString,s.images.imagesegmentertool.showGrabCutTutorialDialog);
            
        end
        
    end
    
end

function out = prepLab(in)
%prepLab - Convert L*a*b* image to range [0,1]

out = in;
out(:,:,1)   = in(:,:,1) / 100;  % L range is [0 100].
out(:,:,2:3) = (in(:,:,2:3) + 100) / 200;  % a* and b* range is [-100,100].

end
