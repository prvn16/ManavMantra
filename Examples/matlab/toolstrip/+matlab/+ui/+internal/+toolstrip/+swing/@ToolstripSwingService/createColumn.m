function createColumn(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.sections.ColumnTSComponent');
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% must set the column vertical alignment to center (default is top)
    jh.setAlignment(com.mathworks.toolstrip.components.VerticalAlignment.CENTER); 
    %% initialize swing component properties
    % tag
    value = widget_node.getProperty('tag');
    jh.setName(value);
    % width
    value = widget_node.getProperty('width');
    jh.setPreferredWidth(value);
    % alignment
    value = char(widget_node.getProperty('horizontalAlignment'));
    switch value
        case 'left'
            jh.setHorizontalAlignment(com.mathworks.toolstrip.components.HorizontalAlignment.LEFT);
        case 'center'
            jh.setHorizontalAlignment(com.mathworks.toolstrip.components.HorizontalAlignment.CENTER);
        case 'right'
            jh.setHorizontalAlignment(com.mathworks.toolstrip.components.HorizontalAlignment.RIGHT);
    end            
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, [], fcn);
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
