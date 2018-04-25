function createGallery(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    popupId = char(widget_node.getProperty('galleryPopupId'));
    if isempty(popupId)
        error('you must specify gellery popup before rendering gallery!')
    else
        popup_node = this.getWidgetNodeFromId(popupId);
        jpopup = this.Registry.getWidgetById(popupId);    
    end
    joption = javaObjectEDT('com.mathworks.toolstrip.components.gallery.GalleryOptions');
    value = widget_node.getProperty('maxColumnCount');
    joption.setMaxColumnCount(value);
    value = widget_node.getProperty('minColumnCount');
    joption.setMinColumnCount(value);
    value = popup_node.getProperty('galleryItemRowCount');
    joption.setRowCount(value);
    value = popup_node.getProperty('galleryItemTextLineCount');
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
    jh = javaObjectEDT('com.mathworks.toolstrip.components.gallery.view.GalleryView',jpopup,joption);
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
    % textOverlay
    value = char(widget_node.getProperty('textOverlay'));
    if isempty(value)
        javaMethodEDT('setOverlayText', jh, []);
    else
        javaMethodEDT('setOverlayText', jh, value);
    end
    % setBusy
    value = char(widget_node.getProperty('displayState'));
    bool = strcmp(value,'busy');
    if bool
        javaMethodEDT('setBusy', jh, true);
        javaMethodEDT('setEnabled', jh, false);
    end
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
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
            case 'description'
                this.setSwingTooltip(jh,value);
            case 'enabled'
                javaMethodEDT('setEnabled', jh, value);
            case 'textOverlay'
                if isempty(value)
                    javaMethodEDT('setOverlayText', jh, []);
                else
                    javaMethodEDT('setOverlayText', jh, value);
                end
            case 'displayState'
                bool = strcmp(value,'busy');
                javaMethodEDT('setBusy', jh, bool);
                javaMethodEDT('setEnabled', jh, ~bool);
        end
    end
end
