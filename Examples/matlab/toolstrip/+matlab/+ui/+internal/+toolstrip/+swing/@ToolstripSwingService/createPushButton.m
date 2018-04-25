function createPushButton(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% get action peer node
    action_node = getActionNodeFromWidgetNode(this, widget_node);
    %% initialize swing component properties
    % turn off Mnemonic
    jh.setAutoMnemonicEnabled(false);
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
    % icon
    value = getImageIcon(this,action_node); % [] if not specified
    jh.setIcon(value);
    %% register listeners to Swing driven events
    action_id = char(action_node.getId());
    fcn = {@buttonPushedCallback, this, action_id};
    registerSwingListener(this, widget_node, jh, 'ActionPerformed', fcn);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

function buttonPushedCallback(~, ~, this, action_id)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        eventdata = java.util.HashMap;
        eventdata.put('eventType','ButtonPushed');
        action_node.dispatchPeerEvent('peerEvent',action_node,eventdata);
    end
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
                this.setSwingTooltip(jh,value);
            case 'enabled'
                jh.setEnabled(value);
            case 'text'
                jh.setText(value);
            case 'icon'
                icon = getImageIcon(this,src); % [] if not specified
                jh.setIcon(icon);
            case 'tag'
                jh.setName(value);
        end
    end
end



