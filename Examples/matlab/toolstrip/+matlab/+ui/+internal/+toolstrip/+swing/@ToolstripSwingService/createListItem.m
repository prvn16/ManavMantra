function createListItem(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    name = widget_node.getProperty('tag');
    if isempty(name)
        name = char(java.util.UUID.randomUUID);
    end
    jh = javaObjectEDT('com.mathworks.toolstrip.components.popups.ListItem',name);
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% get action peer node
    action_node = getActionNodeFromWidgetNode(this, widget_node);
    %% initialize swing component properties
    % style
    value = widget_node.getProperty('showDescription');    
    if value
        jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.STYLE, com.mathworks.toolstrip.components.popups.ListStyle.ICON_TEXT_DESCRIPTION);    
    else
        jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.STYLE, com.mathworks.toolstrip.components.popups.ListStyle.ICON_TEXT);    
    end
    % description
    value = action_node.getProperty('description');
    jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.DESCRIPTION, java.lang.String(value));
    % enabled
    value = action_node.getProperty('enabled');
    jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.ENABLED_STATE, value);
    % text
    value = action_node.getProperty('text');
    jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.TITLE, java.lang.String(value));
    % icon
    value = getImageIcon(this,action_node); % [] if not specified
    jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.ICON, value);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

function propertySetCallback(src, data, this, widget_id)
    % check originator
    originator = data.getOriginator();
    % set property value ONLY If it is a MCOS driven event
    if isa(originator, 'java.util.HashMap') && strcmp(originator.get('source'),'MCOS')
        % get data
        hashmap = data.getData();
        structure = matlab.ui.internal.toolstrip.base.Utility.convertFromHashmapToStructure(hashmap);
        % get swing widget
        jh = this.Registry.getWidgetById(widget_id);    
        value = structure.newValue;
        % set swing property
        switch structure.key
            case 'description'
                jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.DESCRIPTION, java.lang.String(value));
            case 'enabled'
                jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.ENABLED_STATE, value);
            case 'text'
                jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.TITLE, java.lang.String(value));
            case 'icon'
                icon = getImageIcon(this,src); % [] if not specified
                jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.ICON, icon);
            case 'showDescription'
                if value
                    jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.STYLE, com.mathworks.toolstrip.components.popups.ListStyle.ICON_TEXT_DESCRIPTION);    
                else
                    jh.setAttribute(com.mathworks.toolstrip.components.popups.ListItem.STYLE, com.mathworks.toolstrip.components.popups.ListStyle.ICON_TEXT);    
                end
        end
    end
end



