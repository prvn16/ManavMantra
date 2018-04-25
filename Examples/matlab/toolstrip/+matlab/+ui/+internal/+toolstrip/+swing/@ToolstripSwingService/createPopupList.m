function createPopupList(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    model = javaObjectEDT('javax.swing.DefaultListModel');
    jh = javaObjectEDT('com.mathworks.toolstrip.components.popups.PopupList',model);
    %jh.setListStyle(com.mathworks.toolstrip.components.popups.ListStyle.SINGLE_LINE_DESCRIPTION);
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% initialize swing component properties
    % tag
    value = widget_node.getProperty('tag');
    jh.setName(value);
    %% register listeners to Swing driven events
    fcn = {@callbackListItemSelected, this};
    registerSwingListener(this, widget_node, jh, 'ListItemSelected', fcn);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, [], fcn);
end

function callbackListItemSelected(src, ~, this)
    % get swing list item
    jSelectedItem = src.getSelectedValue();
    % find widget node
    item_id = this.Registry.findIdByWidget(jSelectedItem);
    item_node = getWidgetNodeFromId(this, item_id);
    if ~isempty(item_node)
        % find action node
        action_id = char(item_node.getProperty('actionId'));
        action_node = getActionNodeFromId(this, action_id);
        % send out event
        if ~isempty(action_node)
            eventdata = java.util.HashMap;
            if jSelectedItem.getAttributes().getAttribute(com.mathworks.toolstrip.components.popups.ListItem.HAS_CHECKBOX)
                % list item with checkbox
                action_node.setProperty('selected',jSelectedItem.getAttributes().getAttribute(com.mathworks.toolstrip.components.popups.ListItem.CHECKVALUE_STATE));
            else
                % list item
                eventdata.put('eventType','itemPushed');
                action_node.dispatchPeerEvent('peerEvent',action_node,eventdata);
            end
        end
    end
end

function propertySetCallback(~, data, this, widget_id)
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
            case 'tag'
                jh.setName(value);
        end
    end
end

