function createGalleryPopup(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.gallery.model.DefaultGalleryModel');
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% initialize swing component properties
    % DisplayState: ignored, always "icon-text"
    % GalleryItemRowCount: option.RowCount
    % GalleryItemTextLineCount: option.LabelLineCount
    % GalleryItemWidth: ignored
    % UserCustomizable: ignored, always false
    % ShowHeader: ignored, always true
    %% register listeners to Swing driven events
    h = handle(jh, 'callbackproperties');
    L = handle.listener(h,'PropertyChange',@(x,y) categoryMovedCallback(x, y, this));
    this.Registry.register('ClientListener',widget_id,L);
end

function categoryMovedCallback(src, data, this)
    if strcmp(char(data.JavaEvent.getPropertyName),char(com.mathworks.toolstrip.components.gallery.model.GalleryModel.CATEGORIES_PROPERTY))
        popup = data.JavaEvent.getSource();
        categories = popup.getCategories();
        if size(categories)>1
            category = categories.get(1); % first non-favorite
            if strcmp(char(category.getLabel()),char(data.JavaEvent.getNewValue()))
                id = this.Registry.findIdByWidget(category);
                widget_node = this.getWidgetNodeFromId(id);
                if ~isempty(widget_node)
                    eventdata = java.util.HashMap;
                    eventdata.put('eventType','categoryMoved');
                    widget_node.dispatchPeerEvent('peerEvent',widget_node,eventdata);
                end
            end
        end
    end
end

