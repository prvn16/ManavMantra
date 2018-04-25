function createTextArea(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing object
    % force to have 4 rows (width is overwritten by column layout policy)
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSTextArea');
    %% register widget
    this.Registry.register('Widget', widget_id, jh);
    %% get action peer node
    action_node = getActionNodeFromWidgetNode(this, widget_node);    
    %% initialize swing component properties
    % text
    value = action_node.getProperty('text');
    jh.setText(value);
    % description
    value = action_node.getProperty('description');
    this.setSwingTooltip(jh,value);
    % enabled
    value = action_node.getProperty('enabled');
    jh.setEnabled(value);
    % editable
    value = action_node.getProperty('editable');
    jh.setEditable(value);
    % tag
    value = widget_node.getProperty('tag');
    jh.setName(value);
    %% register listeners to Swing driven events
    action_id = char(action_node.getId());
    cb = javaMethodEDT('getDocumentCallback','com.mathworks.mlwidgets.toolgroup.Utils',jh);    
    fcn1 = {@textChangedCallback, this, action_id, widget_id};
    fcn2 = {@textFocusLostCallback, this, action_id};
    fcn3 = {@textFocusGainedCallback, this, action_id};
    registerSwingListener(this, widget_node, cb, 'delayed', fcn1, jh, 'FocusLost', fcn2, jh, 'FocusGained', fcn3);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

function textChangedCallback(~, ~, this, action_id, widget_id)
    jh = this.Registry.getWidgetById(widget_id);    
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        action_node.setProperty('text',jh.getText());
    end
end

function textFocusLostCallback(src, ~, this, action_id)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        action_node.setProperty('text',src.getText());
        eventdata = java.util.HashMap;
        eventdata.put('eventType','FocusLost');
        eventdata.put('value',src.getText());
        action_node.dispatchPeerEvent('peerEvent',action_node,eventdata);
    end
end

function textFocusGainedCallback(src, ~, this, action_id)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        eventdata = java.util.HashMap;
        eventdata.put('eventType','FocusGained');
        eventdata.put('value',src.getText());
        action_node.dispatchPeerEvent('peerEvent',action_node,eventdata);
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
        switch structure.key
            case 'description'
                this.setSwingTooltip(jh,value);
            case 'enabled'
                jh.setEnabled(value);
            case 'text'
                jh.setText(value);
            case 'editable'
                jh.setEditable(value);
            case 'tag'
                jh.setName(value);
        end
    end
end 