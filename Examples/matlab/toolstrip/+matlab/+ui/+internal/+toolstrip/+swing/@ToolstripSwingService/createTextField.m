function createTextField(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSTextField');
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% get action peer node
    action_node = getActionNodeFromWidgetNode(this, widget_node);
    %% set swing component properties
    % tag
    value = widget_node.getProperty('tag');
    jh.setName(value);
    % description
    value = action_node.getProperty('description');
    this.setSwingTooltip(jh,value);
    % enabled
    value = action_node.getProperty('enabled');
    jh.setEnabled(value);
    % text
    value = action_node.getProperty('text');
    jh.setText(value);
    % enabled
    value = action_node.getProperty('editable');
    jh.setEditable(value);
    %% register listeners to Swing driven events
    action_id = char(action_node.getId());
    fcn1 = {@textEditedCallback, this, action_id};
    fcn2 = {@textFocusLostCallback, this, action_id};
    fcn3 = {@textFocusGainedCallback, this, action_id};
    registerSwingListener(this, widget_node, jh, 'ActionPerformed', fcn1, jh, 'FocusLost', fcn2, jh, 'FocusGained', fcn3);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

function textEditedCallback(src, ~, this, action_id)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        action_node.setProperty('text',src.getText());
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
