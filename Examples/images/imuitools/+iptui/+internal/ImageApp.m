classdef ImageApp < handle

%   Copyright 2014 The MathWorks, Inc.

    properties
        
        appName      % Market name for this app
        GroupName    % Unique name assigned to toolgroup
        hToolGroup   % Handle to this app's ToolGroup
        
        hZoomInButton
        hZoomOutButton
        hPanButton

        % Handles to buttons in toolstrip that are enabled/distabled based
        % on whether data has been loaded into app.
        hLoadDependentControls
        hasImage
        
        % Image I/O
        imageData
        imageLoader
        imageLoadedEvent
        
    end
    
    methods

        function self = ImageApp(appName)
            
            % Each tool instance needs a unique name; use tempname.
            [~, uniqueName] = fileparts(tempname);
            self.GroupName = uniqueName;
            self.hToolGroup = toolpack.desktop.ToolGroup(self.GroupName, appName);
            
            % Set up the app.
            self.removeViewTab();
            self.removeQuickAccessBar()
            
            % Use the following event when a new image is loaded.
            self.imageLoadedEvent = iptui.internal.ImageLoadedIntoApp();
            self.hasImage = false;
        end
        
    end
    
    methods (Access = private)
        
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
        function openImageSplitButtonCallback(self, src, ~)
            
            if src.SelectedIndex == 1         % Open Image From File
                newImage = self.imageLoader.loadImageFromFile();
            elseif src.SelectedIndex == 2     % Load Image From Workspace
                newImage = self.imageLoader.loadImageFromWorkspace();
            end
            
            if ~isempty(newImage) && ~isequal(newImage, self.imageData)
                self.imageData = newImage;
                notify(self.imageLoadedEvent, 'loaded')
            end
        end
        
        %------------------------------------------------------------------
        function zoomIn(self,hToggle,~)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if hToggle.Selected
                self.hZoomOutButton.Selected = false;
                self.hPanButton.Selected = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                zoomInFcn = imuitoolsgate('FunctionHandle', 'imzoomin');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',zoomInFcn);
                glassPlus = setptr('glassplus');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,glassPlus{:}));
            else
                if ~(self.hZoomOutButton.Selected || self.hPanButton.Selected)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                end
            end
            
        end
        
        %------------------------------------------------------------------
        function zoomOut(self,hToggle,~)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if hToggle.Selected
                self.hZoomInButton.Selected = false;
                self.hPanButton.Selected    = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                zoomOutFcn = imuitoolsgate('FunctionHandle', 'imzoomout');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',zoomOutFcn);
                glassMinus = setptr('glassminus');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,glassMinus{:}));
            else
                if ~(self.hZoomInButton.Selected || self.hPanButton.Selected)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                end
            end
            
        end
        
        %------------------------------------------------------------------
        function panImage(self,hToggle,~)
            
            hIm = findobj(self.hScrollpanel,'type','image');
            if hToggle.Selected
                self.hZoomOutButton.Selected = false;
                self.hZoomInButton.Selected = false;
                warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
                panFcn = imuitoolsgate('FunctionHandle', 'impan');
                warning(warnstate);
                set(hIm,'ButtonDownFcn',panFcn);
                handCursor = setptr('hand');
                iptSetPointerBehavior(hIm,@(hFig,~) set(hFig,handCursor{:}));
            else
                if ~(self.hZoomInButton.Selected || self.hZoomOutButton.Selected)
                    set(hIm,'ButtonDownFcn','');
                    iptSetPointerBehavior(hIm,[]);
                    
                end
            end
            
        end

    end
    
    methods (Access = protected)
        
        function disableInteractiveTiling(self)
            % Disable interactive tiling in app. 
            
            % Needs to be called before tool group is opened.
            g = self.hToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_USER_TILE, false);
        end
        
        function hideDataBrowser(self)
            % Hide Data Browser in Tab
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.hideClient('DataBrowserContainer',self.GroupName);
        end
        
        function preventTabHiding(self)
            % Disable "Hide" option in tabs.
            g = self.hToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_DOCUMENT_BAR_HIDE, false);
        end
        
        function hSection = layoutLoadImageSection(self, parentTab)

            hSection = parentTab.addSection('LoadImage',getString(message('images:colorSegmentor:loadImage')));

            % Create Panel to hold button in Load Image section
            loadImagePanel = toolpack.component.TSPanel('f:p','f:p');
            loadImagePanel.Name = 'panelLoadImage';
            hSection.add(loadImagePanel);
            
            loadImageButton = toolpack.component.TSSplitButton(getString(message('images:colorSegmentor:loadImageSplitButtonTitle')), ...
                toolpack.component.Icon.IMPORT_24);
            addlistener(loadImageButton, 'ActionPerformed', @(hobj,evt) defaultLoadAction(self, hobj,evt) );
            loadImageButton.Orientation = toolpack.component.ButtonOrientation.VERTICAL;
            iptui.internal.utilities.setToolTipText(loadImageButton,getString(message('images:colorSegmentor:loadImageTooltip')));
            loadImageButton.Name = 'btnLoadImage';
            
            % This style tells TSDropDownPopup to show just text and the
            % icon. We could also use 'text_only'.
            style = 'icon_text';
            
            loadImageButton.Popup = toolpack.component.TSDropDownPopup(...
                getLoadOptions(), style);
            loadImageButton.Popup.Name = 'Load Image Popup';
            
            % Add listener for processing load image options
            addlistener(loadImageButton.Popup, 'ListItemSelected',...
                @self.openImageSplitButtonCallback);
            
            loadImagePanel.add(loadImageButton, 'xy(1,1)' );
            
            % -------------------------------------------------------------
            function items = getLoadOptions
                % defining the option entries appearing on the popup of the
                % Load Split Button.
                
                items(1) = struct(...
                    'Title', getString(message('images:colorSegmentor:loadImageFromFile')), ...
                    'Description', '', ...
                    'Icon', toolpack.component.Icon.IMPORT_16, ...
                    'Help', [], ...
                    'Header', false);
                items(2) = struct(...
                    'Title', getString(message('images:colorSegmentor:loadImageFromWorkspace')), ...
                    'Description', '', ...
                    'Icon', toolpack.component.Icon.IMPORT_16, ...
                    'Help', [], ...
                    'Header', false);
            end
            
        end
        
        function defaultLoadAction(self, ~, ~)
            newImage = self.imageLoader.loadImageFromFile();
            
            if ~isempty(newImage) && ~isequal(newImage, self.imageData)
                self.imageData = newImage;
                self.hasImage = true;
                notify(self.imageLoadedEvent, 'loaded')
                self.toggleLoadDependentControls(true)
            end
        end
        
        function hSection = layoutPanZoomSection(self, parentTab)

            hSection = parentTab.addSection('PanZoomSection',getString(message('images:colorSegmentor:zoomAndPan')));
            
            zoomPanPanel = toolpack.component.TSPanel( ...
                'f:p', ... % columns
                'f:p:g,f:p:g,f:p:g');  % rows
            
            zoomPanPanel.Name = 'panelZoomPan';
            
            hSection.add(zoomPanPanel);
            
            self.hZoomInButton = toolpack.component.TSToggleButton(getString(message('images:commonUIString:zoomInTooltip')),...
                toolpack.component.Icon.ZOOM_IN_16);
            addlistener(self.hZoomInButton, 'ItemStateChanged', @(hobj,evt) self.zoomIn(hobj,evt) );
            self.hZoomInButton.Orientation = toolpack.component.ButtonOrientation.HORIZONTAL;
            self.hLoadDependentControls{end+1} = self.hZoomInButton;
            iptui.internal.utilities.setToolTipText(self.hZoomInButton,getString(message('images:commonUIString:zoomInTooltip')));
            self.hZoomInButton.Name = 'btnZoomIn';
            
            self.hZoomOutButton = toolpack.component.TSToggleButton(getString(message('images:commonUIString:zoomOutTooltip')),...
                toolpack.component.Icon.ZOOM_OUT_16);
            addlistener(self.hZoomOutButton, 'ItemStateChanged', @(hobj,evt) self.zoomOut(hobj,evt) );
            self.hZoomOutButton.Orientation = toolpack.component.ButtonOrientation.HORIZONTAL;
            self.hLoadDependentControls{end+1} = self.hZoomOutButton;
            iptui.internal.utilities.setToolTipText(self.hZoomOutButton,getString(message('images:commonUIString:zoomOutTooltip')));
            self.hZoomOutButton.Name = 'btnZoomOut';
            
            self.hPanButton = toolpack.component.TSToggleButton(getString(message('images:colorSegmentor:pan')),...
                toolpack.component.Icon.PAN_16 );
            addlistener(self.hPanButton, 'ItemStateChanged', @(hobj,evt) self.panImage(hobj,evt) );
            self.hPanButton.Orientation = toolpack.component.ButtonOrientation.HORIZONTAL;
            self.hLoadDependentControls{end+1} = self.hPanButton;
            iptui.internal.utilities.setToolTipText(self.hPanButton,getString(message('images:colorSegmentor:pan')));
            self.hPanButton.Name = 'btnPan';
            
            zoomPanPanel.add(self.hZoomInButton, 'xy(1,1)' );
            zoomPanPanel.add(self.hZoomOutButton,'xy(1,2)' );
            zoomPanPanel.add(self.hPanButton,'xy(1,3)' );
            
        end
        
        function removeDocumentBar(self)
            %removeDocumentBar  Remove document bar above figure.
            
            group = self.hToolGroup.Peer.getWrappedComponent;
            
            % Remove document bar.
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.SHOW_SINGLE_ENTRY_DOCUMENT_BAR, false);
            
            % Clean up title.
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.APPEND_DOCUMENT_TITLE, false);
        end

        function toggleLoadDependentControls(self, TF)
            for p = 1:numel(self.hLoadDependentControls)
                self.hLoadDependentControls{p}.Enabled = TF;
            end
        end
        
        function setStatusBarText(self, statusText)
            iptui.internal.utilities.setStatusBarText(self.GroupName, statusText)
        end
    end
end
