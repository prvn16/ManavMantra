classdef ToolGroup < handle
    % Tool Group
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.ToolGroup">ToolGroup</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.Collapsible">Collapsible</a>                
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.Name">Name</a>                
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.SelectedTab">SelectedTab</a>                
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.TabNames">TabNames</a>                
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.Title">Title</a>                
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.addClientTabGroup">addClientTabGroup</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.addFigure">addFigure</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.addTabGroup">addTabGroup</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.approveClose">approveClose</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.close">close</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.disableDataBrowser">disableDataBrowser</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.getFiguresDropTargetHandler">getFiguresDropTargetHandler</a>
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.getTab">getTab</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.getTabGroup">getTabGroup</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.hideViewTab">hideViewTab</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.isClientShowing">isClientShowing</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.isClosingApprovalNeeded">isClosingApprovalNeeded</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.open">open</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.removeClientTabGroup">removeClientTabGroup</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.removeTabGroup">removeTabGroup</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setClosingApprovalNeeded">setClosingApprovalNeeded</a>   
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setContextualHelpCallback">setContextualHelpCallback</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setDataBrowser">setDataBrowser</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setDefaultPosition">setDefaultPosition</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setDockable">setDockable</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setIcon">setIcon</a>    
	%   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setPosition">setPosition</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.setWaiting">setWaiting</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.showClient">showClient</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.showTearOffDialog">showTearOffDialog</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.vetoClose">vetoClose</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.ClientAction">ClientAction</a>    
    %   <a href="matlab:help matlab.ui.internal.desktop.ToolGroup.GroupAction">GroupAction</a>    
    %
    % See also matlab.ui.internal.toolstrip.TabGroup

    % Author(s): R. Chen
    % Copyright 2015 The MathWorks, Inc.
    
    %% Public Properties
    properties (Dependent)
        % Property "Title": 
        %
        %   Displayed as the app title.  It takes a string.  The default
        %   value is 'Title'.  Writable.
        Title
        % Property "Collapsible": 
        %
        %   Determine whether toolstrip is collapsible in the app.  It
        %   takes a logical value.  The default value is true when there is
        %   tab group present in the toolstrip.  Writable.
        Collapsible
    end
    
    properties (Dependent, SetAccess = private)
        % Property "Name": 
        %
        %   App name, which should be unique in a MATLAB session.  It takes
        %   a string.  The default value is 'appname' appended by a UUID
        %   string. Read-only.  You can specify it as the 2nd input of the
        %   constructor.
        Name
        % Property "TabNames": 
        %
        %   List of names of all the tabs present in the toolstrip.  It is
        %   a cell array of strings.  The default value is {}.  Read-only.
        TabNames
    end
    
    properties (Dependent, Access = public, SetObservable, AbortSet)
        % Property "SelectedTab": 
        %
        %   Name of the currently selected tab in the toolstrip.  It takes 
        %   a string.  The default value is ''.  Writable.
        SelectedTab
    end
    
    %% Internal Properties
    properties (Hidden, GetAccess = public, SetAccess = private)
        % com.mathworks.mlwidgets.toolgroup.ToolGroupWrapper
        Peer
        % peer model channel namespace
        UUID
        PeerModelChannel
        PeerModelManager
        ToolstripHostId
        % Toolstrip
        SwingToolstrip  % com.mathworks.toolstrip.DefaultToolstrip
        MCOSToolstrip   % matlab.ui.internal.toolstrip.Toolstrip
        % swing client side service
        ToolstripSwingService % matlab.ui.internal.toolstrip.swing.ToolstripSwingService
    end
    
    properties (Access = protected)
        % Listeners for events from ToolGroupWrapper
        AttributeListener
        ClientListener
        GroupListener
        % Listeners for Toolstrip management
        ListenersMCOSToolstrip
        ListenersToolstripSwingService
    end
    
    properties (Access = private)
        % Handling of association between clients (figures) and contextual
        % tabgroups.  Only the clients with contextual tabgroups are added
        % to the ClientMap list.
        ClientMap = cell(0,3)   % {figure, tabgroup, selectedtab; ...}
        ClientActionListener    % single listener to the ClientAction event 
        ActiveClient            % a client in the client map or []
        % Holds the FigureDropTargetHandler object
        FiguresDropTargetHandler
        % QABHelpButtonListener for help button in QAB
        QABHelpButtonListener
    end
    
    % ----------------------------------------------------------------------------
    events
        % Event fired upon changes to any document client.
        ClientAction
        % Event fired upon changes to the toolgroup itself.
        GroupAction
    end
    
    % ----------------------------------------------------------------------------
    methods
        
        %% constructor
        function this = ToolGroup(apptitle, appname)
            % Constructor "ToolGroup": 
            %
            %   Create a ToolGroup container to host an app.
            %
            % Example:
            %   title = 'Control System Tuner';
            %   app = matlab.ui.internal.desktop.ToolGroup(title);
            %   tabgroup = matlab.ui.internal.toolstrip.TabGroup();
            %   tab = tabgroup.addTab('HOME');
            %   tab.Tag = 'tabHome';
            %   app.addTabGroup(tabgroup);
            %   app.open()
            
			% check java
			if ~usejava('jvm') || ~matlab.ui.internal.hasDisplay || ~matlab.ui.internal.isFigureShowEnabled
				error(message('MATLAB:toolstrip:general:NoJVM'));
			end
            % random channel
            this.UUID = char(java.util.UUID.randomUUID);
            this.PeerModelChannel = ['/Toolstrip/' this.UUID]; 
            this.ToolstripHostId = this.UUID;
            % default name
            if nargin == 0
                appname = ['appname(' this.UUID ')'];
                apptitle = 'Title';
            elseif nargin == 1
                appname = ['appname(' this.UUID ')'];
            else
                appname = [appname '(' this.UUID ')'];
            end
            % enforce common look and feel
            com.mathworks.toolstrip.plaf.TSLookAndFeel.install
            % create ToolGroup that is a sub-class of DTGroupBase
            swingClass = 'com.mathworks.mlwidgets.toolgroup.ToolGroupWrapper';
            this.Peer = javaObjectEDT(swingClass, appname, apptitle);
            % enable listeners
            addClientListener( this, {@handleClientAction, this} );
            addGroupListener( this,  {@handleGroupAction, this} );
            % enable drag and drop 
            this.FiguresDropTargetHandler = matlab.ui.internal.desktop.FiguresDropTargetHandler();
            % enable toolstrip peer model service
            this.ToolstripSwingService = matlab.ui.internal.toolstrip.swing.ToolstripSwingService(this.PeerModelChannel);
            this.PeerModelManager = com.mathworks.peermodel.PeerModelManagers.getInstance(this.PeerModelChannel);
            % create MCOS toolstrip object (not rendered yet)
            this.MCOSToolstrip = matlab.ui.internal.toolstrip.Toolstrip();
            % refresh app when requested by swing service
            this.ListenersToolstripSwingService = addlistener(this.ToolstripSwingService,'RefreshToolGroup',@(es, ed) refreshToolGroup(this));
            % sync swing toolstrip display state and selected tab with MGG toolstrip
            if matlab.ui.internal.desktop.isMOTW()
                this.ListenersMCOSToolstrip = [addlistener(this.MCOSToolstrip,'DisplayStateChanged',@(es, ed) refreshDisplayState(this)); addlistener(this.MCOSToolstrip,'SelectedTabChanged',@(es, ed) refreshTabSelection(this))];
            end
        end
        
        %% destructor
        function delete(this)
            % Deletes the handle, also removing the group from the desktop.
            delete(this.ListenersToolstripSwingService);
            delete(this.ListenersMCOSToolstrip);
            delete(this.QABHelpButtonListener)  % Delete QAB listeners
            delete(this.AttributeListener)      
            delete(this.ClientListener)
            delete(this.GroupListener)
            if isvalid(this.ToolstripSwingService)
                this.ToolstripSwingService.cleanup();
            end
            delete(this.MCOSToolstrip);
            %pause(1);this.ToolstripSwingService.Registry.getSize()
            this.close;
        end
        
        %% getters and setters
        % Name
        function value = get.Name(this)
            % GET function for Name property.
            value = char(this.Peer.getName);
        end
        % TabNames
        function tabs = get.TabNames(this)
            % GET function for TabNames property.
            tabs = {};
            for ct = 1:length(this.MCOSToolstrip.Children)
                tabgroup = this.MCOSToolstrip.Children(ct);
                for i = 1:length(tabgroup.Children)
                    tab = tabgroup.Children(i);
                    tabs = [tabs; {tab.Tag}]; %#ok<AGROW>
                end
            end
        end
        % Title
        function value = get.Title(this)
            % GET function for Title property.
            value = char(this.Peer.getTitle);
        end
        function set.Title(this, value)
            % SET function for Title property.
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if isempty(value)
                value = '';
            elseif ~ischar(value)
                error(message('MATLAB:toolstrip:general:StringArgumentNeeded'));
            end
            this.Peer.setTitle(value);
        end
        % Collapsible
        function collapsible = get.Collapsible(this)
            % Returns the visibility status of the collapse button.
            collapsible = this.Peer.isCollapsable;
        end
        function set.Collapsible(this, collapsible)
            % Sets the visibility status of the collapse button.
            this.Peer.setCollapsable(collapsible);
        end
        % SelectedTab
        function value = get.SelectedTab(this)
            % GET function for SelectedTab property.
            value = char(this.Peer.getCurrentTab());
        end
        function set.SelectedTab(this, value)
            % SET function for SelectedTab property.
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if ~ischar(value)
                error(message('MATLAB:toolstrip:general:StringArgumentNeeded'));
            end
            if isempty(value)
                % swing
                this.Peer.setCurrentTab('');
            elseif any(strcmp(value,this.TabNames))
                % swing
                this.Peer.setCurrentTab(value);
                % update tabgroup selection
                tab = this.getTab(value);
                for ct=1:length(this.MCOSToolstrip.Children)
                    tabgroup = this.MCOSToolstrip.Children(ct);
                    if any(tab==tabgroup.Children)
                        tabgroup.SelectedTab = tab;
                        break;
                    end
                end
            end
        end
        
        %% Tab management
        function tab = getTab(this, tag)
            % Method "getTab": 
            %
            %   Returns the Tab MCOS object with specified tag (error out
            %   if not found).  
            %   
            %   If no tag is specified, return all the tabs.
            %
            % Example:
            %   tabs = getTab(toolgroup);
            %   tab = getTab(toolgroup, 'tabHome');
            narginchk(1,2);
            tab = [];
            if nargin==1
                for ct = 1:length(this.MCOSToolstrip.Children)
                    tabgroup = this.MCOSToolstrip.Children(ct);
                    for i = 1:length(tabgroup.Children)
                        tab = [tab; tabgroup.Children(i)]; %#ok<AGROW>
                    end
                end
            else
                tag = matlab.ui.internal.toolstrip.base.Utility.hString2Char(tag);
                if ischar(tag)            
                    for ct = 1:length(this.MCOSToolstrip.Children)
                        tabgroup = this.MCOSToolstrip.Children(ct);
                        for i = 1:length(tabgroup.Children)
                            if strcmp(tabgroup.Children(i).Tag, tag)
                                tab = tabgroup.Children(i);
                                break;
                            end
                        end
                    end
                    if isempty(tab)
                        error(message('MATLAB:toolstrip:container:failedTabNotFound',tag));
                    end
                else
                    error(message('MATLAB:toolstrip:general:StringArgumentNeeded'));
                end
            end
        end
        
        %% TabGroup management
        function addTabGroup(this, tabgroup)
            % Method "addTabGroup": 
            %
            %   Add a TabGroup MCOS object to the Toolstrip in ToolGroup
            %
            %   Example:
            %       addTabGroup(this, tabgroup);
            
            % if toolgroup is open (i.e. toolstrip is already rendered),
            % the following line will also render tabgroup hierarchy on the
            % swing side.  Otherwise, only MCOS hierarchy is added.
            this.MCOSToolstrip.add(tabgroup);
            % must force swing rendering before tabs can be added to
            % toolstrip in the toolgroup.
            drawnow();
            % In the above code, if a tab node is added to a tabgroup node,
            % the swing tab would be added to toolstrip.  In that case, the
            % following "addTabs" command will not add it again.
            % Otherwise, it will add the tab.
            if ~isempty(this.SwingToolstrip)
                addTabs(this, tabgroup);
            end
        end
        
        function removeTabGroup(this, tabgroup)
            % Method "removeTabGroup": 
            %
            %   Remove a TabGroup MCOS object from the Toolstrip in
            %   ToolGroup.  The TabGroup object is not deleted by this
            %   operation.
            %
            %   Example:
            %       removeTabGroup(this, tabgroup);
            
            % if toolgroup is open (i.e. toolstrip is already rendered),
            % the following line will only move tabgroup peer node to the
            % orphan root without removing swing tabs from toolstrip.
            % Otherwise, only MCOS hierarchy is changed.
            this.MCOSToolstrip.remove(tabgroup);
            % If toolgroup is open (i.e. toolstrip is rendered), we need to
            % use toolgroup swing API to manually remove tabs directly from
            % toolstrip.
            if ~isempty(this.SwingToolstrip)
                removeTabs(this, tabgroup);
            end
        end
        
        function tg = getTabGroup(this, tag)
            % Method "getTabGroup": 
            %
            %   Returns the TabGroup MCOS object with specified tag ([] if
            %   not found).  
            %
            %   If no tag is specified, return all the tab groups.
            %
            % Example:
            %   tabgroups = getTabGroup(toolgroup);
            %   tabgroup = getTabGroup(toolgroup, 'tg1');
            narginchk(1,2);
            tg = [];
            if nargin==1
                if ~isempty(this.MCOSToolstrip.Children)
                    tg = this.MCOSToolstrip.Children;
                end
            else
                tag = matlab.ui.internal.toolstrip.base.Utility.hString2Char(tag);
                if ischar(tag)            
                    for ct = 1:length(this.MCOSToolstrip.Children)
                        if strcmp(this.MCOSToolstrip.Children(ct).Tag, tag)
                            tg = this.MCOSToolstrip.Children(ct);
                            break;
                        end
                    end
                    if isempty(tg)
                        error(message('MATLAB:toolstrip:container:failedTabGroupNotFound',tag));
                    end
                else
                    error(message('MATLAB:toolstrip:general:StringArgumentNeeded'));
                end
            end
        end
        
        %% Render management
        function open(this)
            % Method "open": 
            %
            %   Display ToolGroup.  Note: You must build toolstrip before
            %   openning the app. You also must add figure documents after
            %   openning the app.
            %
            %   Example:
            %       open(this);
            
            % opens the desktop group.
            this.Peer.open();
            % get swing toolstrip
            while isempty(this.SwingToolstrip)
                this.SwingToolstrip = this.Peer.getWrappedComponent().getToolstrip();
            end
            this.ToolstripSwingService.SwingToolGroup = this.Peer;
            % add namespace to toolstrip swing component
            javaMethodEDT('putClientProperty',this.SwingToolstrip.getComponent(),'toolstrip_namespace',this.PeerModelChannel);
            javaMethodEDT('putClientProperty',this.SwingToolstrip.getComponent(),'toolstrip_host_id',this.ToolstripHostId);
            % render the toolstrip hierarchy
            render(this.MCOSToolstrip, this.PeerModelChannel);
            % make sure swing toolstrip components are created
            drawnow();
            % place toolstrip in the dom (valid for JS rendering)
            this.MCOSToolstrip.addToHost(this.ToolstripHostId);
            % enable selected tab listener at the very end
            if isempty(this.AttributeListener)
                addAttributeListener( this, {@handleAttribute, this} );
            end
        end
        
        function close(this)
            % Method "close": 
            %
            %   Remove ToolGroup from Desktop and thus close the app view.
            %
            %   Example:
            %       close(this);
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.closeGroup(this.Name);
        end
        
        %% Special utility methods
		function showTearOffDialog(this, dialog, anchor, floating)
            % Method "showTearOffDialog": 
            %
            %   Display a tear-off dialog below a toolstrip control.
            %
            %   Example:
            %       showTearOffDialog(this, dialog, anchor);
            %   where: 
            %       "dialog" must be a "toolpack.component.TSTearOffPopup" MCOS object
            %       "anchor" must be a "matlab.ui.internal.toolstrip.***" MCOS object  
            %
            %   To enfore dialog opens in a particular floating mode, do:
            %       showTearOffDialog(this, dialog, anchor, floating);
            %   where: 
            %       "floating" is true or false
            
            % for MGG use only
            jrootpane = dialog.Peer.getWrappedComponent().getRootPane();
            javaMethodEDT('putClientProperty',jrootpane(1),'anchor_id',anchor.getId());
            % deal with optional floating setting
            if nargin==4
                if islogical(floating)
                    dialog.Peer.setFloating(floating);
                else
                    error(message('MATLAB:toolstrip:general:LogicalArgumentNeeded'));
                end
            end
            % open
            janchor = this.ToolstripSwingService.Registry.getWidgetById(anchor.getId());
            jdialog = dialog.Peer.getWrappedComponent();
            javaMethodEDT('pack',jdialog);
            javaMethodEDT('showPopup','com.mathworks.toolbox.shared.controllib.desktop.TearOffDialogWrapper',janchor,jdialog,'SOUTH');
        end
        
        function hideViewTab(this)
            % Method "hideViewTab": 
            %
            %   Hide the default "View" tab.  Must call it before openning
            %   the app. 
            %
            %   Example:
            %       hideViewTab(this);
            g = this.Peer.getWrappedComponent();
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB, false);
        end
        
        function setIcon(this, ImageIcon)
            % Method "setIcon": 
            %
            %   Change the app icon at the top-left corner before or after
            %   openning the app.  
            %
            %   Example:
            %       setIcon(this, icon);
            %   where "icon" must be a "javax.swing.ImageIcon" object that
            %   represents a 16x16 image.
            md = com.mathworks.mde.desk.MLDesktop.getInstance;
            myclient =  md.getClient('DataBrowserContainer',this.Name);
            if isempty(myclient)
                % before open
                c = this.Peer.getWrappedComponent();
                c.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.ICON, ImageIcon);
            else
                f = md.getContainingFrame(myclient);
                f.setIcon(ImageIcon);
            end
        end
        
        function setDockable(this)
            % Method "setDockable": 
            %
            %   Enable the app to be dockable to Desktop.  Must be called
            %   before openning the app.   
            %
            %   Example:
            %       setDockable(this);
            this.Peer.getWrappedComponent().putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DOCKABLE, true);
        end
        
        function setWaiting(this, state, comps)
            % Method "setWaiting": 
            %
            %   Sets the waiting state of the java frame containing the
            %   tool group, optionally keeping live access to specified
            %   toolstrip components. 
            %
            %   Example:
            %       setWaiting(this, state, comps);
            %   where:
            %       "state" is true/false 
            %       "comps" (if specified) is an array of "matlab.ui.internal.toolstrip.*" objects.
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            frame = md.getFrameContainingGroup(this.Name);
            if ~md.isGroupDocked(this.Name) && ~isempty(frame)
                gc = 'com.mathworks.mwswing.GlobalCursor';
                if state
                    if nargin > 2 && ~isempty(comps)
                        list = java.util.ArrayList;
                        for n = 1:length(comps)
                            list.add(getToolstripSwingComponent(this,comps(n)));
                        end
                        javaMethodEDT('setWait', gc, frame, list);
                    else
                        javaMethodEDT('setWait', gc, frame);
                    end
                else
                    javaMethodEDT('clear', gc, frame);
                end
            end
        end
        
        %% contextual help management
        function setContextualHelpCallback(this, fhandle)
            % Method "setContextualHelpCallback": 
            %
            %   Sets doc link to the help button in the QAB. this method
            %   MUST be called before app opens.
            %
            %   Example: 
            %       setContextualHelpCallback(this, @(es, ed) doc('abs'));
            dtGroupBase = this.Peer.getWrappedComponent();
            % Create action
            action = javaMethodEDT('getAction','com.mathworks.mlwidgets.toolgroup.Utils','My Help',javax.swing.ImageIcon);
            this.QABHelpButtonListener = addlistener(action.getCallback, 'delayed', fhandle);
            % Register action
            contextTargetingManager = com.mathworks.toolstrip.factory.ContextTargetingManager();
            contextTargetingManager.setToolName(action, 'help');
            % Set the action BEFORE opening the ToolGroup
            aJavaArray = dtGroupBase.getGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.CONTEXT_ACTIONS);
            if isempty(aJavaArray) 
                 aJavaArray = javaArray('javax.swing.Action', 1); 
                 aJavaArray(1) = action; 
            else 
                 aJavaArray(end+1) = action; 
            end 
            dtGroupBase.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.CONTEXT_ACTIONS, aJavaArray);
        end      
        
        %% closing management
        function b = isClosingApprovalNeeded(this)
            % Method "isClosingApprovalNeeded": 
            %
            %   Return whether the group needs approval or veto before
            %   closing. 
            %
            %   Example:
            %       value = isClosingApprovalNeeded(this);
            b = this.Peer.isClosingApprovalNeeded;
        end
        
        function setClosingApprovalNeeded(this, b)
            % Method "setClosingApprovalNeeded": 
            %
            %   Set to true if the group needs approval or veto before
            %   closing. 
            %
            %   Example:
            %       setClosingApprovalNeeded(this, value);
            %   where "value" must be true or false.
            this.Peer.setClosingApprovalNeeded(b);
        end
        
        function approveClose(this)
            % Method "approveClose": 
            %
            %   Approve the closing of the ToolGroup.  To be used in the
            %   callback of the group CLOSING event after approval.
            %
            %   Example:
            %       approveClose(this);
            this.Peer.approveGroupClose;
        end
        
        function vetoClose(this)
            % Method "vetoClose": 
            %
            %   Veto the closing of the ToolGroup.  To be used in the
            %   callback of the group CLOSING event after veto.
            %
            %   Example:
            %       vetoClose(this);
            this.Peer.vetoGroupClose;
        end
        
        %% data browser management
        function disableDataBrowser(this)
            % Method "disableDataBrowser": 
            %
            %   Completely remove default data browser from ToolGroup.
            %   You can use it before or after calling "open" method.
            %
            %   Example:
            %       app = matlab.ui.internal.desktop.ToolGroup();
            %       app.disableDataBrowser();
            %       app.open();
            
            % the following line is for disabling before openning
            this.Peer.disableDataBrowser();
        end
        
        function setDataBrowser(this, panel)
            % Method "setDataBrowser": 
            %
            %   Places the specified Java panel in the singleton client
            %   location. 
            %
            %   Example:
            %       setDataBrowser(this, jpanel);
            %   where "jpanel" is a "javax.swing.JPanel" object
            this.Peer.setPanel(panel);
        end
        
        %% Position management
        function setDefaultPosition(this)
            % Method "setDefaultPosition": 
            %
            %   Move the tool group to its default position
            %   [100, 100, 960, 710].  You should use it before or after
            %   calling "open" method.
            %
            %   Example:
            %       setDefaultPosition(this);
            this.Peer.setDefaultPosition();
        end
        
        function setPosition(this, x, y, width, height)
            % Method "setPosition": 
            %
            %   Display toolgroup at the desired position.  You can
            %   use it before or after calling "open" method.
            %
            %   The position values are consistent with the definition used
            %   by MATLAB "figure", which compensates for high-DPI.
            %
            %       setPosition(this, x, y, width, height)
            %   where:  [x, y] is the top-left corner
            %           all the position values are in pixels.
            %
            %   Example:
            %       app = matlab.ui.internal.desktop.ToolGroup();
            %       app.setPosition(100, 100, 1080, 720);
            %       app.open();
            x = com.mathworks.util.ResolutionUtils.scaleSize(x);
            y = com.mathworks.util.ResolutionUtils.scaleSize(y);
            width = com.mathworks.util.ResolutionUtils.scaleSize(width);
            height = com.mathworks.util.ResolutionUtils.scaleSize(height);
            loc = com.mathworks.widgets.desk.DTLocation.createExternal( int16(x), int16(y), int16(width), int16(height));
            this.Peer.setPosition(loc);
        end
        
        %% figure management
        function successful = addFigure(this, fig)
            % Method "addFigure": 
            %
            %   Add a figure to ToolGroup as a document client. If the figure already
            %   exists in the ToolGroup, it will be made active and brought to front.
            %
            %   If you want to add a figure with contextual tabgroup, use
            %   "addclientTabGroup" instead.            
            %
            %   This method must be called after app opens.
            %
            %   Example:
            %       addFigure(this, fig);
            %   where "fig" is a MATLAB figure object (NOT a UI figure).
            hWarn = ctrlMsgUtils.SuspendWarnings('MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); %#ok<NASGU>
            jf = get(fig, 'JavaFrame');
            if isempty(jf)
				% TO DO: support figure with new rendering mechanism such as uiaxes
				fprintf('UI figure cannot be added to "ToolGroup".  Use regular figure instead.\n')
                successful = false;
            else            
                if strcmp(jf.getGroupName(),this.Name)
                    % if figure is already added, simply bring it to front
                    if strcmp(get(fig,'NumberTitle'),'off') || strcmp(get(fig,'IntegerHandle'),'off')
                        this.showClient(fig.Name);
                    else
                        md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                        titles = cell(md.getClientTitles);
                        found = find(~cellfun(@isempty, regexp(titles,[num2str(fig.Number) ': ' fig.Name])));
                        if ~isempty(found)
                            this.showClient(titles{found(1)});
                        end
                    end
                    successful = false;
                else
                    % otherwise, add it
                    set(fig, 'MenuBar', 'none')
                    set(fig, 'ToolBar', 'none')
                    md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                    jf.setDesktopGroup(md, this.Name)
                    set(fig, 'WindowStyle', 'Docked')
                    this.FiguresDropTargetHandler.registerInterest(handle(fig));
                    successful = true;
                end
            end
        end
        
        function r = getFiguresDropTargetHandler(this)
            % Method "getFiguresDropTargetHandler": 
            %
            %   Return  FiguresDropTargetHandler that enables drop and drop
            %   from browser to figure.
            %
            %   Example:
            %       getFiguresDropTargetHandler(this);
            r = this.FiguresDropTargetHandler;
        end
        
        %% contextual tab group management
        function addClientTabGroup(this, client, tabgroup)
            % Method "addClientTabGroup": 
            %
            %   Add a new figure with contextual tabgroup to ToolGroup as a document
            %   client.  If the figure already exists in the ToolGroup, it will be made
            %   active and brought to front.
            %
            %   If you want to add a figure without contextual tabgroup, use
            %   "addFigure" instead.            
            %
            %   This method must be called after app opens.
            %
            %   Example:
            %       addClientTabGroup(this, fig, tabgroup)
            %   where:
            %       "fig" is a MATLAB figure object (NOT a UI figure)
            %       "tabgroup" must be a "matlab.ui.internal.toolstrip.TabGroup" object
            
            % disable listeners
            this.AttributeListener.Enabled = 'off';
            this.ClientListener.Enabled = 'off';
            % add figure
            successful = this.addFigure(client);
            if successful
                % update client map
                this.setClientTabGroup(client, tabgroup);
                % make it active client and add contextual tabs
                this.setActiveClient(client);
                % one listener sufficient to handle actions from all clients
                if isempty(this.ClientActionListener) 
                    this.ClientActionListener = addlistener(this, 'ClientAction', @(hSrc,hData) handleClientModes(this,hData));
                end
            end
            % enable listeners
            this.AttributeListener.Enabled = 'on';
            this.ClientListener.Enabled = 'on';
        end
        
        function removeClientTabGroup(this, client)
            % Method "removeClientTabGroup": 
            %
            %   Remove the contextual tabgroup associated with a client
            %   figure.
            %
            %   Example:
            %       removeClientTabGroup(this, fig);
            %   where:
            %       "fig" is a MATLAB figure object (NOT a UI figure).
            
            % make client inactive
            if isvalid(this)
                if this.ActiveClient == client
                    setActiveClient(this, []);
                end
            end
            % delete entry from the client-tabgroup map
            k = findClientIndex(this,client);
            % act only if the client has a contextual tabgroup
            if k > 0
                this.ClientMap(k,:) = [];
            end
            if isvalid(this)
                % delete listener when no clients left
                if isempty(this.ClientMap)
                    delete(this.ClientActionListener)
                    this.ClientActionListener = [];
                end
            end
        end
        
        %% client display management
        function value = isClientShowing(this, name)
            % Method "isClientShowing": 
            %
            %   Returns true if the client with the given name or title
            %   is currently being shown by the desktop.  The fact the a
            %   client is "showing" in the desktop doesn't mean it is
            %   actually visible on screen.  It may be in a tabbed pane or
            %   in a minimized frame.
            %
            %   Example:
            %       value = isClientShowing(this, name)
            %   where "name" is a string such as a figure name.
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            value = md.isClientShowing(name, this.Name);
        end
        
        function showClient(this, name)
            % Method "showClient": 
            %
            %   Shows and activates a client component referenced by its
            %   name or title.
            %
            %   Example:
            %       showClient(this, name)
            %   where "name" is a string such as a figure name.
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.showClient(name, this.Name);
        end
       
    end
    
    methods (Hidden)

        function jh = getToolstripSwingComponent(this, comp)
            jh = this.ToolstripSwingService.Registry.getWidgetById(comp.getId());
        end
        
    end
    
    methods (Access = private)

        function refreshToolGroup(this)
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f = md.getFrameContainingGroup(this.Name);
            javaMethodEDT('validate', f)
            javaMethodEDT('repaint', f)    
        end
        
        function refreshDisplayState(this)
            % Invoked by MGG event only
            if ~isempty(this.SwingToolstrip)
                switch lower(this.MCOSToolstrip.DisplayState)
                    case 'expanded'
                        value = javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','EXPANDED');
                    case 'collapsed'
                        value = javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','COLLAPSED');
                    case 'expanded_on_top'
                        value = javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','EXPANDED_AS_POPUP');
                end
                javaMethodEDT('setAttribute',this.SwingToolstrip,com.mathworks.toolstrip.Toolstrip.STATE,value);
            end
        end
        
        function refreshTabSelection(this)
            % Invoked by MGG event only
            if ~isempty(this.MCOSToolstrip.SelectedTab)
                if ~strcmp(this.MCOSToolstrip.SelectedTab.Tag,this.Peer.getCurrentTab())
                    this.Peer.setCurrentTab(this.MCOSToolstrip.SelectedTab.Tag);
                end
            end
        end
        
        function OK = isToolGroupValid(this)
            jDefaultToolGroup = this.Peer.getWrappedComponent();
            jToolstrip = jDefaultToolGroup.getToolstrip();
            OK = ~isempty(jToolstrip);
        end    
        
        function addAttributeListener(this, fcn)
            % Do not modify. Use as is to prevent Java memory leaks.
            this.AttributeListener = addlistener(this.Peer.getAttributeCallback, 'delayed', fcn);
        end
        
        function addClientListener(this, fcn)
            % Do not modify. Use as is to prevent Java memory leaks.
            this.ClientListener = addlistener(this.Peer.getClientCallback, 'delayed', fcn);
        end
        
        function addGroupListener(this, fcn)
            % Do not modify. Use as is to prevent Java memory leaks.
            this.GroupListener = addlistener(this.Peer.getGroupCallback, 'delayed', fcn);
        end
		
%% The following code will be enabled after addTabs/removeTabs are available from swing ToolgroupWraper         
%         function addTabs(this, tabgroup)
%             % only the new tabs are added
%             list = getTabList(this.Peer.getWrappedComponent()); 
%             jtabs = javaArray('com.mathworks.toolstrip.DefaultToolstripTab',0);
%             for i = 1:length(tabgroup.Children)
%                 tab_id = tabgroup.Children(i).getId();
%                 jtab = this.ToolstripSwingService.Registry.getWidgetByPollingId(tab_id);
%                 if list.contains(jtab)
%                     continue;
%                 else
%                     jtabs(i) = jtab;
%                 end
%             end
%             if ~isempty(jtabs)
%                 this.Peer.addTabs(jtabs);
%             end
%         end
%         
%         function removeTabs(this, tabgroup)
%             list = getTabList(this.Peer.getWrappedComponent()); 
%             jtabs = javaArray('com.mathworks.toolstrip.DefaultToolstripTab',length(tabgroup.Children));
%             for i = 1:length(tabgroup.Children)
%                 tab_id = tabgroup.Children(i).getId();
%                 jtab = this.ToolstripSwingService.Registry.getWidgetByPollingId(tab_id);
%                 if list.contains(jtab)
%                     jtabs(i) = jtab;
%                 else
%                     error(message('MATLAB:toolstrip:container:failedTabNotFound',tabgroup.Children(i).Tag));
%                 end
%             end
%             this.Peer.removeTabs(jtabs);
%         end
        
        function addTabs(this, tabgroup)
            list = getTabList(this.Peer.getWrappedComponent()); 
            for i = 1:length(tabgroup.Children)
                tab_id = tabgroup.Children(i).getId();
                jtab = this.ToolstripSwingService.Registry.getWidgetByPollingId(tab_id);
                if ~list.contains(jtab)
                    this.Peer.add(jtab);
                end
            end
        end
        
        function removeTabs(this, tabgroup)
            list = getTabList(this.Peer.getWrappedComponent()); 
            for i = 1:length(tabgroup.Children)
                tab_id = tabgroup.Children(i).getId();
                jtab = this.ToolstripSwingService.Registry.getWidgetByPollingId(tab_id);
                if list.contains(jtab)
                    this.Peer.remove(jtab);
                end
            end
        end
        
        function tabgroup = getClientTabGroup(this, client)
            % Returns the tab group associated with a client (figure) or []
            % if the client does not have a contextual tabgroup.
            k = findClientIndex(this,client);
            if k > 0
                tabgroup = this.ClientMap{k,2};
            else
                tabgroup = [];
            end
        end
        
        function setClientTabGroup(this, client, tabgroup)
            % Associate the tab group for the specified client using the
            % 1:1 client map.  Replace if there is an existing tab group
            % associated with the client.
            k = findClientIndex(this,client);
            if k>0
                % replace in existing entry but do not change selected tab
                this.ClientMap{k,2} = tabgroup;
            else
                % new entry
                this.ClientMap = [this.ClientMap; {client, tabgroup, ''}];
            end
        end
        
        function setActiveClient(this, client)
            % make an inactive client active or an active client inactive
            if isempty(client)
                % client is [], which removes the current active client
                if ~isempty(this.ActiveClient)
                    % remove tab group of the old active client
                    oldtabgroup = this.getClientTabGroup(this.ActiveClient);
                    removeTabGroup(this, oldtabgroup);
                end
            else
                % activate a new active client
                newtabgroup = this.getClientTabGroup(client);
                if ~isempty(this.ActiveClient)
                    % if there is a current active client, remove it first
                    if (this.ActiveClient ~= client)
                        % remove tab group of the old active client
                        oldtabgroup = this.getClientTabGroup(this.ActiveClient);
                        removeTabGroup(this, oldtabgroup);
                        % add new client's tabs
                        addTabGroup(this, newtabgroup);
                        % Update selected tab from tab group or client map
                        k = findClientIndex(this, client);
                        % act only if the client has a contextual tabgroup
                        if k > 0
                            if ~isempty(newtabgroup.SelectedTab)
                                this.SelectedTab = newtabgroup.SelectedTab.Tag;
                            elseif ~isempty(this.ClientMap{k,3})
                                this.SelectedTab = this.ClientMap{k,3};
                            else
                                this.ClientMap{k,3} = this.SelectedTab;
                            end
                        end
                    end
                else
                    % if there is no current active client, add the new one
                    addTabGroup(this, newtabgroup);
                    % Update selected tab from tab group or client map.
                    k = findClientIndex(this, client);
                    % act only if the client has a contextual tabgroup
                    if k > 0
                        if ~isempty(newtabgroup.SelectedTab)
                            this.SelectedTab = newtabgroup.SelectedTab.Tag;
                        elseif ~isempty(this.ClientMap{k,3})
                            this.SelectedTab = this.ClientMap{k,3};
                        else
                            this.ClientMap{k,3} = this.SelectedTab;
                        end
                    end
                end
            end
            % store new active client
            this.ActiveClient = client;
        end
        
        function index = findClientIndex(this, client)
            % Returns the index of the client in the ClientMap, which
            % implies that the client has a contextual tab group. If
            % returned 0, it implies that the client does not have a
            % contextual tab group.
            index = 0;
            if isvalid(this)
                for k = 1:size(this.ClientMap,1)
                    if this.ClientMap{k,1} == client
                        index = k;
                        return
                    end
                end
            end
        end
    
        function handleClientModes(this, hData)
            % Handle contextual tabs in response to client action events.
            data = hData.EventData;
            client = data.Client;
            % Only a valid figure client action can change contextual tabs
            if isempty(client) || ~isvalid(client)
                return
            end
            if strcmp(data.EventType, 'ACTIVATED')
                % disable selected tab listener
                if isvalid(this)
                    this.AttributeListener.Enabled = 'off';
                end
                if isvalid(this)
                    k = findClientIndex(this, client);
                    if k>0
                        % the client has contextual tabgroup, replace the
                        % current one
                        setActiveClient(this, client);
                    else
                        % the client does not have a contextual tabgroup,
                        % remove the current one if any
                        setActiveClient(this, []);
                    end
                end
                % enable selected tab listener
                if isvalid(this)
                    this.AttributeListener.Enabled = 'on';
                end
            elseif strcmp(data.EventType, 'CLOSED')
                % Remove the closing client's tab group
                k = findClientIndex(this, client);
                % act only if the client has a contextual tabgroup
                if k > 0
                    % disable selected tab listener
                    if isvalid(this)
                        this.AttributeListener.Enabled = 'off';
                    end
                    % remove client tab group
                    this.removeClientTabGroup(client);
                    % enable selected tab listener
                    if isvalid(this)
                        this.AttributeListener.Enabled = 'on';
                    end
                end
            end
        end
        
    end
    
end

% ------------------------------------------------------------------------------
function handleAttribute(~,ed,toolgroup)
    % SELECTED_TAB attribute has changed by the swing widget.
    % This callback might be triggered by (1) user selects a new tab from
    % the toolstrip, or (2) the selected tab is programmatically removed
    % (i.e. by closing a figure)
    % Note: "ToolGroup.SelectedTab" always reflects swing tab selection
    
    % get old and new tabs
    oldtabname = char(ed.getOldValue);
    newtabname = char(ed.getNewValue);
    if isempty(oldtabname)
        oldtab = [];
    else
        oldtab = toolgroup.MCOSToolstrip.find(oldtabname);
    end
    if isempty(newtabname)
        newtab = [];
    else
        newtab = toolgroup.MCOSToolstrip.find(newtabname);
    end
    % disp(['old tab: ' oldtabname ', new tab: ' newtabname])
    % if oldtab is empty, the tab is being removed and it triggers an
    % event of automatic selection of the tab to its left by built-in
    % swing behavior.  In this special case, do nothing because another
    % event will come and select the home tab.
    if ~isempty(oldtab) && ~isempty(newtab)
        % get the tabgroups they belong to
        oldtabgroup = oldtab.Parent;
        newtabgroup = newtab.Parent;
        % set SelectedTab based on different scenarios
        if oldtabgroup == newtabgroup
            % when selection change happens in the same tabgroup
            oldtabgroup.SelectedTab = newtab;
            % send out tabgroup SelectedTabChanged event                    
            oldtabgroup.sendSelectedTabChangedEvent(oldtab,newtab);
        else
            % when selection change happens in two tabgroups
            oldtabgroup.SelectedTab = [];
            newtabgroup.SelectedTab = newtab;
            % send out tabgroup SelectedTabChanged event                    
            oldtabgroup.sendSelectedTabChangedEvent(oldtab,[]);
            newtabgroup.sendSelectedTabChangedEvent([],newtab);
        end
        % Update selected tab name in ClientMap    
        if ~isempty(toolgroup.ActiveClient)
            k = findClientIndex(toolgroup, toolgroup.ActiveClient);
            % act only if the client has a contextual tabgroup
            if k > 0
                toolgroup.ClientMap{k,3} = newtabname;
            end
        end        
    end
end

function handleClientAction(~,ed,obj)
	types = { ...
		'ACTIVATING', 'ACTIVATED', 'DEACTIVATED', 'DOCKING', ...
		'DOCKED', 'UNDOCKING', 'UNDOCKED', 'RELOCATED', ...
		'RESIZED', 'OPENED', 'CLOSING', 'CLOSED'};
	c = ed.getClient;
	title = char(javaMethodEDT('getClientProperty',c,com.mathworks.widgets.desk.DTClientProperty.TITLE));
    % disp(['Client "' title '" event: ' types{ed.getType}])
	data = struct( ...
		'Client', utGetFigureHandleFromClient(c), ...
		'ClientName', char(javaMethodEDT('getName',c)), ...
		'ClientTitle', title, ...
		'EventType', types{ed.getType});
	obj.notify('ClientAction', matlab.ui.internal.toolstrip.base.ToolstripEventData(data))
end

function handleGroupAction(~,ed,obj)
    types = { ...
        'ACTIVATING', 'ACTIVATED', 'DEACTIVATED', 'DOCKING', ...
        'DOCKED', 'UNDOCKING', 'UNDOCKED', 'RELOCATED', ...
        'RESIZED', 'OPENED', 'CLOSING', 'CLOSED'};
    g = ed.getPropertyProvider;
    data = struct( ...
        'GroupName', char(g.getGroupName), ...
        'GroupTitle', char(g.getGroupTitle), ...
        'EventType', types{ed.getType});
    obj.notify('GroupAction', matlab.ui.internal.toolstrip.base.ToolstripEventData(data))
end

function fig = utGetFigureHandleFromClient(client)
    % Finds the figure that has the specified client or return empty if there is no
    % matching figure.
    hWarn = ctrlMsgUtils.SuspendWarnings('MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); %#ok<NASGU>
    ch = allchild(0);
    cls = 'com.mathworks.hg.peer.FigureClientProxy$FigureDTClientBase';
    for i = 1:length(ch)
        fig = ch(i);
        jf = get(fig, 'JavaFrame');
        if isempty(jf)
            % TO DO: support uifigure
        else            
            c = javaMethodEDT('getFigurePanelContainer',jf);
            while ~( isempty(c) || isa(c,cls) )
                % Move up the hierarchy to find a figure client or a component with no
                % parent.
                c = javaMethodEDT('getParent',c);
            end
            if isequal(c, client)
                % Found figure with matching client. Return with current FIG handle.
                return
            end
        end
    end
    % No figure has a matching client.
    fig = [];
end
