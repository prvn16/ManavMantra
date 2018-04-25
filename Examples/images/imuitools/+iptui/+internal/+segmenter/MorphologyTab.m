classdef MorphologyTab < handle
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    %%Public
    properties (GetAccess = public, SetAccess = private)
        Visible = false;
    end
    
    %%Tab Management
    properties (Access = private)
        hTab
        hApp
        hToolGroup
        hTabGroup
        hToolstrip
    end
    
    %%UI Controls
    properties
        OperationSection
        OperationButton
        
        StrelSection
        ShapeButton
        RadiusLabel
        RadiusSpinner
        LengthLabel
        LengthSpinner
        DegreesLabel
        DegreesSpinner
        NLabel
        NComboBox
        WidthLabel
        WidthSpinner
        
        PanZoomSection
        PanZoomMgr
        
        ViewSection
        ViewMgr
        
        ApplyCloseSection
        ApplyCloseMgr
        
        OpacitySliderListener
        ShowBinaryButtonListener
    end
    
    %%Algorithm
    properties
        NoOperationSelected
        OperationList = {'dilate','erode','open','close'};
        ShapeList = {'disk','diamond','line','octagon','square','rectangle'};
        StrelCreationCommand
    end
    
    %%Public API
    methods
        function self = MorphologyTab(toolGroup, tabGroup, theToolstrip, theApp, varargin)

            if (nargin == 1)
                self.hTab = iptui.internal.segmenter.createTab(tabGroup,'morphologyTab');
            else
                self.hTab = iptui.internal.segmenter.createTab(tabGroup,'morphologyTab', varargin{:});
            end

            self.hToolGroup = toolGroup;
            self.hTabGroup = tabGroup;
            self.hToolstrip = theToolstrip;
            self.hApp = theApp;
            
            self.layoutTab();
        end
        
        function show(self)
            if (~self.isVisible())
                self.hTabGroup.add(self.hTab)
            end
            
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
            case {AppMode.Drawing, AppMode.ActiveContoursRunning,...
                  AppMode.FloodFillSelection, AppMode.DrawingDone,...
                  AppMode.ActiveContoursDone, AppMode.FloodFillDone,...
                  AppMode.HistoryIsEmpty, AppMode.HistoryIsNotEmpty,...
                  AppMode.ThresholdDone, AppMode.MorphologyDone,...
                  AppMode.ActiveContoursIterationsDone,...
                  AppMode.ImageLoaded, AppMode.ThresholdImage,...
                  AppMode.ActiveContoursTabOpened,AppMode.ToggleTexture}
                %No-op
                
            case {AppMode.NoMasks, ...
                  AppMode.NoImageLoaded, ...
                  AppMode.ActiveContoursNoMask}
                %If the app enters a state with no mask, make sure we set
                %the state back to unshow binary.
                if self.ViewMgr.ShowBinaryButton.Enabled
                    self.reactToUnshowBinary();
                    % This is needed to ensure that state is settled after
                    % unshow binary.
                    drawnow;
                end
                self.ViewMgr.Enabled = false;
                self.OperationButton.Enabled = false;
                self.disableStrelSection()
                
            case AppMode.MasksExist
                self.OperationButton.Enabled = true;
                self.enableStrelSection()
                self.ViewMgr.Enabled = true;
                
            case AppMode.MorphTabOpened
                self.restoreDefaults()
                self.ApplyCloseMgr.ApplyButton.Enabled = false;
                
            case AppMode.OpacityChanged
                self.reactToOpacityChange()
                
            case AppMode.ShowBinary
                self.reactToShowBinary()
                
            case AppMode.UnshowBinary
                self.reactToUnshowBinary()
                
            case AppMode.MorphImage
                self.applyMorphologicalOperation()
            end
        end
        
        function onApply(self)
            self.hApp.commitTemporaryHistory()

            self.unselectPanZoomTools()
            
            self.ApplyCloseMgr.ApplyButton.Enabled = false;
            
            if (maskHasRegions(self.hApp.getCurrentMask() ))
                self.hToolstrip.setMode(iptui.internal.segmenter.AppMode.MasksExist)
            else
                self.hToolstrip.setMode(iptui.internal.segmenter.AppMode.NoMasks)
            end
        end
        
        function onClose(self)
            
            import iptui.internal.segmenter.AppMode;
            
            self.hApp.clearTemporaryHistory()
            
            self.unselectPanZoomTools()
            
            self.hToolstrip.showSegmentTab()
            self.hToolstrip.hideMorphologyTab()
            self.hToolstrip.setMode(AppMode.MorphologyDone);
        end
    end
    
    %%Layout
    methods (Access = private)
        function layoutTab(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            self.OperationSection   = self.hTab.addSection(getMessageString('operation'));
            self.OperationSection.Tag = 'Operation';
            self.StrelSection       = self.hTab.addSection(getMessageString('strel'));
            self.StrelSection.Tag   = 'StructuringElement';
            self.PanZoomSection     = self.addPanZoomSection();
            self.ViewSection        = self.addViewSection();
            self.ApplyCloseSection  = self.addApplyCloseSection();
            
            self.layoutOperationSection();
            self.layoutStrelSection();
        end
        
        function layoutOperationSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            %Operation Label
            OperationLabel = matlab.ui.internal.toolstrip.Label(getMessageString('operation'));
            OperationLabel.Description = getMessageString('operationTooltip');
            
            %Operation Button
            self.OperationButton = matlab.ui.internal.toolstrip.DropDownButton(getMessageString('selectOp'));
            self.OperationButton.Tag = 'btnOp';
            self.OperationButton.Description = getMessageString('operationTooltip');
            
            %Operation Dropdown
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            sub_item1 = matlab.ui.internal.toolstrip.ListItem(getMessageString(sprintf('%sOp',self.OperationList{1})));
            sub_item1.Description = getMessageString(sprintf('%sDescription',self.OperationList{1}));
            sub_item1.Tag = self.OperationList{1};
            addlistener(sub_item1, 'ItemPushed', @self.updateOperationSelection);
            
            sub_item2 = matlab.ui.internal.toolstrip.ListItem(getMessageString(sprintf('%sOp',self.OperationList{2})));
            sub_item2.Description = getMessageString(sprintf('%sDescription',self.OperationList{2}));
            sub_item2.Tag = self.OperationList{2};
            addlistener(sub_item2, 'ItemPushed', @self.updateOperationSelection);
            
            sub_item3 = matlab.ui.internal.toolstrip.ListItem(getMessageString(sprintf('%sOp',self.OperationList{3})));
            sub_item3.Description = getMessageString(sprintf('%sDescription',self.OperationList{3}));
            sub_item3.Tag = self.OperationList{3};
            addlistener(sub_item3, 'ItemPushed', @self.updateOperationSelection);
            
            sub_item4 = matlab.ui.internal.toolstrip.ListItem(getMessageString(sprintf('%sOp',self.OperationList{4})));
            sub_item4.Description = getMessageString(sprintf('%sDescription',self.OperationList{4}));
            sub_item4.Tag = self.OperationList{4};
            addlistener(sub_item4, 'ItemPushed', @self.updateOperationSelection);
            
            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            sub_popup.add(sub_item3);
            sub_popup.add(sub_item4);
            
            self.OperationButton.Popup = sub_popup;
            self.OperationButton.Popup.Tag = 'popupOperationList';
            
            %Layout
            c = self.OperationSection.addColumn('width',100,...
                'HorizontalAlignment','center');
            c.add(OperationLabel);
            c.add(self.OperationButton);
        end
        
        function layoutStrelSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            import images.internal.app.Icon;
            
            %Shape Button
            shapeMessageList = cellfun(@getMessageString,self.ShapeList,'UniformOutput',false);
            shapeDescList = cellfun(@(s)getMessageString(sprintf('%sDescription',s)),self.ShapeList,'UniformOutput',false);
            shapeIconList = cellfun(@(s)str2func(strcat('images.internal.app.Icon.STREL',upper(s),'_24')),self.ShapeList,'UniformOutput',false);

            self.ShapeButton = matlab.ui.internal.toolstrip.DropDownButton(sprintf('%s -\n%s', getMessageString('shape'), getMessageString('disk')));
            self.ShapeButton.Icon = Icon.STRELDISK_24;
            self.ShapeButton.Tag = self.ShapeList{1};
            self.ShapeButton.Description = getMessageString('shapeTooltip');
            
            %Operation Dropdown
            sub_popup = matlab.ui.internal.toolstrip.PopupList();
            
            for idx = 1:length(self.ShapeList)
                sub_item = matlab.ui.internal.toolstrip.ListItem(shapeMessageList{idx});
                sub_item.Tag = self.ShapeList{idx};
                iconfunc = shapeIconList{idx};
                sub_item.Icon = iconfunc();
                sub_item.Description = shapeDescList{idx};
                addlistener(sub_item, 'ItemPushed', @self.updateShapeSelection);
                sub_popup.add(sub_item);
            end
            
            self.ShapeButton.Popup = sub_popup;
            self.ShapeButton.Popup.Tag = 'popupShapeList';
            
            %Radius Label
            self.RadiusLabel    = matlab.ui.internal.toolstrip.Label(getMessageString('radius'));
            self.RadiusLabel.Description = getMessageString('radTooltip');
            
            %Length Label
            self.LengthLabel    = matlab.ui.internal.toolstrip.Label(getMessageString('length'));
            self.LengthLabel.Description = getMessageString('lengthTooltip');
            
            %Degrees Label
            self.DegreesLabel   = matlab.ui.internal.toolstrip.Label(getMessageString('degrees'));
            self.DegreesLabel.Description = getMessageString('degreesTooltip');
            
            %N Label
            self.NLabel         = matlab.ui.internal.toolstrip.Label(getMessageString('N'));
            self.NLabel.Description = getMessageString('nTooltip');
            
            %Width Label
            self.WidthLabel     = matlab.ui.internal.toolstrip.Label(getMessageString('width'));
            self.WidthLabel.Description = getMessageString('widthTooltip');
            
            %Radius Spinner
            self.RadiusSpinner = matlab.ui.internal.toolstrip.Spinner([0,65535],3);
            self.RadiusSpinner.Tag = 'spinnerRadius';
            self.RadiusSpinner.Description = getMessageString('radTooltip');
            addlistener(self.RadiusSpinner,'ValueChanged',@(~,~)self.radiusChanged);
            
            %Length Spinner
            self.LengthSpinner = matlab.ui.internal.toolstrip.Spinner([0,65535],3);
            self.LengthSpinner.Tag = 'spinnerLength';
            self.LengthSpinner.Description = getMessageString('lengthTooltip');
            addlistener(self.LengthSpinner,'ValueChanged',@(~,~)self.lengthChanged);
            
            %Degrees Spinner
            self.DegreesSpinner = matlab.ui.internal.toolstrip.Spinner([0,180],0);
            self.DegreesSpinner.Tag = 'spinnerDegrees';
            self.DegreesSpinner.Description = getMessageString('degreesTooltip');
            addlistener(self.DegreesSpinner,'ValueChanged',@(~,~)self.degreesChanged);
            
            %N Combo Box
            self.NComboBox = matlab.ui.internal.toolstrip.DropDown({'0';'4';'6';'8'});
            self.NComboBox.SelectedIndex = 1;
            self.NComboBox.Tag = 'comboN';
            self.NComboBox.Description = getMessageString('nTooltip');
            addlistener(self.NComboBox,'ValueChanged',@(~,~)self.nChanged);
            
            %Width Spinner
            self.WidthSpinner = matlab.ui.internal.toolstrip.Spinner([0,65535],3);
            self.WidthSpinner.Tag = 'spinnerWidth';
            self.WidthSpinner.Description = getMessageString('widthTooltip');
            addlistener(self.WidthSpinner,'ValueChanged',@(~,~)self.widthChanged);

            %Layout
            c = self.StrelSection.addColumn('width',60);
            c.add(self.ShapeButton);
            c2 = self.StrelSection.addColumn(...
                'HorizontalAlignment','right');
            c2.add(self.RadiusLabel);
            c2.add(self.LengthLabel);
            c2.add(self.DegreesLabel);
            c3 = self.StrelSection.addColumn('width',40);
            c3.add(self.RadiusSpinner);
            c3.add(self.LengthSpinner);
            c3.add(self.DegreesSpinner);
            c4 = self.StrelSection.addColumn(...
                'HorizontalAlignment','right');
            c4.add(self.NLabel);
            c4.add(self.WidthLabel);
            c5 = self.StrelSection.addColumn('width',40);
            c5.add(self.NComboBox);
            c5.add(self.WidthSpinner);
            
        end
        
        function section = addPanZoomSection(self)
            
            self.PanZoomMgr = iptui.internal.PanZoomManager(self.hTab,self.hApp);
            section = self.PanZoomMgr.Section;
            
            self.PanZoomMgr.Enabled = true;
            
        end
        
        function section = addViewSection(self)
            
            self.ViewMgr = iptui.internal.segmenter.ViewControlsManager(self.hTab);
            section = self.ViewMgr.Section;
            
            self.OpacitySliderListener = addlistener(self.ViewMgr.OpacitySlider, 'ValueChanged', @(~,~)self.opacitySliderMoved());
            self.ShowBinaryButtonListener = addlistener(self.ViewMgr.ShowBinaryButton, 'ValueChanged', @(hobj,~)self.showBinaryPress(hobj));
        end
        
        function section = addApplyCloseSection(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            tabName = getMessageString('morphologyTab');
            
            self.ApplyCloseMgr = iptui.internal.ApplyCloseManager(self.hTab, tabName);
            section = self.ApplyCloseMgr.Section;
            
            addlistener(self.ApplyCloseMgr.ApplyButton,'ButtonPushed',@(~,~)self.onApply());
            addlistener(self.ApplyCloseMgr.CloseButton,'ButtonPushed',@(~,~)self.onClose());
        end
    end
    
    %%Callbacks
    methods (Access = private)
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
        
        function updateOperationSelection(self,src,~)
            
            import iptui.internal.segmenter.getMessageString;
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            self.OperationButton.Text = src.Tag;
            self.OperationButton.Tag = src.Tag;
            
            self.NoOperationSelected = false;
            
            self.hToolstrip.setMode(AppMode.MorphImage);
        end
        
        function updateShapeSelection(self,src,~)
            
            import iptui.internal.segmenter.getMessageString;
            import iptui.internal.segmenter.AppMode;
            
            self.unselectPanZoomTools()
            
            shape = src.Tag;
            self.ShapeButton.Tag = shape;
            self.ShapeButton.Text = getMessageString(shape);
            iconFunc = str2func(sprintf('images.internal.app.Icon.STREL%s_24',upper(shape)));
            self.ShapeButton.Icon = iconFunc();
            self.updateStrelPropertyPanel()
            self.hToolstrip.setMode(AppMode.MorphImage);
        end
        
        function radiusChanged(self)
            
            import iptui.internal.segmenter.AppMode;
            self.unselectPanZoomTools()
            
            % Update radius to integer-valued number if needed.
            val = self.RadiusSpinner.Value;
            if val ~= round(val)
                self.RadiusSpinner.Value = round(val);
                val = round(val);
            end
            
            % Update radius to a multiple of 3 if needed. (Octagon)
            if self.RadiusSpinner.StepSize == 3
                if mod(val,3) ~= 0
                    self.RadiusSpinner.Value = val + (3 - mod(val,3));
                end
            end
            
            self.hToolstrip.setMode(AppMode.MorphImage);
        end
        
        function lengthChanged(self)
            
            import iptui.internal.segmenter.AppMode;
            self.unselectPanZoomTools()
            
            val = self.LengthSpinner.Value;
            if val~=round(val)
                self.LengthSpinner.Value = round(val);
            end
            self.hToolstrip.setMode(AppMode.MorphImage);
        end
        
        function degreesChanged(self)
            
            import iptui.internal.segmenter.AppMode;
            self.unselectPanZoomTools()
            
            val = self.DegreesSpinner.Value;
            if val~=round(val)
                self.DegreesSpinner.Value = round(val);
            end
            self.hToolstrip.setMode(AppMode.MorphImage);
        end
        
        function nChanged(self)
            
            import iptui.internal.segmenter.AppMode;
            self.unselectPanZoomTools()
            self.hToolstrip.setMode(AppMode.MorphImage);
        end
        
        function widthChanged(self)
            
            import iptui.internal.segmenter.AppMode;
            self.unselectPanZoomTools()
            
            val = self.WidthSpinner.Value;
            if val~=round(val)
                self.WidthSpinner.Value = round(val);
            end
            self.hToolstrip.setMode(AppMode.MorphImage);
        end
    end
    
    %%Helpers
    methods (Access = private)
        function restoreDefaults(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            % Reset operation selection
            self.OperationButton.Text = getMessageString('selectOp');
            self.NoOperationSelected = true;
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
        
        function unselectPanZoomTools(self)
            
            self.PanZoomMgr.unselectAll();
        end
        
        function applyMorphologicalOperation(self)
            
            import iptui.internal.segmenter.getMessageString;
            
            if self.NoOperationSelected
                return;
            end
            
            self.showAsBusy();
            
            self.hApp.clearTemporaryHistory()
            
            % Find the morphological operation to apply
            operation = self.OperationButton.Tag;
            morphOp = str2func(sprintf('im%s',operation));
            
            % Get the structuring element to use
            [se,shape] = self.getStructuringElement();
            
            % Get the mask.
            mask = self.hApp.getCurrentMask();
            
            % Apply the morphological operation
            mask = morphOp(mask,se);
            
            cmdStrel = self.StrelCreationCommand;
            cmdMorph = sprintf('BW = im%s(BW, se);', operation);
            cmd = [cmdStrel, {cmdMorph}];
            
            % Enable Apply button
            self.ApplyCloseMgr.ApplyButton.Enabled = true;
            
            resourceKey = sprintf('%sComment', operation);
            self.hApp.setTemporaryHistory(mask, getMessageString(resourceKey, shape), cmd)
            self.hApp.updateScrollPanelPreview(mask)
            
            self.unshowAsBusy();
        end
        
        function updateStrelPropertyPanel(self)

            strelShape = self.ShapeButton.Tag;
            
            self.disableAllStrelProperties();
            switch strelShape
            case 'disk'
                self.RadiusLabel.Enabled = true;
                self.RadiusSpinner.Enabled = true;
                self.RadiusSpinner.StepSize = 1;
                self.NLabel.Enabled = true;
                self.NComboBox.Enabled = true;
            case 'diamond'
                self.RadiusLabel.Enabled = true;
                self.RadiusSpinner.Enabled = true;
                self.RadiusSpinner.StepSize = 1;
            case 'line'
                self.LengthLabel.Enabled = true;
                self.LengthSpinner.Enabled = true;
                self.DegreesLabel.Enabled = true;
                self.DegreesSpinner.Enabled = true;
            case 'octagon'
                self.RadiusLabel.Enabled = true;
                self.RadiusSpinner.Enabled = true;
                self.RadiusSpinner.StepSize = 3;
                
                % Update spinner value to be a multiple of 3
                val = self.RadiusSpinner.Value;
                if mod(val,3) ~= 0
                    self.RadiusSpinner.Value = val + (3 - mod(val,3));
                end
            case 'square'
                self.LengthLabel.Enabled = true;
                self.LengthSpinner.Enabled = true;
            case 'rectangle'
                self.LengthLabel.Enabled = true;
                self.LengthSpinner.Enabled = true;
                self.WidthLabel.Enabled = true;
                self.WidthSpinner.Enabled = true;
            otherwise
                assert(false,'Incorrect structuring element shape')
            end
        end

        function disableAllStrelProperties(self)

            self.RadiusLabel.Enabled = false;
            self.RadiusSpinner.Enabled = false;
            self.LengthLabel.Enabled = false;
            self.LengthSpinner.Enabled = false;
            self.DegreesLabel.Enabled = false;
            self.DegreesSpinner.Enabled = false;
            self.NLabel.Enabled = false;
            self.NComboBox.Enabled = false;
            self.WidthLabel.Enabled = false;
            self.WidthSpinner.Enabled = false;
        end

        function [se,strelShape] = getStructuringElement(self)
            strelShape = self.ShapeButton.Tag;
            
            R       = self.RadiusSpinner.Value;
            len     = self.LengthSpinner.Value;
            deg     = self.DegreesSpinner.Value;
            N       = str2double(self.NComboBox.Value);
            W       = self.WidthSpinner.Value;
            
            switch strelShape
            case 'disk'
                se = strel('disk',R,N);
                self.StrelCreationCommand = {...
                    sprintf('radius = %d;', R), ...
                    sprintf('decomposition = %d;', N), ...
                    'se = strel(''disk'', radius, decomposition);'};
            case 'diamond'
                se = strel('diamond',R);
                self.StrelCreationCommand = {...
                    sprintf('radius = %d;', R), ...
                    'se = strel(''diamond'', radius);'};
            case 'line'
                se = strel('line',len,deg);
                self.StrelCreationCommand = {...
                    sprintf('length = %f;', len), ...
                    sprintf('angle = %f;', deg), ...
                    'se = strel(''line'', length, angle);'};
            case 'octagon'
                se = strel('octagon',R);
                self.StrelCreationCommand = {...
                    sprintf('radius = %d;', R), ...
                    'se = strel(''octagon'', radius);'};
            case 'square'
                se = strel('square',len);
                self.StrelCreationCommand = {...
                    sprintf('width = %d;', len), ...
                    'se = strel(''square'', width);'};
            case 'rectangle'
                se = strel('rectangle',[len W]);
                self.StrelCreationCommand = {...
                    sprintf('dimensions = [%d %d];', len, W), ...
                    'se = strel(''rectangle'', dimensions);'};
            otherwise
                assert(false,'Incorrect structuring element shape')
            end
                   
        end
        
        function TF = isVisible(self)
            existingTabs = self.hToolGroup.TabNames;
            TF = any(strcmp(existingTabs, self.hApp));
        end
        
        function disableStrelSection(self)
            
            self.ShapeButton.Enabled = false;
            self.disableAllStrelProperties()
        end
        
        function enableStrelSection(self)
            
            self.ShapeButton.Enabled = true;
			self.updateStrelPropertyPanel()
        end
        
        function showAsBusy(self)
            self.hToolGroup.setWaiting(true);
        end
        
        function unshowAsBusy(self)
            self.hToolGroup.setWaiting(false)
        end
    end
    
    %%Set/Get Methods
    methods
        function set.NoOperationSelected(self,TF)
            % Update view of strel section every time this flag is updated.
            
            if TF
               self.disableStrelSection()
            else
                self.enableStrelSection()
            end
            self.NoOperationSelected = TF;
        end
    end
    
end

function TF = maskHasRegions(mask)

TF = any(mask(:));

end