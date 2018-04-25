function createGalleryItem(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% get action peer node
    action_node = getActionNodeFromWidgetNode(this, widget_node);
    %% create swing widget
    % gallery action
    jtitle = action_node.getProperty('text');
    jdescription = action_node.getProperty('description');
    if isempty(jdescription)
        jdescription = []; % need null to avoid displaying a dot
    end
    jicon = getImageIcon(this,action_node); % always assume valid icon
    jaction = javaObjectEDT('com.mathworks.mlwidgets.toolgroup.GalleryAction',jtitle,jdescription,jicon);
    % gallery item
    name = char(widget_node.getProperty('tag'));
    if isempty(name)
        name = char(java.util.UUID.randomUUID);
    end
    jh = javaObjectEDT('com.mathworks.toolstrip.components.gallery.model.Item',name,jaction,[]);
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% initialize swing component properties
    % enabled
    value = action_node.getProperty('enabled');
    jh.setEnabled(value);
    %% register listeners to Swing driven events
    % store action id in gallery action object
    action_id = char(action_node.getId());
    jaction.putValue('actionId',action_id);
    % listen to item pushed event
    fcnItemPushed = {@itemPushedCallback, this, action_id, jaction};
    cb = javaMethodEDT('getCallback',jaction);    
    L1 = addlistener(cb, 'delayed', fcnItemPushed);
    this.Registry.register('ClientListener',widget_id,L1);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

function itemPushedCallback(~, ~, this, action_id, jaction)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        % always send out item pushed event
        eventdata = java.util.HashMap;
        eventdata.put('eventType','ItemPushed');
        action_node.dispatchPeerEvent('peerEvent',action_node,eventdata);
        % always toggle itself
        new_value = ~jaction.isSelected();
        jaction.setSelected(new_value);
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
                if isempty(value)
                    jh.getAction().setTip([]);
                else
                    jh.getAction().setTip(value);
                end
            case 'enabled'
                jh.setEnabled(value);
            case 'text'
                jh.getAction().setName(value);
            case 'icon'
                icon = getImageIcon(this,src); % always assume valid icon
                jh.getAction().setButtonOnlyIcon(icon);
        end
    end
end



