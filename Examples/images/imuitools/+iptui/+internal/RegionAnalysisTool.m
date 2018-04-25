classdef RegionAnalysisTool < iptui.internal.ImageApp

%   Copyright 2014-2015 The MathWorks, Inc.
    
    properties
        
        % Tabs
        AnalysisTab
        
        %imscrollpanel that contains overlay view
        hScrollpanel
        hTable
        
        % Sections: Threshold tab
        LoadImageSection
        RegionFilteringSection
        TableViewSection
        PanZoomSection
        ExportSection
        
        % Handles to buttons in toolstrip
        hLoadButton
        hExcludeBorderCheckbox
        hFillHolesCheckbox
        hFilterButton
        hSortCombo
        hSelectPropsButton
        hExportButton
        hPropertyPickerPanel
        hFilterRegionPanel
        hTableViewPanel
        
        % Handle to figures docked in toolstrip
        FigureHandles
        
        % Handle to current figure docked in toolstrip
        hFigCurrent
        
        propsUnsorted
        
        % Current binary image/mask and properties
        propsSortApplied
        maskCurrent
        
        % We cache ClientActionListener on ToolGroup so that we can
        % disable/enable it at specific times.
        ClientActionListener
        
        % Control listeners
        regionCheckboxListener
        choosePropsButtonListener
        imageLoadedListener
        filterUpdateListener
        
        % imageApp.imageData is Original mask
    end
    
    properties (SetAccess = private, SetObservable = true)
        % Version of image with imfil/imclearborder optionally applied.
        maskFilledCleared
    end
    
    
    properties (Access = private)
        
        tableSortOrder
        propLimitsCache
        hasLotsOfObjects
        
    end
    
    
    % Constructor and public methods
    methods
        
        function self = RegionAnalysisTool(varargin)
            
            % Construct common parts from base class.
            self = self@iptui.internal.ImageApp(message('images:regionAnalyzer:appName').getString());
            self.appName = 'imageRegionAnalyzer';
            
            self.imageLoader = iptui.internal.ImageLoaderBW(false);
            
            self.removeDocumentBar()
            
            % Add DDUX logging to Toolgroup
            images.internal.app.utilities.addDDUXLogging(self.hToolGroup,'Image Processing Toolbox','Image Region Analyzer');
            
            self.hToolGroup.open()
            imageslib.internal.apputil.ScreenUtilities.setInitialToolPosition(self.GroupName);
            
            % Create toolstrip components.
            self.AnalysisTab = self.hToolGroup.addTab('AnalysisTab', ...
                message('images:regionAnalyzer:analysisTabTitle').getString());
            self.hideDataBrowser()

            % Create this property cache before creating filter section.
            self.propLimitsCache = iptui.internal.PropertyLimitsCache(self);
            iptui.internal.filterTagGenerator('reset');
            
            self.LoadImageSection = self.layoutLoadImageSection(self.AnalysisTab);
            self.RegionFilteringSection = self.layoutRegionFilteringSection(self.AnalysisTab);
            self.TableViewSection = self.layoutTableViewSection(self.AnalysisTab);
            self.PanZoomSection = self.layoutPanZoomSection(self.AnalysisTab);
            self.ExportSection = self.layoutExportSection(self.AnalysisTab);

            % Always create a figure, even if the tool was called without
            % an image. Otherwise, the app will close at the end of this
            % constructor.
            self.createFigure();

            % Add an image if it was provided.
            if nargin > 0
                self.importImageData(varargin{1});
                self.hasImage = true;
                self.resetFilters()
                self.toggleLoadDependentControls(true)
            else
                self.toggleLoadDependentControls(false)
            end
            
            self.imageLoadedListener = addlistener(self.imageLoadedEvent, ...
                'loaded', @self.reinitializeAppWithImage);
            self.filterUpdateListener = addlistener(self.hFilterRegionPanel.filterUpdateEvent, ...
                'settingsChanged', @self.reactToFilterChanges);
            
            imageslib.internal.apputil.manageToolInstances('add', 'imageRegionAnalyzer', self);

            % If a figure is closed, disable some controls.
            self.ClientActionListener = addlistener(self.hToolGroup,...
                'ClientAction',@(hobj,evt) clientActionCB(self,hobj,evt));
            
            % We want to destroy the current tool instance if a user
            % interactively closes the toolgroup associated with this
            % instance.
            addlistener(self.hToolGroup, 'GroupAction', ...
                @(~,ed) doClosingSession(self,ed));
            
        end
        
        function addMissingProps(self, propNames)
            % Find properties to add based on existing properties struct.
            propsToAdd = setdiff(propNames, fieldnames(self.propsUnsorted));
            if isempty(propsToAdd)
                return
            end
            
            % Add each property to the unsorted struct.
            newProps = regionprops(self.maskCurrent, propsToAdd);
            
            for p = 1:numel(propsToAdd)
                thisField = propsToAdd{p};
                [self.propsUnsorted(:).(thisField)] = deal(newProps.(thisField));
            end
            
            % Sort the current view.
            self.propsSortApplied = self.propsUnsorted(self.tableSortOrder);

        end
        
        function propNames = interestingProps(self)
            if isstruct(self.propsUnsorted)
                propNames = fieldnames(self.propsUnsorted);
                propNames = setdiff(propNames, 'PixelIdxList');
            else
                propNames = {};
            end
        end
        
    end
    
    
    % Toolstrip layout
    methods (Access = private)

        function hSection = layoutRegionFilteringSection(self, parentTab)
            
            hSection = parentTab.addSection('RegionFiltering', ...
                message('images:regionAnalyzer:regionFilteringTitle').getString());

            regionFilteringPanel = toolpack.component.TSPanel( ...
                'f:p,f:p', ... % columns
                'f:p:g,f:p:g,f:p:g');  % rows

            hSection.add(regionFilteringPanel);
            regionFilteringPanel.Name = 'panelRegionFiltering';
            
            FilterIcon = toolpack.component.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/Refine_24px.png'));
            self.hFilterButton = toolpack.component.TSDropDownButton(...
                message('images:regionAnalyzer:filterLabel').getString(),...
                FilterIcon);
            
            self.hFilterRegionPanel = iptui.internal.FilterPanel(self.propLimitsCache);
            self.hFilterButton.Popup = self.hFilterRegionPanel.hPopup;
            self.hFilterButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            
            self.hLoadDependentControls{end+1} = self.hFilterButton;
            iptui.internal.utilities.setToolTipText(self.hFilterButton, ...
                message('images:regionAnalyzer:filterTooltip').getString());
            self.hFilterButton.Name = 'btnFilterRegions';
            
            self.hExcludeBorderCheckbox = toolpack.component.TSCheckBox(...
                message('images:regionAnalyzer:excludeBorderLabel').getString());
            self.hLoadDependentControls{end+1} = self.hExcludeBorderCheckbox;
            iptui.internal.utilities.setToolTipText(self.hExcludeBorderCheckbox, ...
                message('images:regionAnalyzer:excludeBorderTooltip').getString());
            self.hExcludeBorderCheckbox.Name = 'chkExcludeBorder';
            
            self.hFillHolesCheckbox = toolpack.component.TSCheckBox(...
                message('images:regionAnalyzer:fillHolesLabel').getString());
            self.hLoadDependentControls{end+1} = self.hFillHolesCheckbox;
            iptui.internal.utilities.setToolTipText(self.hFillHolesCheckbox, ...
                message('images:regionAnalyzer:fillHolesTooltip').getString());
            self.hFillHolesCheckbox.Name = 'chkFillHoles';

            % Listeners for checkbox changes.
            self.regionCheckboxListener = addlistener([self.hExcludeBorderCheckbox self.hFillHolesCheckbox], ...
                'ItemStateChanged', @(hObj,evt) reactToFilterCheckboxChanges(self,hObj,evt));

            regionFilteringPanel.add(self.hFillHolesCheckbox,'xy(1,1)');
            regionFilteringPanel.add(self.hExcludeBorderCheckbox,'xy(1,2)');
            regionFilteringPanel.add(self.hFilterButton,'xywh(2,1,1,3)');
            
        end

        function hSection = layoutTableViewSection(self, parentTab)
            
            hSection = parentTab.addSection('TableView', ...
                message('images:regionAnalyzer:propertiesTitle').getString());

            tableViewPanel = toolpack.component.TSPanel( ...
                'f:p,f:p,50dlu', ... % columns
                'f:p,1dlu,f:p,f:p:g,');  % rows
            self.hTableViewPanel = tableViewPanel;

            hSection.add(tableViewPanel);
            tableViewPanel.Name = 'panelTableView';
            
            ChoosePropsIcon = toolpack.component.Icon.PROPERTIES_24;
            self.hSelectPropsButton = toolpack.component.TSDropDownButton(...
                message('images:regionAnalyzer:propertiesLabel').getString(), ...
                ChoosePropsIcon);
            
            [propNames, numForDisplay] = iptui.internal.getPropNames();
            self.hPropertyPickerPanel = iptui.internal.PropertiesSelectionPanel(propNames(1:numForDisplay));
            self.hPropertyPickerPanel.SelectedValues = iptui.internal.defaultSubsetOfProps();
            self.hSelectPropsButton.Popup = self.hPropertyPickerPanel.popup;
            self.hSelectPropsButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            iptui.internal.utilities.setToolTipText(self.hSelectPropsButton, ...
                message('images:regionAnalyzer:propertiesTooltip').getString());
            self.hSelectPropsButton.Name = 'btnSelectProps';
            self.hLoadDependentControls{end+1} = self.hSelectPropsButton;
            
            sortLabel = toolpack.component.TSLabel(getString(message('images:regionAnalyzer:sortLabel')));
            
            propNames = {message('images:regionAnalyzer:unsortedValue').getString(), ...
                self.hPropertyPickerPanel.SelectedValues{:}}; %#ok<CCAT>
            
            self.addSortCombo(propNames)

            tableViewPanel.add(self.hSelectPropsButton, 'xywh(1,1,1,4)');
            tableViewPanel.add(sortLabel, 'xywh(2,1,2,1)');
            
            addlistener(self.hPropertyPickerPanel, 'SelectedIndices', 'PostSet', @(hObj,evt) onPropertySelection(self,hObj,evt) );
                        
        end
        
        function hSection = layoutExportSection(self, parentTab)
            
            hSection = parentTab.addSection('Export',getString(message('images:colorSegmentor:export')));

            createMaskPanel = toolpack.component.TSPanel('f:p','f:p');
            hSection.add(createMaskPanel);
            createMaskPanel.Name = 'panelExport';
            
            createMaskIcon = toolpack.component.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/CreateMask_24px.png'));
            
            exportButton = toolpack.component.TSSplitButton(getString(message('images:regionAnalyzer:export')), ...
                createMaskIcon);
            addlistener(exportButton, 'ActionPerformed',@(hobj,evt) self.exportDataToWorkspace() );
            exportButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            exportButton.Name = 'btnExport';
            iptui.internal.utilities.setToolTipText(exportButton,getString(message('images:colorSegmentor:exportButtonTooltip')));

            % This style tells TSDropDownPopup to show just text and the
            % icon. We could also use 'text_only'.
            style = 'icon_text';
            
            exportButton.Popup = toolpack.component.TSDropDownPopup(...
                getExportOptions(), style);
            exportButton.Popup.Name = 'Export Popup';
            
            % Add listener for processing load image options
            addlistener(exportButton.Popup, 'ListItemSelected',...
                @self.exportSplitButtonCallback);
            
            createMaskPanel.add(exportButton, 'xy(1,1)' );
            
            self.hLoadDependentControls{end+1} = exportButton;
            
            
            % -------------------------------------------------------------
            function items = getExportOptions(~)
                % defining the option entries appearing on the popup of the
                % Export Split Button.
                
                exportDataIcon = toolpack.component.Icon(...
                    fullfile(matlabroot,'/toolbox/images/icons/CreateMask_16px.png'));
                
                exportFunctionIcon = toolpack.component.Icon(...
                    fullfile(matlabroot,'/toolbox/images/icons/GenerateMATLABScript_Icon_16px.png'));
                
                exportPropsIcon = toolpack.component.Icon.EXPORT_16;
                
                items(1) = struct(...
                    'Title', getString(message('images:regionAnalyzer:exportImage')), ...
                    'Description', '', ...
                    'Icon', exportDataIcon, ...
                    'Help', [], ...
                    'Header', false);

                items(2) = struct(...
                    'Title', getString(message('images:regionAnalyzer:exportProps')), ...
                    'Description', '', ...
                    'Icon', exportPropsIcon, ...
                    'Help', [], ...
                    'Header', false);

                items(3) = struct(...
                    'Title', getString(message('images:colorSegmentor:exportFunction')), ...
                    'Description', '', ...
                    'Icon', exportFunctionIcon, ...
                    'Help', [], ...
                    'Header', false);
            end
            
        end
        
        function addSortCombo(self, propNames)
            
            self.hSortCombo = toolpack.component.TSComboBox(propNames);
            self.hLoadDependentControls{end+1} = self.hSortCombo;
            iptui.internal.utilities.setToolTipText(self.hSortCombo, ...
                message('images:regionAnalyzer:sortTooltip').getString());
            self.hSortCombo.Name = 'comboSort';
            
            self.hTableViewPanel.add(self.hSortCombo, 'xywh(2,3,2,1)');
            addlistener(self.hSortCombo, 'ActionPerformed', @(~,evt)self.onSortSelectionChanged(evt));
            
            % At this point, the Panel holding the sort combo needs to be
            % re-rendered. The only way to do that seems to be to force a
            % revalidate on the panel.
            self.hTableViewPanel.Peer.revalidate();
            
            self.hSortCombo.Enabled = self.hasImage;
        end
        
        function removeSortCombo(self)
            self.hTableViewPanel.remove(self.hSortCombo)
        end
        
    end
    

    % Figure layout and image loading
    methods (Access = private)

        function hFig = createFigure(self)

            hFig = figure('NumberTitle', 'off',...
                'Colormap',gray(2),...
                'Tag','RegionAnalysisFigure',...
                'IntegerHandle','off');
            
            % Set the WindowKeyPressFcn to a non-empty function. This is
            % effectively a no-op that executes everytime a key is pressed
            % when the App is in focus. This is done to prevent focus from
            % shifting to the MATLAB command window when a key is typed.
            hFig.WindowKeyPressFcn = @(~,~)[];
            
            self.FigureHandles = hFig; % Only allows one figure.
            self.hToolGroup.addFigure(hFig);
            
            % Unregister image in drag and drop gestures when figures are
            % docked in toolgroup.
            self.hToolGroup.getFiguresDropTargetHandler.unregisterInterest(hFig);
            
            hideFigureFromExternalHGEvents(hFig)
            
            iptPointerManager(hFig);

        end

        function importImageData(self, img)
            % Set the imageData property of the superclass.
            self.imageData = self.prepImageData(img);
            
            % Layout the image-related parts.
            self.createScrollpanelView(self.imageData);
            self.maskCurrent = self.imageData;
            self.maskFilledCleared = self.imageData;
        end
        
        function out = prepImageData(self, in)
            maxNumberOfRegions = getMaxNumberOfRegions();
            cc = bwconncomp(in);
            self.hasLotsOfObjects = (cc.NumObjects > maxNumberOfRegions);
            
            if self.hasLotsOfObjects
                warndlg(getString(message('images:regionAnalyzer:tooManyObjects', maxNumberOfRegions)), ...
                    getString(message('images:regionAnalyzer:tooManyObjectsTitle')), ...
                    'non-modal');
                out = findLargestObjects(in);
            else
                out = in;
            end
        end
        
        function hFig = createScrollpanelView(self, img)
            
            hFig = self.FigureHandles;
            
            hImagePanel = findobj(hFig, 'tag', 'ImagePanel');
            if isempty(hImagePanel)
                hImagePanel = uipanel('Parent',hFig,'Position',[0 0 0.6 1],'BorderType','none','tag','ImagePanel');
            end
            
            hTablePanel = findobj(hFig, 'tag', 'TablePanel');
            if isempty(hTablePanel)
                hTablePanel = uipanel('Parent',hFig,'Position',[0.6 0 0.4 1],'BorderType','none','tag','TablePanel');
            end
            
            self.layoutScrollpanel(hImagePanel, img)
            self.layoutTable(hTablePanel, img)

            hideFigureFromExternalHGEvents(hFig)
            
        end

        
        function layoutScrollpanel(self, hImagePanel, img)
            
            if isempty(self.hScrollpanel) || ~ishandle(self.hScrollpanel)
                
                hAx = axes('Parent',hImagePanel);
                
                % Figure will be docked before imshow is invoked. We want
                % to avoid warning about fit mag in context of a docked
                % figure.
                warnState = warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
                hIm = imshow(img, 'Parent', hAx);
                warning(warnState)
                
                self.hScrollpanel = imscrollpanel(hImagePanel, hIm);
                set(self.hScrollpanel,'Units','normalized',...
                    'Position',[0 0 1 1])
                
                api = iptgetapi(self.hScrollpanel);
                drawnow()
                api.setMagnification(api.findFitMag())
                
                % Turn on axes visibility
                hAx = findobj(self.hScrollpanel, 'type', 'axes');
                set(hAx,'Visible','on');
                
                % Make selected regions red by setting background to red.
                set(hAx,'Color',[1 0 0])
                
                % Turn off axes gridding
                set(hAx, 'XTick', [], 'YTick', [])
                
            else
                
                % If scrollpanel has already been created, we simply want
                % to reparent it to the current figure that is being
                % created/in view.
                set(self.hScrollpanel, 'Parent', hImagePanel)
                
            end
        end

        function layoutTable(self, hTablePanel, img)
            propsStruct = self.computeProps(img);
            self.propsUnsorted = propsStruct;
            self.propsSortApplied = propsStruct;
            self.tableSortOrder = 1:numel(propsStruct);
            
            propsStruct = subsetProps(propsStruct, iptui.internal.defaultSubsetOfProps());
            [propsTable, propNames] = prepPropsForDisplay(propsStruct);
            
            if (isempty(self.hTable) || ~isvalid(self.hTable))
                self.hTable = uitable(...
                    'Data', propsTable, ...
                    'Parent', hTablePanel, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1], ...
                    'ColumnName', propNames, ...
                    'RearrangeableColumns', 'on', ...
                    'Tag', 'PropertiesTable', ...
                    'CellSelectionCallback', @(obj,evt) tableSelectionCallback(self, obj, evt));
            else
                set(self.hTable, 'Data', propsTable)
            end
            
            % Set the status bar text now that the table is populated.
            self.setStatusBarText(getString(message('images:regionAnalyzer:clickTableToSeeRegion')))
        end
        
        function reinitializeAppWithImage(self, ~, ~)
            self.hasImage = true;
            
            if isempty(self.hScrollpanel)
                self.importImageData(self.imageData)
            else
                img = self.prepImageData(self.imageData);
                self.maskCurrent = img;
                self.maskFilledCleared = img;
                self.imageData = img;
                api = iptgetapi(self.hScrollpanel);
                api.replaceImage(self.imageData)
                api.setMagnification(api.findFitMag())
            end
            
            propsStruct = self.computeProps(self.imageData);
            self.propsUnsorted = propsStruct;
            self.tableSortOrder = 1:numel(propsStruct);
            
            self.resetFilters()
            self.reactToFilterCheckboxChanges()
            
            self.toggleLoadDependentControls(true)
        end

    end
    
    
    % Client action callback
    methods (Access = private)
                
        function clientActionCB(self,~,evt)
                                     
            % When the last figure in the app has been closed, disable the
            % appropriate UI controls.
            if strcmpi(evt.EventData.EventType,'CLOSED')
                appDeleted = ~isvalid(self) || ~isvalid(self.hToolGroup);
                if ~appDeleted
                    self.hScrollpanel = [];
                    self.createFigure();
                    self.toggleLoadDependentControls(false)
                end
            end
            
        end
        
    end
    
    
    % Property sorting, selection, and filtering
    methods (Access = private)
        
        function doClosingSession(self, event)
            if strcmp(event.EventData.EventType, 'CLOSING')
                imageslib.internal.apputil.manageToolInstances('remove', 'imageRegionAnalyzer', self);
                delete(self);                     
            end
        end

        function reactToFilterChanges(self, ~, ~)
            originalMask = self.maskCurrent;
            self.maskCurrent = self.applyFilters(self.maskFilledCleared);

            % As an optimization, only update app's view if mask changed.
            if ~isequal(self.maskCurrent, originalMask)
                self.updateMaskView(self.maskCurrent);
                self.updateTableView(self.maskCurrent);
            end
        end

        function mask = applyFilters(self, mask)
            selections = self.hFilterRegionPanel;
            for idx = 1:selections.numberOfSelections
                filterFcn = selections.getSelectionFilterFcn(idx);
                mask = filterFcn(mask);
            end
        end
        
        function reactToFilterCheckboxChanges(self, ~, ~)
            self.maskFilledCleared = computeMask(self.imageData, ...
                self.hExcludeBorderCheckbox.Selected, ...
                self.hFillHolesCheckbox.Selected);
            self.maskCurrent = self.applyFilters(self.maskFilledCleared);

            % Assume that mask changed.
            self.updateMaskView(self.maskCurrent);
            self.updateTableView(self.maskCurrent);
        end

        function tableSelectionCallback(self, ~, evt)
            rowsSelected = evt.Indices(:,1);
            props = self.propsSortApplied(rowsSelected);
            pixels = [];
            for p = 1:numel(props)
                pixels = [pixels; props(p).PixelIdxList]; %#ok<AGROW>
            end
            
            hIm = findobj(self.hScrollpanel, 'type', 'image');
            adata = ones(size(self.maskCurrent));
            adata(pixels) = 0.5;
            set(hIm, 'AlphaData', adata)
        end

        function onSortSelectionChanged(self, evt)
            propName = evt.Source.SelectedItem;
            self.sortProperties(propName)
        end

        function sortProperties(self, propName)
            
            msg = message('images:regionAnalyzer:unsortedValue').getString();
            switch (propName)
                case (msg)
                    % If selected option is "unsorted," there's nothing to do.
                    processUnsortedCase(self);
                otherwise
                    if isempty(self.propsUnsorted)
                        processUnsortedCase(self);
                    else
                        processSortedCase(self,propName);
                    end
            end
            
            self.updateTableContents(self.propsSortApplied);
        end
        
        function processUnsortedCase(self)
            self.propsSortApplied = self.propsUnsorted;
            self.tableSortOrder = 1:numel(self.propsUnsorted);
        end
        
        function processSortedCase(self,propName)
            [~,idx] = sort([self.propsUnsorted.(propName)], 'descend');
            self.propsSortApplied = self.propsUnsorted(idx);
            self.tableSortOrder = idx;
        end

        function updateTableView(self, newMask)
            self.propsUnsorted = self.computeProps(newMask); %TODO: Is propsSortApplied correctly sorted?
            self.propsSortApplied = self.propsUnsorted;
            self.sortProperties(self.getCurrentSortField())
            self.updateTableContents(self.propsSortApplied)
        end

        function updateTableContents(self, propsStruct)
            hUitable = findobj(self.hTable, 'type', 'uitable');
            propsStruct = subsetProps(propsStruct, self.getSelectedProps());
            propsTable = prepPropsForDisplay(propsStruct);
            set(hUitable, 'Data', propsTable)
            fields = fieldnames(propsStruct);
            set(hUitable, 'ColumnName', fields);
        end

        function updateMaskView(self, newMask)
            % Find scrollpanel's image.
            hIm = findobj(self.hScrollpanel, 'type', 'image');
            
            % Update image's CData.
            set(hIm, 'CData', newMask)
        end

        function onPropertySelection(self, ~, evt)
            
            if ~self.hasImage
                return
            end
            propNames = evt.AffectedObject.SelectedValues;
            
            self.updateSortCombo(propNames)
            
            if ~isempty(self.propsUnsorted)
                self.addMissingProps(propNames)
                newPropsForDisplay = subsetProps(self.propsSortApplied, propNames);
                self.updateTableContents(newPropsForDisplay)
            end
            if ~(isempty(self.propsUnsorted) && ~isstruct(self.propsUnsorted))
                self.addMissingProps(propNames)
                newPropsForDisplay = subsetProps(self.propsSortApplied, propNames);
                self.updateTableContents(newPropsForDisplay)
            end
            self.addMissingProps(propNames)
            newPropsForDisplay = subsetProps(self.propsSortApplied, propNames);
            self.updateTableContents(newPropsForDisplay)
            

        end

        function updateSortCombo(self, propNames)
            % Add "(unset)" to the head of the propNames
            propNames = {message('images:regionAnalyzer:unsortedValue').getString(), ...
                propNames{:}}; %#ok<CCAT>
            
            % Find currently selected property.
            selectedProp = self.hSortCombo.SelectedItem;
            [~, idx] = intersect(propNames, selectedProp);

            % Update combo box property selections, updating the selection
            % index to point at the currently selected property or setting
            % it to "(unset)".
            self.removeSortCombo()
            self.addSortCombo(propNames)
            
            if isempty(idx)
                self.hSortCombo.SelectedIndex = 1;
            else
                self.hSortCombo.SelectedIndex = idx;
            end
        end
        
        function propNames = getSelectedProps(self)
            propNames = self.hPropertyPickerPanel.SelectedValues;
        end

        function sortField = getCurrentSortField(self)
            sortField = self.hSortCombo.SelectedItem;
        end

        function propsStruct = computeProps(self, mask)
            propNames = self.getSelectedProps();
            propNames{end+1} = 'PixelIdxList';
            propsStruct = regionprops(mask, propNames);
        end
        
        function resetFilters(self)

            self.hExcludeBorderCheckbox.Selected = false;
            self.hFillHolesCheckbox.Selected = false;
            
            selections = self.hFilterRegionPanel;
            selections.reset()
            
        end
        
    end


    % Code and variable exporting
    methods (Access = private)
        
        function exportSplitButtonCallback(self, src, ~)
            
            switch (src.SelectedIndex)
            case 1 
                self.exportDataToWorkspace()
            
            case 2
                self.exportProperties()
                
            case 3
                self.generateCode()
            end

        end
        
        function exportDataToWorkspace(self)
            
            export2wsdlg({getString(message('images:colorSegmentor:binaryMask'))},...
                          {'BW'}, {self.maskCurrent});
            
        end
        
        function exportProperties(self)
            
            propsStruct = subsetProps(self.propsSortApplied, self.hPropertyPickerPanel.SelectedValues);
            propsTable = struct2table(propsStruct);
            
            export2wsdlg({getString(message('images:regionAnalyzer:propsStruct')), ...
                          getString(message('images:regionAnalyzer:propsTable'))},...
                         {'propsStruct', 'propsTable'}, {propsStruct, propsTable});
            
        end
        
        function generateCode(self)
            
            codeGenerator = iptui.internal.CodeGenerator();
            
            % Write function definition
            self.addFunctionDeclaration(codeGenerator)
            codeGenerator.addReturn()
            codeGenerator.addHeader(self.appName);
            
            if (self.hasLotsOfObjects)
                codeGenerator.addLine(sprintf('BW_out = bwareafilt(BW_in, %d);', getMaxNumberOfRegions()))
            else
                codeGenerator.addLine('BW_out = BW_in;')
            end
            
            % Checkboxes
            if self.hExcludeBorderCheckbox.Selected
                codeGenerator.addComment('Remove portions of the image that touch an outside edge.')
                codeGenerator.addLine('BW_out = imclearborder(BW_out);')
            end
            
            if self.hFillHolesCheckbox.Selected
                codeGenerator.addComment('Fill holes in regions.')
                codeGenerator.addLine('BW_out = imfill(BW_out, ''holes'');')
            end
            
            % Apply filters if they don't have default settings.
            numFilters = self.hFilterRegionPanel.numberOfSelections;
            defaultSettings = true;
            for idx = 1:numFilters
                defaultSettings = defaultSettings && self.hFilterRegionPanel.hasDefaultSettings(idx);
            end
            
            if (~defaultSettings)
                codeGenerator.addComment('Filter image based on image properties.')
                for idx = 1:numFilters
                    if (~self.hFilterRegionPanel.hasDefaultSettings(idx))
                        [~, filterString] = self.hFilterRegionPanel.getSelectionFilterFcn(idx);
                        codeGenerator.addLine(sprintf(filterString, 'BW_out', 'BW_out'))
                    end
                end
            end
            
            % Build regionprops call (for property output).
            propertyList = self.hPropertyPickerPanel.SelectedValues;
            
            if ~isempty(propertyList)
                propertyString = ['{', sprintf('''%s'', ', propertyList{:})];
                propertyString(end-1:end) = '';
                propertyString = [propertyString '}'];
                
                codeGenerator.addComment('Get properties.')
                codeGenerator.addLine(sprintf('properties = regionprops(BW_out, %s);', ...
                    propertyString))
                
                if (~isequal(self.getCurrentSortField(), ...
                        message('images:regionAnalyzer:unsortedValue').getString()))
                    
                    % Add the call in the main function to sort properties.
                    codeGenerator.addComment('Sort the properties.')
                    codeGenerator.addLine(sprintf('properties = sortProperties(properties, ''%s'');', ...
                        self.getCurrentSortField()))
                    
                    % Create the subfunction that sorts properties.
                    sortingCodeGenerator = generateSortingCode();
                    sortingCode = sortingCodeGenerator.getCodeString();
                    codeGenerator.addSubFunction(sortingCode)
                end
                
                codeGenerator.addComment('Uncomment the following line to return the properties in a table.')
                codeGenerator.addLine('% properties = struct2table(properties);')
                
            else
                % No property selection was made.
                codeGenerator.addLine('properties = [];');
            end

            % Terminate the file with carriage return.
            codeGenerator.addReturn()
            
            % Output the generated code to the MATLAB editor.
            codeGenerator.putCodeInEditor()
            
            %--------------------------------------------------
            function sortingCodeGenerator = generateSortingCode()
                
                sortingCodeGenerator = iptui.internal.CodeGenerator();
                sortingCodeGenerator.addLine('function properties = sortProperties(properties, sortField)')
                sortingCodeGenerator.addComment('Compute the sort order of the structure based on the sort field.')
                sortingCodeGenerator.addLine('[~,idx] = sort([properties.(sortField)], ''descend'');')
                sortingCodeGenerator.addComment('Reorder the entire structure.')
                sortingCodeGenerator.addLine('properties = properties(idx);')
                
            end
            
        end
        
        function addFunctionDeclaration(~,generator)
            fcnName = 'filterRegions';
            inputs = {'BW_in'};
            outputs = {'BW_out', 'properties'};
            
            h1Line = ' Filter BW image using auto-generated code from imageRegionAnalyzer app.';
            
            description = ['filters binary image BW_IN using auto-generated code' ...
                ' from the imageRegionAnalyzer app. BW_OUT has had all of the' ...
                ' options and filtering selections that were specified in' ...
                ' imageRegionAnalyzer applied to it. The PROPERTIES structure' ...
                ' contains the attributes of BW_out that were visible in the app.'];
            
            generator.addFunctionDeclaration(fcnName,inputs,outputs,h1Line);
            generator.addSyntaxHelp(fcnName,description,inputs,outputs);
        end
        
    end
           
    methods (Static)
        
        function deleteAllTools
            imageslib.internal.apputil.manageToolInstances('deleteAll', 'imageRegionAnalyzer');
        end
        
    end
    
end
    

%--------------------------------------------------------------------------
function [propsTable, propNames] = prepPropsForDisplay(propsStruct)
    if (isfield(propsStruct, 'PixelIdxList'))
        propsStruct = rmfield(propsStruct, 'PixelIdxList');
    end
    propsTable = struct2cell(propsStruct)';
    propNames = fieldnames(propsStruct);
end

%--------------------------------------------------------------------------
function subset = subsetProps(fullPropsStruct, propNamesInSubset)
    allFields = fieldnames(fullPropsStruct);
    fieldsToDelete = setdiff(allFields, propNamesInSubset);
    subset = rmfield(fullPropsStruct, fieldsToDelete);
end

%--------------------------------------------------------------------------
function newMask = computeMask(mask, excludeBorder, fillHoles)
    if excludeBorder
        newMask = imclearborder(mask);
    else
        newMask = mask;
    end
    
    if fillHoles
        newMask = imfill(newMask, 'holes');
    end
end

%--------------------------------------------------------------------------
function img = findLargestObjects(img)
    w = warning();
    warning('off', 'images:bwfilt:tie')
    img = bwpropfilt(img, 'area', getMaxNumberOfRegions());
    warning(w);
end

%--------------------------------------------------------------------------
function value = getMaxNumberOfRegions
    value = 1000;
end
        

function hideFigureFromExternalHGEvents(hFig)
    set(hFig,'HandleVisibility','callback');
end
