classdef (Sealed) ToolstripSwingService < handle
    % Toolstrip server side service for swing rendering.
    
    % Author(s): Rong Chen
    % Copyright 2014 The MathWorks, Inc.
    
    properties
        ChildAddedListener
        ChildMovedListener
        Registry
        PeerModelChannel
        ActionChannel
    end
    
    properties (Hidden)
        IsDebug
        SwingToolGroup
    end
    
    events
        RefreshToolGroup
    end
    
    methods
        
        function this = ToolstripSwingService(channel)
            % ToolstripSwingService is used together with ToolGroup. The
            % peer model does not contain any toolstrip node because it is
            % a built-in component of the Swing ToolGroup. All the
            % operations such as add/remove a tabgroup to/from the
            % toolstrip is handled directly on the ToolGroup code.
            this.IsDebug = false;
            % ensure connector is on
			if ~matlab.ui.internal.desktop.isMOTW()
				connector.ensureServiceOn;
			end
            % create registry, one per channel
            this.Registry = matlab.ui.internal.toolstrip.swing.registry();
            % create peer model channel and add listeners to peer events
            this.PeerModelChannel = channel;
            manager = matlab.ui.internal.toolstrip.base.ToolstripService.initialize(channel);
            this.ChildAddedListener = addlistener(manager.getByType('OrphanRoot').get(0),'ChildAdded',@(x,y) compCreated(this,x,y));
            this.ChildMovedListener = addlistener(manager,'ChildMoved',@(x,y) compAddedRemoved(this,x,y));
            % create action channel
            this.ActionChannel = [channel '_Action'];
            matlab.ui.internal.toolstrip.base.ActionService.initialize(this.ActionChannel);
        end
        
        function delete(this)
            this.Registry.reset();
        end
        
        function compCreated(this, ~, data)
            % Build swing component when node created under "OrphanRoot" 
            % Yhe top container is TabGroup, not Toolstrip 
            
            % get event data
            hashmap = data.getData();
            % get type
            node = hashmap.get('child');
            type = char(node.getType());
            % create swing component based on type and attach listeners
            switch type
                %% containers
                case 'Toolstrip'
                    this.createToolstrip(node);
                case 'TabGroup'
                    this.createTabGroup(node);
                case 'Tab'
                    this.createTab(node);
                case 'Section'
                    this.createSection(node);
                case 'Column'
                    this.createColumn(node);
                case 'Panel'
                    this.createPanel(node);
                case 'PopupList'
                    this.createPopupList(node);
                case 'GalleryPopup'
                    this.createGalleryPopup(node);
                case 'GalleryCategory'
                    this.createGalleryCategory(node);
                %% controls
                case 'CheckBox'
                    this.createCheckBox(node);
                case 'ComboBox'
                    this.createComboBox(node);
                case 'DropDownButton'
                    % if popup is gallery popup, create drop down button
                    % with special handling, otherwise, normal drop down
                    % button.
                    if node.hasProperty('popupType') 
                        this.createDropDownGalleryButton(node);
                    else
                        this.createDropDownButton(node);
                    end
                case 'EmptyControl'
                    this.createEmptyControl(node);
                case 'Gallery'
                    this.createGallery(node);
                case 'GalleryItem'
                    this.createGalleryItem(node);
                case 'Label'
                    this.createLabel(node);
                case 'List'
                    this.createList(node);
                case 'ListItem'
                    this.createListItem(node);
                case 'ListItemWithCheckBox'
                    this.createListItemWithCheckBox(node);
                case 'ListItemWithPopup'
                    this.createListItemWithPopup(node);
                case 'PopupListHeader'
                    this.createPopupListHeader(node);
                case 'PushButton'
                    this.createPushButton(node);
                case 'RadioButton'
                    button_group_name = this.getActionNodeFromWidgetNode(node).getProperty('buttonGroupName');
                    if this.Registry.ButtonGroupMap.isKey(button_group_name)
                        button_group_java_obj = this.Registry.ButtonGroupMap(button_group_name);
                    else
                        button_group_java_obj = javaObjectEDT('javax.swing.ButtonGroup');
                        this.Registry.register('ButtonGroup', button_group_name, button_group_java_obj);
                    end                                        
                    this.createRadioButton(node, button_group_java_obj);                        
                case 'HorizontalSlider'
                    this.createSlider(node);
                case 'Spinner'
                    this.createSpinner(node);
                case 'SplitButton'
                    this.createSplitButton(node);
                case 'TextArea'
                    this.createTextArea(node);
                case 'TextField'
                    this.createTextField(node);
                case 'ToggleButton'
                    button_group_name = this.getActionNodeFromWidgetNode(node).getProperty('buttonGroupName');
                    if isempty(button_group_name)
                        this.createToggleButton(node);
                    else
                        if this.Registry.ButtonGroupMap.isKey(button_group_name)
                            button_group_java_obj = this.Registry.ButtonGroupMap(button_group_name);
                        else
                            button_group_java_obj = javaObjectEDT('javax.swing.ButtonGroup');
                            this.Registry.register('ButtonGroup', button_group_name, button_group_java_obj);
                        end                           
                        this.createToggleButton(node, button_group_java_obj);
                    end                        
                case 'ToggleGalleryItem'
                    button_group_name = this.getActionNodeFromWidgetNode(node).getProperty('buttonGroupName');
                    if isempty(button_group_name)
                        this.createToggleGalleryItem(node);
                    else
                        if this.Registry.ButtonGroupMap.isKey(button_group_name)
                            button_group_java_obj = this.Registry.ButtonGroupMap(button_group_name);
                        else
                            button_group_java_obj = javaObjectEDT('com.mathworks.mlwidgets.util.ActionGroup');
                            this.Registry.register('ButtonGroup', button_group_name, button_group_java_obj);
                        end                           
                        this.createToggleGalleryItem(node, button_group_java_obj);
                    end                    
            end
            % 
            if this.IsDebug
                disp(['create ' type]);
            end
            % register node destroyed listener
            widget_id = char(node.getId());
            Ldestroyed_widget = addlistener(node,'destroyed',@(x,y) widgetDestroyed(this,x,y,widget_id));
            this.Registry.register('ServerListener',widget_id,Ldestroyed_widget);            
        end

        function compAddedRemoved(this, ~, data)
            % Add/remove swing component when node is moved between the
            % "OrphanRoot" node and the "parent" node
            
            % get event data
            hashmap = data.getData();
            % get child
            child_id = char(data.getSource().getId());
            % get new parent and index
            parent = hashmap.get('newParent');
            parent_id = char(parent.getId());
            % get new parent type
            parent_type = char(parent.getType());
            if strcmp(parent_type, 'OrphanRoot')
                %% remove a widget (from current parent to orphan root)
                oldparent = hashmap.get('oldParent');
                oldparent_id = char(oldparent.getId());
                oldparent_type = char(oldparent.getType());
                switch oldparent_type
                    case 'Toolstrip'
                        % remove a tab group
                        if isempty(this.SwingToolGroup)
                            % If toolstrip is not part of toolgroup, use
                            % standard procedure
                            jc = this.Registry.getWidgetById(child_id);
                            jp = this.Registry.getWidgetById(oldparent_id);
                            jp.removeTabGroup(jc);
                        else
                            % If toolstrip is part of toolgroup, tabs are
                            % already removed directly in "removeTabGroup".
                            % It is null op here because swing tab group is
                            % not a child of swing toolstrip
                        end
                    case 'TabGroup'
                        % remove a tab
                        jc = this.Registry.getWidgetById(child_id);
                        if isempty(this.SwingToolGroup)
                            % If toolstrip is not part of toolgroup, use
                            % standard procedure
                            jp = this.Registry.getWidgetById(oldparent_id);
                            jp.remove(jc);
                        else
                            % If toolstrip is part of toolgroup, explicitly
                            % remove the tab using toolgroup API only if
                            % tool group is part of the toolstrip
                            manager = matlab.ui.internal.toolstrip.base.ToolstripService.get(this.PeerModelChannel);
                            tgnode = manager.getById(oldparent_id);
                            tsnode = tgnode.getParent();
                            if strcmp(char(tsnode.getType()),'Toolstrip')
                                this.SwingToolGroup.remove(jc);                            
                            end
                        end
                    case 'GalleryPopup'
                        % remove a gallery category
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(oldparent_id);
                        javaMethodEDT('removeCategory',jp,jc);
                    case 'GalleryCategory'
                        % remove a gallery item
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(oldparent_id);
                        popup_id = getParentIdByChildId(this, oldparent_id);
                        jpopup = this.Registry.getWidgetById(popup_id);
                        javaMethodEDT('removeItem',jpopup,jp,jc);
                    case {'QABRoot','QuickAccessBar','QuickAccessGroup'}
                        % null op
                    case {'PopupRoot','GalleryPopupRoot','GalleryFavoriteCategoryRoot'}
                        % null op
                    otherwise
                        % default
                        if this.Registry.hasWidgetById(child_id) && this.Registry.hasWidgetById(oldparent_id)
                            jc = this.Registry.getWidgetById(child_id);
                            jp = this.Registry.getWidgetById(oldparent_id);
                            jp.remove(jc);
                        end
                end
                if this.IsDebug
                    disp(['remove from ' oldparent_type]);
                end
            else
                %% add a widget (from orphan root to a parent)
                switch parent_type
                    case 'Toolstrip' 
                        % add a tabgroup (no insertion)
                        if isempty(this.SwingToolGroup)
                            % If toolstrip is not part of toolgroup, use
                            % standard procedure
                            jc = this.Registry.getWidgetById(child_id);
                            jp = this.Registry.getWidgetById(parent_id);
                            addTabGroup(jp, jc);
                        else
                            % If toolstrip is part of toolgroup, tabs are
                            % already added either directly in
                            % "addTabGroup" (when tab is already part of
                            % tabgroup) or when tab is added to tabgroup
                            % below. It is null op here (because swing tab
                            % group is not a child of swing toolstrip in
                            % toolgroup)
                        end
                    case 'TabGroup'
                        % add/insert a tab
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        if isempty(this.SwingToolGroup)
                            % If toolstrip is not part of toolgroup, use
                            % standard procedure
                            add(jp,hashmap.get('newIndex'),jc);
                        else
                            % If toolstrip is part of toolgroup, explicitly
                            % add the tab using toolgroup API only if
                            % tabgroup is already added to toolstrip.
                            %
                            % special handling of the index because it is
                            % relative to the tab group, not toolstrip
                            manager = matlab.ui.internal.toolstrip.base.ToolstripService.get(this.PeerModelChannel);
                            tgnode = manager.getById(parent_id);
                            tsnode = tgnode.getParent();
                            if strcmp(char(tsnode.getType()),'Toolstrip')
                                num = 0;
                                for ct=1:tsnode.getNumberOfChildren()
                                    if tsnode.getChild(ct-1)~=tgnode
                                        num = num + tsnode.getChild(ct-1).getNumberOfChildren();
                                    else
                                        break;
                                    end
                                end
                                this.SwingToolGroup.add(jc,num+hashmap.get('newIndex'));
                            end
                        end
                    case 'Tab'
                        % add a section (no insertion)
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        add(jp.getModel(), jc);
                    case 'Section'
                        % add a column (no insertion)
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        add(jp, jc);
                    case 'Column' 
                        % add a control (no insertion)
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        % adjust for button orientation when applicable
                        existing = jp.getChildren();
                        if existing.isEmpty()
                            % if the added button is the first control in
                            % the column, it has to be a vertical button
                            if ismember(class(jc),{'com.mathworks.toolstrip.components.TSButton','com.mathworks.toolstrip.components.TSDropDownButton','com.mathworks.toolstrip.components.TSSplitButton','com.mathworks.toolstrip.components.TSToggleButton'})                            
                                jc.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                            end
                        else
                            % if the added control is not the first control
                            % in the column, update the first control.
                            first = existing.get(0);
                            if ismember(class(first),{'com.mathworks.toolstrip.components.TSButton','com.mathworks.toolstrip.components.TSDropDownButton','com.mathworks.toolstrip.components.TSSplitButton','com.mathworks.toolstrip.components.TSToggleButton'})
                                % if first control is a button, change it
                                % to horizontal
                                first.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.HORIZONTAL);
                            elseif isa(first,'com.mathworks.toolstrip.components.TSPanel')
                                % if first control is a panel, change any
                                % button in the panel to horizontal
                                for i=1:first.getComponentCount()
                                    col = first.getComponent(i-1);
                                    controls = col.getChildren();
                                    for j=1:length(controls)
                                        control = controls.get(j-1);
                                        if ismember(class(control),{'com.mathworks.toolstrip.components.TSButton','com.mathworks.toolstrip.components.TSDropDownButton','com.mathworks.toolstrip.components.TSSplitButton','com.mathworks.toolstrip.components.TSToggleButton'})
                                            control.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.HORIZONTAL);
                                        end
                                    end
                                end
                            end
                            % if the added control is not the first control
                            % in the column and it is a button, make it
                            % horizontal
                            if ismember(class(jc),{'com.mathworks.toolstrip.components.TSButton','com.mathworks.toolstrip.components.TSDropDownButton','com.mathworks.toolstrip.components.TSSplitButton','com.mathworks.toolstrip.components.TSToggleButton'})                            
                                jc.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.HORIZONTAL);
                            end
                            % if the added control is not the first control
                            % in the column and it is a panel, make any
                            % button in the panel to horizontal
                            if isa(jc,'com.mathworks.toolstrip.components.TSPanel')
                                for i=1:jc.getComponentCount()
                                    col = jc.getComponent(i-1);
                                    controls = col.getChildren();
                                    for j=1:length(controls)
                                        control = controls.get(j-1);
                                        if ismember(class(control),{'com.mathworks.toolstrip.components.TSButton','com.mathworks.toolstrip.components.TSDropDownButton','com.mathworks.toolstrip.components.TSSplitButton','com.mathworks.toolstrip.components.TSToggleButton'})
                                            control.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.HORIZONTAL);
                                        end
                                    end
                                end
                            end
                        end
                        if isa(jc,'com.mathworks.toolstrip.components.TSTextArea') || isa(jc,'com.mathworks.toolstrip.components.TSList')
                            jc = javaObjectEDT('com.mathworks.toolstrip.components.TSScrollPane', jc);
                        end
                        add(jp, jc);
                    case 'Panel' 
                        % add a panel to a column (no insertion)
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        add(jp, jc);
                    case 'PopupList'
                        % add/insert a list item
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        model = jp.getModel();
                        add(model, hashmap.get('newIndex'), jc);
                    case 'GalleryPopup'
                        % add/insert a gallery category
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        oldparent = hashmap.get('oldParent');
                        oldparent_type = char(oldparent.getType());
                        % add a gallery category if necessary
                        if strcmp(oldparent_type,'OrphanRoot')
                            javaMethodEDT('addCategory',jp,jc);
                        end
                        % move a gallery category
                        % use index+1 because the first category is always favorite
                        javaMethodEDT('moveCategory',jp,jc,hashmap.get('newIndex')+1);
                    case 'GalleryCategory'
                        % add/insert a gallery item
                        jc = this.Registry.getWidgetById(child_id);
                        jp = this.Registry.getWidgetById(parent_id);
                        popup_id = getParentIdByChildId(this, parent_id);
                        jpopup = this.Registry.getWidgetById(popup_id);
                        oldparent = hashmap.get('oldParent');
                        oldparent_type = char(oldparent.getType());
                        % add a gallery item if necessary
                        if strcmp(oldparent_type,'OrphanRoot')
                            javaMethodEDT('addItem',jpopup,jp,jc);
                        end
                        % move a gallery item
                        javaMethodEDT('moveItem',jpopup,jp,jc,hashmap.get('newIndex'));
                    otherwise
                        % 'ToolstripRoot'
                        % 'QABRoot'
                        % 'PopupRoot'
                        % 'GalleryPopupRoot'
                        % 'GalleryFavoriteCategoryRoot'
                        % 'QuickAccessBar'
                        % 'QuickAccessGroup'
                end
                if this.IsDebug
                    disp(['add to ' parent_type]);
                end
            end
                        
        end
        
        function widgetDestroyed(this, ~, ~, widget_id)
            this.Registry.unregister('Widget',widget_id);    
            this.Registry.unregister('ClientListener',widget_id);    
            this.Registry.unregister('ServerListener',widget_id);   
        end
        
        function cleanup(this)
            % clean up peer model channel (automatically unregister)
            com.mathworks.peermodel.PeerModelManagers.cleanup(this.PeerModelChannel);
        end
        
        function registerPeerNodeListener(this, widget_node, action_node, callbackPropertySet, callbackPeerEvent)
            %% add listener to MCOS driven events issued from peer node
            % Do not modify. Use as is to prevent Java memory leaks.
            L1 = addlistener(widget_node, 'propertySet', callbackPropertySet);
            if isempty(action_node)
                L2 = [];
            else
                L2 = addlistener(action_node,'propertySet', callbackPropertySet);
            end
            if nargin>4
                L3 = addlistener(widget_node,'peerEvent', callbackPeerEvent);
            else
                L3 = [];
            end
            widget_id = char(widget_node.getId());
            this.Registry.register('ServerListener',widget_id,[L1;L2;L3]);
        end
        
        function registerSwingListener(this, widget_node, varargin)
            %% add listener to Swing driven events
            % Do not modify. Use as is to prevent Java memory leaks.
            len = (nargin-2)/3;
            L = [];
            for ct = 1:len
                L = [L; addlistener(varargin{ct*3-2}, varargin{ct*3-1}, varargin{ct*3})]; %#ok<AGROW>
            end
            widget_id = char(widget_node.getId());
            this.Registry.register('ClientListener',widget_id,L);
        end
        
        function action_node = getActionNodeFromWidgetNode(this, widget_node)
            action_id = widget_node.getProperty('actionId');
            action_node = getActionNodeFromId(this, action_id);
        end
        
        function action_node = getActionNodeFromId(this, action_id)
            manager = matlab.ui.internal.toolstrip.base.ActionService.get(this.ActionChannel);
            if manager.hasById(action_id)
                action_node = manager.getById(action_id);            
            else
                action_node = [];
            end
        end
        
        function widget_node = getWidgetNodeFromId(this, widget_id)
            manager = matlab.ui.internal.toolstrip.base.ToolstripService.get(this.PeerModelChannel);
            if manager.hasById(widget_id)
                widget_node = manager.getById(widget_id);            
            else
                widget_node = [];            
            end
        end
        
        function parent_id = getParentIdByChildId(this, child_id)
            manager = matlab.ui.internal.toolstrip.base.ToolstripService.get(this.PeerModelChannel);
            child_node = manager.getById(child_id);            
            parent_node = getParent(child_node);
            parent_id = char(parent_node.getId());
        end
        
        % set slider value without firing event
        function setValueWithoutFiringEvent(this, Type, Model, Value) %#ok<INUSL>
            if strcmp(Type,'slider')
                str = 'javax.swing.JSlider$ModelListener';
            else
                str = 'javax.swing.JSpinner$ModelListener';
            end
            tmp = Model.getChangeListeners;
            for ct=1:length(tmp)
                if isa(tmp(ct),str)
                    Model.removeChangeListener(tmp(ct));
                end
            end
            javaMethodEDT('setValue',Model,Value);
            for ct=1:length(tmp)
                if isa(tmp(ct),str)
                    Model.addChangeListener(tmp(ct));
                end
            end
        end
        
        function value = getImageIcon(~, action_node)
            iconpath = char(action_node.getProperty('iconPath'));
            icon64 = char(action_node.getProperty('icon'));
            hasIcon = ~(isempty(icon64) && isempty(iconpath));
            if ~hasIcon
                % no icon
                value = [];
            elseif isempty(iconpath)
                if ~contains(icon64,'base64')
                    % from CSS, ignored for swing rendering
                    value = [];
                else
                    % from ImageIcon
                    value = matlab.ui.internal.toolstrip.Icon.getImageIconFromBase64(icon64);
                end
            else
                % from a file or built-in
                if ~contains(iconpath,'jar!')
                    value = javaObjectEDT('javax.swing.ImageIcon',iconpath);    
                else
                    value = javaObjectEDT('javax.swing.ImageIcon',java.net.URL(iconpath));
                end
            end
        end
        
        function setSwingTooltip(~,jh,value)
            if isempty(value)
                % use [] instead of '' for NULL expression
                javaMethodEDT('setToolTipText',jh,[]);
            else
                javaMethodEDT('setToolTipText',jh,value);
            end
        end
        
    end
    
end
