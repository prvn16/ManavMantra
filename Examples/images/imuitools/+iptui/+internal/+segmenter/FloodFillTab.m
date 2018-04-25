classdef FloodFillTab < handle
    
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
        FloodFillSection
        DistanceMetricLabel
        DistanceMetricButton
        ToleranceLabel
        ToleranceSlider
        ToleranceSliderListener
        ToleranceText
        ToleranceTextListener
        
        PaintBucket
        
        PanZoomSection
        PanZoomMgr
        
        TextureSection
        TextureMgr
        
        ViewSection
        ViewMgr
        
        ApplyCloseSection
        ApplyCloseMgr
        
        OriginalPointerBehavior
        
        OpacitySliderListener
        ShowBinaryButtonListener
        
    end
    
    %%Algorithm
    properties
        LastCommittedMask
        LocationOfLastFillClick
        MaskFromClick
    end
    
    %%Public API
    methods
        function self = FloodFillTab(toolGroup, tabGroup, theToolstrip, theApp, varargin)
            
            if (nargin == 3)
                self.hTab = iptui.internal.segmenter.createTab(tabGroup, 'floodFillTab');
            else
                self.hTab = iptui.internal.segmenter.createTab(tabGroup, 'floodFillTab', varargin{:});
            end
            
            self.hToolGroup = toolGroup;
            self.hTabGroup = tabGroup;
            self.hToolstrip = theToolstrip;
            self.hApp       = theApp;
            
            self.layoutTab()
            
            self.LocationOfLastFillClick = [];
            self.Visible = true;
        end
        
        function show(self)
            if (~self.isVisible())
                self.hTabGroup.add(self.hTab)
            end
            
            self.updateToleranceSliderLimits()
            self.hApp.showLegend()
            self.makeActive()
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
        
        function setMode(self, mode)
            
            import iptui.internal.segmenter.AppMode;
            switch (mode)
                case AppMode.FloodFillTabOpened
                    self.disableToleranceControls()
                    self.installPaintBucketPointer()
                    self.showMessagePane()
                    self.ApplyCloseMgr.ApplyButton.Enabled = false;
                case AppMode.FloodFillDone
                    self.removePaintBucketPointer()
                    self.hideMessagePane()
                case AppMode.FloodFillSelection
                    self.enableToleranceControls()
                    self.hideMessagePane()
                    self.ApplyCloseMgr.ApplyButton.Enabled = true;
                case {AppMode.NoImageLoaded}
                    self.disableAllButtons()
                case {AppMode.ImageLoaded}
                    self.enableAllButtons()
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
                case {AppMode.ThresholdImage,...
                      AppMode.ActiveContoursIterationsDone,AppMode.Drawing,...
                      AppMode.ActiveContoursRunning,AppMode.DrawingDone,...
                      AppMode.ActiveContoursDone,AppMode.ThresholdDone,...
                      AppMode.MorphologyDone,AppMode.HistoryIsEmpty,...
                      AppMode.HistoryIsNotEmpty,AppMode.MorphImage,...
                      AppMode.MorphTabOpened,AppMode.ActiveContoursTabOpened,...
                      AppMode.ActiveContoursNoMask,AppMode.GraphCutOpened,...
                      AppMode.GraphCutDone,AppMode.FindCirclesOpened,...
                      AppMode.FindCirclesDone,AppMode.GrabCutOpened,...
                      AppMode.GrabCutDone}
                    %No-op
                case AppMode.OpacityChanged
                    self.reactToOpacityChange()
                case AppMode.ShowBinary
                    self.reactToShowBinary()
                case AppMode.UnshowBinary
                    self.reactToUnshowBinary()
                case AppMode.ToggleTexture
                    self.TextureMgr.updateTextureState(self.hApp.Session.UseTexture);
                otherwise
                    assert(false,'Unrecognized mode')
            end
            
        end
        
        function onApply(self)

            import iptui.internal.segmenter.getMessageString;
            
            [mask, command] = self.computeFloodFillMask();
            newMask = self.LastCommittedMask | mask;
            
            self.LocationOfLastFillClick = [];
            self.unselectPanZoomTools()
            
            % Disable Apply button and tolerance controls
            self.ApplyCloseMgr.ApplyButton.Enabled = false;
            self.disableToleranceControls()
            if self.hApp.Session.UseTexture
                self.hApp.addToHistory(newMask, getMessageString('floodFillTextureComment'), command)
            else
                self.hApp.addToHistory(newMask, getMessageString('floodFillComment'), command)
            end
        end
        
        function onClose(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.hApp.clearTemporaryHistory()
            
            self.unselectPanZoomTools()
            
            % This ensures that zoom tools have settled down before the
            % paint bucket pointer is removed.
            drawnow;
            
            self.hToolstrip.showSegmentTab()
            self.hToolstrip.hideFloodFillTab()
            self.hToolstrip.setMode(AppMode.FloodFillDone);
            
            self.LocationOfLastFillClick = [];
        end
    end
    
    %%Layout
    methods (Access = private)
        function layoutTab(self)
            
            import iptui.internal.segmenter.*;
            
            self.FloodFillSection   = self.hTab.addSection(getMessageString('floodFillTab'));
            self.FloodFillSection.Tag = 'FloodFill';
            self.TextureSection     = self.addTextureSection();
            self.PanZoomSection     = self.addPanZoomSection();
            self.ViewSection        = self.addViewSection();
            self.ApplyCloseSection  = self.addApplyCloseSection();
            
            self.layoutFloodFillSection();
        end
        
        function layoutFloodFillSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            %Distance Metric Label
            self.DistanceMetricLabel = matlab.ui.internal.toolstrip.Label(getMessageString('distanceMetric'));
            self.DistanceMetricLabel.Description = getMessageString('distanceMetricTooltip');
            
            %Tolerance Label
            self.ToleranceLabel      = matlab.ui.internal.toolstrip.Label(getMessageString('tolerance'));
            self.ToleranceLabel.Description = getMessageString('toleranceSliderTooltip');
            
            %Distance Metric Button
            self.DistanceMetricButton = matlab.ui.internal.toolstrip.DropDownButton(getMessageString('euclidean'));
            self.DistanceMetricButton.Tag = 'btnDistanceMetric';
            self.DistanceMetricButton.Description = getMessageString('distanceMetricTooltip');
            
            %Distance Metric Dropdown
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getMessageString('euclidean'));
            sub_item1.Description = getMessageString('euclideanDescription');
            addlistener(sub_item1, 'ItemPushed', @(~,~) self.setEuclideanDistanceMetric());
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getMessageString('geodesic'));
            sub_item2.Description = getMessageString('geodesicDescription');
            addlistener(sub_item2, 'ItemPushed', @(~,~) self.setGeodesicDistanceMetric());
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            
            self.DistanceMetricButton.Popup = sub_popup;
            self.DistanceMetricButton.Popup.Tag = 'popupDistanceMetricList';
            
            %Tolerance Slider
            self.ToleranceSlider = matlab.ui.internal.toolstrip.Slider([0,100],5);
            self.ToleranceSlider.Tag = 'ToleranceSlider';
            self.ToleranceSlider.Description = getMessageString('toleranceSliderTooltip');
            self.ToleranceSliderListener = addlistener(self.ToleranceSlider, 'ValueChanged', @(src,~)self.updateTolerance(src));
            
            %Tolerance Text Field
            placeHolderLabel = matlab.ui.internal.toolstrip.Label('');
            self.ToleranceText = matlab.ui.internal.toolstrip.EditField(num2str(self.ToleranceSlider.Value));
            self.ToleranceText.Tag = 'ToleranceEdit';
            self.ToleranceText.Description = getMessageString('toleranceTextTooltip');
            self.ToleranceTextListener = addlistener(self.ToleranceText, 'ValueChanged', @(src,~)self.updateTolerance(src));
 
            %Layout
            c = self.FloodFillSection.addColumn();
            c.add(self.DistanceMetricLabel);
            c.add(self.ToleranceLabel);
            c2 = self.FloodFillSection.addColumn('width',90,...
                'HorizontalAlignment','center');
            c2.add(self.DistanceMetricButton);
            c2.add(self.ToleranceSlider);
            c3 = self.FloodFillSection.addColumn('width',40,...
                'HorizontalAlignment','center');
            c3.add(placeHolderLabel);
            c3.add(self.ToleranceText);
        end
        
        function section = addPanZoomSection(self)
            
            self.PanZoomMgr = iptui.internal.PanZoomManager(self.hTab,self.hApp);
            section = self.PanZoomMgr.Section;
            
            addlistener(self.PanZoomMgr.ZoomInButton,'ValueChanged',@(hobj,evt)self.updateFloodFillInteraction());
            addlistener(self.PanZoomMgr.ZoomOutButton,'ValueChanged',@(hobj,evt)self.updateFloodFillInteraction());
            addlistener(self.PanZoomMgr.PanButton,'ValueChanged',@(hobj,evt)self.updateFloodFillInteraction());
        end
        
        function section = addTextureSection(self)
            self.TextureMgr = iptui.internal.segmenter.TextureManager(self.hTab,self.hApp,self.hToolstrip);
            section = self.TextureMgr.Section;
            addlistener(self.TextureMgr, 'TextureButtonClicked', @(~,~) self.updateMask());
        end
        
        function section = addViewSection(self)
            
            self.ViewMgr = iptui.internal.segmenter.ViewControlsManager(self.hTab);
            section = self.ViewMgr.Section;
            
            self.OpacitySliderListener = addlistener(...
                self.ViewMgr.OpacitySlider,'ValueChanged',@(~,~)self.opacitySliderMoved());
            self.ShowBinaryButtonListener = addlistener(...
                self.ViewMgr.ShowBinaryButton,'ValueChanged',@(hobj,~)self.showBinaryPress(hobj));
            
        end
        
        function section = addApplyCloseSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            tabName = getMessageString('floodFillTab');
            
            self.ApplyCloseMgr = iptui.internal.ApplyCloseManager(self.hTab, tabName);
            section = self.ApplyCloseMgr.Section;
            
            addlistener(self.ApplyCloseMgr.ApplyButton,'ButtonPushed',@(~,~)self.onApply());
            addlistener(self.ApplyCloseMgr.CloseButton,'ButtonPushed',@(~,~)self.onClose());
        end
    end
    
    %%Callbacks
    methods (Access = private)
        function setEuclideanDistanceMetric(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            self.DistanceMetricButton.Text = getMessageString('euclidean');
            self.updateMask()
        end
        
        function setGeodesicDistanceMetric(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.unselectPanZoomTools()
            self.DistanceMetricButton.Text = getMessageString('geodesic');
            self.updateMask()
        end
        
        function updateTolerance(self, updatedControl)
            
            self.manageToleranceControlSync(updatedControl)
            self.unselectPanZoomTools()
            self.updateMask()
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
        
        function respondToPaintBucketClick(self,src)
            
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            if ~strcmp(src.SelectionType, 'normal')
                return;
            end
            
            clickLocation = src.CurrentPoint;
            axesPosition  = src.CurrentAxes.Position;
            if (isClickOutsideAxes(clickLocation, axesPosition))
                return;
            end
            
            self.hApp.clearTemporaryHistory()
            self.LastCommittedMask = self.hApp.getCurrentMask();
            
            self.hToolstrip.setMode(AppMode.FloodFillSelection);
            
            self.MaskFromClick = self.findMaskFromClick();
            
            newMask = self.MaskFromClick;
            self.hApp.setTemporaryHistory(newMask, ...
                iptui.internal.segmenter.getMessageString('floodFillComment'), ...
                '*** This will get filled at commit.')
        end
    end
    
    %%Helpers
    methods (Access = private)
        function manageToleranceControlSync(self, controlToMatch)
            
            if self.hApp.Session.UseTexture
                im = self.hApp.Session.getTextureFeatures();
            else
                im = self.hApp.getImage();
            end
            isFloat = isfloat(im);
            
            % If slider was moved, update text.
            if isa(controlToMatch, 'matlab.ui.internal.toolstrip.Slider')
                if isFloat
                    self.ToleranceText.Value = num2str(controlToMatch.Value / 100);
                else
                    self.ToleranceText.Value = num2str(controlToMatch.Value);
                end
            
            % If text was edited, update slider
            elseif isa(controlToMatch, 'matlab.ui.internal.toolstrip.EditField')
                value = str2double(controlToMatch.Value);
                if isnan(value) || ~isreal(value)
                    sliderValue = self.ToleranceSlider.Value;
                    if isFloat
                        sliderValue = sliderValue / 100;
                    end
                    self.ToleranceText.Value = num2str(sliderValue);
                    return;
                end
                
                if isFloat
                    minValue = self.ToleranceSlider.Limits(1) / 100;
                    maxValue = self.ToleranceSlider.Limits(2) / 100;
                else
                    minValue = self.ToleranceSlider.Limits(1);
                    maxValue = self.ToleranceSlider.Limits(2);
                end
                
                % Valid value - continue.
                if value < minValue
                    value = minValue;
                elseif value > maxValue
                    value = maxValue;
                end
                
                self.ToleranceText.Value = num2str(value);
                if isFloat
                    self.ToleranceSlider.Value = value * 100;
                else
                    self.ToleranceSlider.Value = value;
                end
                
            end
            
        end
        
        function updateToleranceSliderLimits(self)
            
            if self.hApp.Session.UseTexture
                im = self.hApp.Session.getTextureFeatures();
            else
                im = self.hApp.getImage();
            end
            isFloat = isfloat(im);
            limits = getrangefromclass(im);
            
            % Disable listener for tolerance slider when limits are
            % updated.
            self.ToleranceSliderListener.Enabled = false;
            self.ToleranceTextListener.Enabled   = false;
            drawnow;
            
            min = 0;
            
            if isFloat
                max = double(abs( diff(limits) )) * 100;
            else
                max = double(abs( diff(limits) ));
            end
            
            self.ToleranceSlider.Limits = [min max];
            self.ToleranceSlider.Value   = 0.05 * max;
            
            if isFloat
                valString = num2str( self.ToleranceSlider.Value / 100 );
            else
                valString = num2str(self.ToleranceSlider.Value);
            end
            self.ToleranceText.Value = valString;
            
            % Enable listener for tolerance slider when finished.
            self.ToleranceSliderListener.Enabled = true;
            self.ToleranceTextListener.Enabled   = true;
        end
        
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
        
        function updateFloodFillInteraction(self)
            
            % If one of the zoom/pan buttons is selected, disable the
            % floodfill draw interaction. If it is unselected, enable the
            % floodfill draw interaction.
            if self.PanZoomMgr.ZoomInButton.Value || self.PanZoomMgr.ZoomOutButton.Value || self.PanZoomMgr.PanButton.Value
                self.removePaintBucketPointer()
            else
                self.installPaintBucketPointer()
            end
        end
        
        function unselectPanZoomTools(self)
            self.PanZoomMgr.unselectAll();    
        end
        
        function TF = isVisible(self)
            existingTabs = self.hToolGroup.TabNames;
            TF = any(strcmp(existingTabs, self.hApp));
        end
        
        function installPaintBucketPointer(self)
            
            hAx  = self.hApp.getScrollPanelAxes();
            hFig = self.hApp.getScrollPanelFigure();
            
            % Setup pointer manager for the figure
            iptPointerManager(hFig);
            
            % Cache original pointer behavior
            self.OriginalPointerBehavior = iptGetPointerBehavior(hAx);
            
            % Install new pointer behavior
            iptSetPointerBehavior(hAx,@setPointerToPaintBucket);
            
            % Add listener to button up
            hFig.WindowButtonDownFcn = @(src,~)self.respondToPaintBucketClick(src);
            
            function setPointerToPaintBucket(h,~)
                h.Pointer = 'custom';
                if isempty(self.PaintBucket)
                    self.loadPaintBucketPointerImage();
                end
                h.PointerShapeCData = self.PaintBucket;
                h.PointerShapeHotSpot = [16,16];
            end
            
        end
        
        function loadPaintBucketPointerImage(self)
            
            self.PaintBucket = [NaN   NaN   NaN   NaN   NaN     1     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
                                NaN   NaN   NaN   NaN     1   NaN   NaN   NaN     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN
                                NaN   NaN   NaN   NaN     1   NaN   NaN     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN
                                NaN   NaN   NaN   NaN     1   NaN     1     2     1     1   NaN   NaN   NaN   NaN   NaN   NaN
                                NaN   NaN   NaN   NaN     1     1     2     2     1     2     1     1   NaN   NaN   NaN   NaN
                                NaN   NaN   NaN   NaN     1     2     2     2     1     2     2     1     1     1   NaN   NaN
                                NaN   NaN   NaN     1     2     2     2     1     2     1     2     2     1     1     1   NaN
                                NaN   NaN     1     2     2     2     2     2     1     2     2     2     2     1     1     1
                                NaN     1     2     2     2     2     2     2     2     2     2     2     1     1     1     1
                                  1     2     2     2     2     2     2     2     2     2     2     1   NaN     1     1     1
                                NaN     1     2     2     2     2     2     2     2     2     1   NaN   NaN     1     1     1
                                NaN   NaN     1     2     2     2     2     2     2     1   NaN   NaN   NaN     1     1     1
                                NaN   NaN   NaN     1     2     2     2     2     1   NaN   NaN   NaN   NaN     1     1     1
                                NaN   NaN   NaN   NaN     1     2     2     1   NaN   NaN   NaN   NaN   NaN     1     1   NaN
                                NaN   NaN   NaN   NaN   NaN     1     1   NaN   NaN   NaN   NaN   NaN   NaN     1   NaN   NaN
                                NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN];

        end
        
        function mask = findMaskFromClick(self)
            
            % We use the CurrentPoint property of the axes and not the
            % figure so that we can use the location as indices for
            % grayconnected (in image co-ordinates).
            hAx = self.hApp.getScrollPanelAxes;
            point = round(hAx.CurrentPoint);
            self.LocationOfLastFillClick = point;
            
            mask = self.computeFloodFillMask();
        end
        
        function [mask, command] = computeFloodFillMask(self)
            
            import iptui.internal.segmenter.getMessageString;

            if self.hApp.Session.UseTexture
                im = self.hApp.Session.getTextureFeatures();
            else
                im = self.hApp.getImage();
            end
            
            point = self.LocationOfLastFillClick;
            
            if isempty(point)
                mask = false(size(im));
                return;
            end
            
            % Bound row and column indices to lie in image size range.
            row = max(min(point(1,2),size(im,1)),1);
            col = max(min(point(1,1),size(im,2)),1);
            
            tol = self.ToleranceSlider.Value;
            
            if self.hApp.Session.WasRGB || self.hApp.Session.UseTexture
                im = sum((im - im(row,col,:)).^2,3);
                im = mat2gray(im);
            end
            
            if isfloat(im)
                tol = tol/100;
            end
            
            switch self.DistanceMetricButton.Text
                case getMessageString('euclidean')
                    mask = grayconnected(im, row, col, tol);
                    command{1} = sprintf('row = %d;', row);
                    command{2} = sprintf('column = %d;', col);
                    command{3} = sprintf('tolerance = %d;', tol);
                    if self.hApp.Session.UseTexture
                        command{4} = sprintf('normGaborX = sum((gaborX - gaborX(row,column,:)).^2,3);');
                        command{5} = sprintf('normGaborX = mat2gray(normGaborX);');
                        command{6} = 'addedRegion = grayconnected(normGaborX, row, column, tolerance);';
                        command{7} = 'BW = BW | addedRegion;';
                    elseif self.hApp.Session.WasRGB
                        command{4} = sprintf('normX = sum((X - X(row,column,:)).^2,3);');
                        command{5} = sprintf('normX = mat2gray(normX);');
                        command{6} = 'addedRegion = grayconnected(normX, row, column, tolerance);';
                        command{7} = 'BW = BW | addedRegion;';
                    else
                        command{4} = 'addedRegion = grayconnected(X, row, column, tolerance);';
                        command{5} = 'BW = BW | addedRegion;';
                    end
                    
                case getMessageString('geodesic')
                    weightImage = graydiffweight(im, col, row, 'GrayDifferenceCutoff',tol);
                    mask = imsegfmm(weightImage, col, row, 0.01);
                    
                    command{1} = sprintf('row = %d;', row);
                    command{2} = sprintf('column = %d;', col);
                    command{3} = sprintf('tolerance = %d;', tol);
                    if self.hApp.Session.UseTexture
                        command{4} = sprintf('normGaborX = sum((gaborX - gaborX(row,column,:)).^2,3);');
                        command{5} = sprintf('normGaborX = mat2gray(normGaborX);');
                        command{6} = 'weightImage = graydiffweight(normGaborX, column, row, ''GrayDifferenceCutoff'', tolerance);';
                        command{7} = 'addedRegion = imsegfmm(weightImage, column, row, 0.01);';
                        command{8} = 'BW = BW | addedRegion;';
                    elseif self.hApp.Session.WasRGB
                        command{4} = sprintf('normX = sum((X - X(row,column,:)).^2,3);');
                        command{5} = sprintf('normX = mat2gray(normX);');
                        command{6} = 'weightImage = graydiffweight(normX, column, row, ''GrayDifferenceCutoff'', tolerance);';
                        command{7} = 'addedRegion = imsegfmm(weightImage, column, row, 0.01);';
                        command{8} = 'BW = BW | addedRegion;';
                    else
                        command{4} = 'weightImage = graydiffweight(X, column, row, ''GrayDifferenceCutoff'', tolerance);';
                        command{5} = 'addedRegion = imsegfmm(weightImage, column, row, 0.01);';
                        command{6} = 'BW = BW | addedRegion;';
                    end
                    
                otherwise
                    assert(true,'incorrect floodfill method')
            end
        end
        
        function updateMask(self)
            
            if ~isempty(self.LocationOfLastFillClick)
                newMask = self.findMaskFromClick();
                self.hApp.setCurrentMask(newMask)
            end
        end
        
        function removePaintBucketPointer(self)
        
            hAx = self.hApp.getScrollPanelAxes();
            iptSetPointerBehavior(hAx,self.OriginalPointerBehavior);
            
            hFig = self.hApp.getScrollPanelFigure();
            
            % Reset button up function to default.
            hFig.WindowButtonDownFcn = '';
        end
        
        function showMessagePane(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            message = getMessageString('seedFloodFill');
            fontName = get(0,'DefaultTextFontName');
            fontSize = 12;
            txtPane = ctrluis.PopupPanel.createMessageTextPane(message,fontName,fontSize);
            self.hApp.MessagePane.setPanel(txtPane);
            
            self.hApp.MessagePane.showPanel();
            self.hApp.MessagePane.setVisible(true);
        end
        
        function hideMessagePane(self)
            
            if ~isempty(self.hApp.MessagePane) && isvalid(self.hApp.MessagePane)
                self.hApp.MessagePane.setVisible(false);
            end
        end
        
        function disableToleranceControls(self)
            self.DistanceMetricLabel.Enabled            = false;
            self.DistanceMetricButton.Enabled           = false;
            self.ToleranceLabel.Enabled                 = false;
            self.ToleranceSlider.Enabled                = false;
            self.ToleranceText.Enabled                  = false;
        end
        
        function enableToleranceControls(self)
            self.DistanceMetricLabel.Enabled            = true;
            self.DistanceMetricButton.Enabled           = true;
            self.ToleranceLabel.Enabled                 = true;
            self.ToleranceSlider.Enabled                = true;
            self.ToleranceText.Enabled                  = true;
        end
        
        function disableAllButtons(self)
            self.DistanceMetricLabel.Enabled            = false;
            self.DistanceMetricButton.Enabled           = false;
            self.ToleranceLabel.Enabled                 = false;
            self.ToleranceSlider.Enabled                = false;
            self.ToleranceText.Enabled                  = false;
            self.PanZoomMgr.Enabled                     = false;
            self.TextureMgr.Enabled                     = false;
            self.ViewMgr.Enabled                        = false;
            self.ApplyCloseMgr.ApplyButton.Enabled      = false;
            self.ApplyCloseMgr.ApplyButton.Enabled      = false;
        end
        
        function enableAllButtons(self)
            self.DistanceMetricLabel.Enabled            = true;
            self.DistanceMetricButton.Enabled           = true;
            self.ToleranceLabel.Enabled                 = true;
            self.ToleranceSlider.Enabled                = true;
            self.ToleranceText.Enabled                  = true;
            self.PanZoomMgr.Enabled                     = true;
            self.TextureMgr.Enabled                     = true;
            self.ViewMgr.Enabled                        = true;
            self.ApplyCloseMgr.ApplyButton.Enabled      = true;
            self.ApplyCloseMgr.ApplyButton.Enabled      = true;
        end
    end
end

function TF = isClickOutsideAxes(clickLocation, axesPosition)
TF = (clickLocation(1) < axesPosition(1)) || ...
     (clickLocation(1) > (axesPosition(1) + axesPosition(3))) || ...
     (clickLocation(2) < axesPosition(2)) || ...
     (clickLocation(2) > (axesPosition(2)+axesPosition(4)));
end