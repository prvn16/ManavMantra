classdef GraphCutTab < iptui.internal.segmenter.GraphCutBaseTab
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    %%Public API
    methods
        function self = GraphCutTab(toolGroup, tabGroup, theToolstrip, theApp, varargin)

            % Call base class constructor
            self@iptui.internal.segmenter.GraphCutBaseTab(toolGroup, tabGroup, theToolstrip, theApp, 'graphCutTab', varargin{:})
            
        end
        
        function setMode(self, mode)
            import iptui.internal.segmenter.AppMode;
            
            switch (mode)
            case AppMode.GraphCutOpened
                
                self.initializeGraphCut();
                self.MarkerSize = 1 + round(mean(self.imSize(1:2))/100);
                self.hGraphCutMaskOverlay = iptui.internal.segmenter.BoundaryMaskOverlay(self.hApp.getScrollPanelAxes(),self.imSize);
                self.hGraphCutMaskOverlay.redrawBoundary(self.Boundaries);                
                self.disableApply();
                self.hApp.hideLegend();
                self.hApp.ScrollPanel.resetCommittedMask();
                
                % Message Panes
                self.MessageStatus = true;
                self.showMessagePane();
                
                % Set tool to start marking
                self.ForegroundButton.Value = true;
                self.addForegroundScribble();
                self.enableAllButtons();          
                self.showSuperpixelBoundaries();
                
            case AppMode.GraphCutDone
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
                
            case AppMode.ImageLoaded
                self.updateImageProperties()

            case AppMode.OpacityChanged
                self.reactToOpacityChange()
            case AppMode.ShowBinary
                self.reactToShowBinary()
            case AppMode.UnshowBinary
                self.reactToUnshowBinary()
            case AppMode.ToggleTexture
                self.TextureMgr.updateTextureState(self.hApp.Session.UseTexture);
            end
            
        end
        
        function applyAndClose(self)
            self.onApply();
            self.onClose();
        end
        
        function onApply(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            self.hApp.setCurrentMask(self.GraphCutter.Mask);
            self.ApplyCloseMgr.ApplyButton.Enabled = false;
            if self.hApp.Session.UseTexture
                self.hApp.addToHistory(self.GraphCutter.Mask,getMessageString('graphCutTextureComment'),self.getCommandsForHistory());
            else
                self.hApp.addToHistory(self.GraphCutter.Mask,getMessageString('graphCutComment'),self.getCommandsForHistory());
            end
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
            
            self.hToolstrip.showSegmentTab()
            self.hToolstrip.hideGraphCutTab()
            self.disableAllButtons();
            self.hToolstrip.setMode(AppMode.GraphCutDone);
        end
    end
    
    %%Layout
    methods (Access = protected)
        
        function layoutTab(self)
            
            import iptui.internal.segmenter.getMessageString;

            self.DrawSection        = self.hTab.addSection(getMessageString('markerTools'));
            self.DrawSection.Tag    = 'Draw Tools';
            self.ClearSection       = self.hTab.addSection(getMessageString('clearTools'));
            self.ClearSection.Tag   = 'Clear Markings';
            self.SuperpixelSection  = self.hTab.addSection(getMessageString('superpixelSettings'));
            self.SuperpixelSection.Tag  = 'Superpixel Settings';
            self.TextureSection     = self.addTextureSection();
            self.PanZoomSection     = self.addPanZoomSection();
            self.ViewSection        = self.addViewSection();
            self.ApplyCloseSection  = self.addApplyCloseSection();
            
            self.layoutDrawSection();
            self.layoutClearSection();
            self.layoutSuperpixelSection();
            
        end
        
        function section = addTextureSection(self)
            self.TextureMgr = iptui.internal.segmenter.TextureManager(self.hTab,self.hApp,self.hToolstrip);
            section = self.TextureMgr.Section;
            addlistener(self.TextureMgr, 'TextureButtonClicked', @(~,~) self.textureCallback());
        end
        
        function section = addApplyCloseSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            tabName = getMessageString('graphCutTab');
            
            useApplyAndClose = true;
            
            self.ApplyCloseMgr = iptui.internal.ApplyCloseManager(self.hTab, tabName, useApplyAndClose);
            section = self.ApplyCloseMgr.Section;
            
            addlistener(self.ApplyCloseMgr.ApplyButton,'ButtonPushed',@(~,~)self.applyAndClose());
            addlistener(self.ApplyCloseMgr.CloseButton,'ButtonPushed',@(~,~)self.onClose());
        end
    end
    
    %%Algorithm
    methods (Access = protected)
        
        function applyGraphCut(self)      
            
            import iptui.internal.segmenter.getMessageString;
                       
            % Default parameters
            conn = 8; % node connectivity
            lambda = 500; % edge weight scale factor
            
            self.hApp.updateStatusBarText(getMessageString('applyingGraphCut'));
            self.showAsBusy()
                     
            if ~self.isGraphBuilt
                if self.hApp.Session.UseTexture
                self.GraphCutter = images.graphcut.internal.lazysnapping(self.hApp.Session.getTextureFeatures(), ...
                    self.SuperpixelLabelMatrix,self.NumSuperpixels,conn,lambda);
                elseif self.hApp.wasRGB
                self.GraphCutter = images.graphcut.internal.lazysnapping(prepLab(self.hApp.getImage()), ...
                    self.SuperpixelLabelMatrix,self.NumSuperpixels,conn,lambda);
                else
                self.GraphCutter = images.graphcut.internal.lazysnapping(self.hApp.getImage(), ...
                    self.SuperpixelLabelMatrix,self.NumSuperpixels,conn,lambda);
                end
            end

            if self.NumSuperpixels > 1  
                self.GraphCutter = self.GraphCutter.addHardConstraints(self.ForegroundInd,self.BackgroundInd);
                self.GraphCutter = self.GraphCutter.segment();
            end
            
            mask = self.GraphCutter.Mask;
            self.hApp.showLegend();
            
            commandForHistory = self.getCommandsForHistory();
            self.hApp.setTemporaryHistory(mask, ...
                 'Graph Cut', {commandForHistory});
                
            self.hApp.ScrollPanel.resetCommittedMask();
            
            self.isGraphBuilt = true;
            
            self.enableApply();
            
            self.hApp.updateStatusBarText('');
            self.unshowAsBusy()
            
        end
        
        function TF = isGraphCutValid(self)
            TF = ~isempty(self.ForegroundInd(:)) && ~isempty(self.BackgroundInd(:));
        end

    end
    
    %%Callbacks
    methods (Access = protected)
        
        function clearAll(self)
            
            self.unselectPanZoomTools()
            
            % This is necessary to allow any lines to finsh drawing before
            % they are deleted.
            drawnow;
            
            self.clearForegroundMask();
            self.clearBackgroundMask();
            self.MessageStatus = true;
            self.cleanupAfterClear();
            
        end
        
        function cleanupAfterClear(self)
            self.hApp.ScrollPanel.resetPreviewMask();
            self.hApp.hideLegend();
            self.disableApply();
            self.showMessagePane();
        end
        
        function textureCallback(self)
            if self.isGraphCutValid()
                self.isGraphBuilt = false;
                self.applyGraphCut();
            end
        end
        
    end
    
     %%Helpers
    methods (Access = protected)
        
        function installPointer(self)
            
            hAx  = self.hApp.getScrollPanelAxes();
            hFig = self.hApp.getScrollPanelFigure();
            
            % Setup pointer manager for the figure
            iptPointerManager(hFig);
            
            switch self.EditMode
                case {'fore', 'back'}
                    myPointer = self.foreScribble;
                    % Install new pointer behavior
                    iptSetPointerBehavior(hAx,@(src,evt) set(src,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16 1]));
                case 'erase'
                    myPointer = self.Eraser;
                    % Install new pointer behavior
                    iptSetPointerBehavior(hAx,@(src,evt) set(src,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[8 8]));
            end        
            
            % Add listener to button up
            hFig.WindowButtonDownFcn = @(src,~) self.respondToClick(src);
            
        end
        
        function enableAllButtons(self)

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
            
        end 
        
        function commands = getCommandsForHistory(self)
        
            foreInd = self.ForegroundInd;
            backInd = self.BackgroundInd;
            fString = sprintf('%d ', foreInd);
            bString = sprintf('%d ', backInd);
            
            if numel(foreInd) == 1
                commands{1} = sprintf('foregroundInd = %s;', fString);
            else
                commands{1} = sprintf('foregroundInd = [%s];', fString);
            end
            
            if numel(backInd) == 1
                commands{2} = sprintf('backgroundInd = %s;', bString);
            else
                commands{2} = sprintf('backgroundInd = [%s];', bString);
            end

            if self.hApp.wasRGB
                commands{3} = sprintf('L = superpixels(X,%d,''IsInputLab'',true);',self.NumRequestedSuperpixels);
                if self.hApp.Session.UseTexture
                    commands{4} = sprintf('BW = lazysnapping(gaborX,L,foregroundInd,backgroundInd);');
                else
                    commands{4} = '';
                    commands{5} = '% Convert L*a*b* range to [0 1]';
                    commands{6} = 'scaledX = prepLab(X);';
                    commands{7} = sprintf('BW = lazysnapping(scaledX,L,foregroundInd,backgroundInd);');
                end
            else
                commands{3} = sprintf('L = superpixels(X,%d);',self.NumRequestedSuperpixels);
                if self.hApp.Session.UseTexture
                    commands{4} = sprintf('BW = lazysnapping(gaborX,L,foregroundInd,backgroundInd);');
                else
                    commands{4} = sprintf('BW = lazysnapping(X,L,foregroundInd,backgroundInd);');
                end
            end
            
        end
        
        function showMessagePane(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            fontName = get(0,'DefaultTextFontName');
            fontSize = 12;
            
            if self.MessageStatus
                message = getMessageString('graphCutMessagePane1');
                txtPane = ctrluis.PopupPanel.createMessageTextPane(message,fontName,fontSize);
                self.hApp.MessagePane.setPanel(txtPane);
                self.hApp.MessagePane.showPanel();
                self.hApp.MessagePane.setVisible(true);
            else
                message = getMessageString('graphCutMessagePane2');
                txtPane = ctrluis.PopupPanel.createMessageTextPane(message,fontName,fontSize);
                self.hApp.MessagePane.setPanel(txtPane);
                self.hApp.MessagePane.showPanel();
                self.hApp.MessagePane.setVisible(true); 
            end
            
        end
        
        function hideMessagePane(self)
            
            if ~isempty(self.hApp.MessagePane) && isvalid(self.hApp.MessagePane)
                self.hApp.MessagePane.setVisible(false);
            end
        end
        
    end
    
end

function out = prepLab(in)
%prepLab - Convert L*a*b* image to range [0,1]

out = in;
out(:,:,1)   = in(:,:,1) / 100;  % L range is [0 100].
out(:,:,2:3) = (in(:,:,2:3) + 100) / 200;  % a* and b* range is [-100,100].

end
