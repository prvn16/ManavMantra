function createSplitButton(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton');
    jh.setPopupListener(javaObjectEDT('com.mathworks.toolstrip.components.DelayedPopupListener'));
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
    fcn1 = {@buttonPushedCallback, this, action_id};
    fcn2 = {@buttonDropDownCallback, this, widget_id};
    registerSwingListener(this, widget_node, jh, 'ActionPerformed', fcn1, jh, 'DropDownActionPerformed', fcn2);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    fcnPeerEvent = {@peerEventCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn, fcnPeerEvent);
end

function buttonPushedCallback(~, ~, this, action_id)
    % get action node
    action_node = getActionNodeFromId(this, action_id);
    % relay event
    if ~isempty(action_node)
        eventdata = java.util.HashMap;
        eventdata.put('eventType','ButtonPushed');
        action_node.dispatchPeerEvent('peerEvent',action_node,eventdata);
    end
end

function buttonDropDownCallback(~, ~, this, widget_id)
    widget_node = getWidgetNodeFromId(this, widget_id);
    if ~isempty(widget_node)
        property = java.util.HashMap;
        property.put('eventType','DropDownPerformed');
        widget_node.dispatchPeerEvent('peerEvent',widget_node,property);
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

function peerEventCallback(~, data, this, widget_id)
    eventdata = data.getData();
    if strcmp(get(eventdata,'eventType'),'showPopup')
        popup_id = get(eventdata,'popupId');
        button = this.Registry.getWidgetById(widget_id);    
        lsnr = button.getPopupListener();
        popup = this.Registry.getWidgetById(popup_id);    
        lsnr.show(popup);            
    end
end
