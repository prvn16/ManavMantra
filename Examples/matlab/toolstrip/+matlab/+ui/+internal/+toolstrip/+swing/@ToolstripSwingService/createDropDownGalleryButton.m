function createDropDownGalleryButton(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSDropDownButton');
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% get action peer node
    action_node = getActionNodeFromWidgetNode(this, widget_node);
    %% initialize swing component properties
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
    % gallery popup
    %% create swing widget
    popupId = char(widget_node.getProperty('popupId'));
    if isempty(popupId)
        error('you must specify gallery popup before rendering gallery!')
    else
        popup_node = this.getWidgetNodeFromId(popupId);
        jpopup = this.Registry.getWidgetById(popupId);    
    end
    joption = javaObjectEDT('com.mathworks.toolstrip.components.gallery.GalleryOptions');
    value = widget_node.getProperty('maxColumnCount');
    joption.setMaxColumnCount(value);
    value = widget_node.getProperty('minColumnCount');
    joption.setMinColumnCount(value);
    value = widget_node.getProperty('galleryItemRowCount');
    joption.setRowCount(value);
    value = widget_node.getProperty('galleryItemTextLineCount');
    joption.setLabelLineCount(value);
    switch lower(char(popup_node.getProperty('displayState')))
        case 'icon_view'
            value = javaMethodEDT('valueOf','com.mathworks.toolstrip.components.gallery.GalleryOptions$PopupViewType','ICON');
        case 'list_view'
            value = javaMethodEDT('valueOf','com.mathworks.toolstrip.components.gallery.GalleryOptions$PopupViewType','LIST');
    end
    joption.setInitialPopupView(value);
    joption.setSupportFavorites(false);
    joption.setShowSelection(widget_node.getProperty('showSelection'));
    jshower = javaObjectEDT('com.mathworks.toolstrip.components.gallery.view.GalleryPopupListenerShower',jpopup,joption);
    jh.setPopupListener(jshower);
    jh.setPopupShower(jshower);
    %% register listeners to Swing driven events
    fcn = {@buttonDropDownCallback, this, widget_id};
    registerSwingListener(this, widget_node, jh, 'ActionPerformed', fcn);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
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
