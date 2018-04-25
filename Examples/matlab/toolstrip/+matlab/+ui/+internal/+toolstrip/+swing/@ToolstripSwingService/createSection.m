function createSection(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    name = widget_node.getProperty('tag');
    if isempty(name)
        name = ['section' char(java.util.UUID.randomUUID)];
    end
    jh = javaObjectEDT('com.mathworks.toolstrip.sections.FlowToolstripSection',name);
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% initialize swing component properties
    % title
    str = char(widget_node.getProperty('title'));
    jh.setAttribute(com.mathworks.toolstrip.ToolstripSection.TITLE, java.lang.String(str));
    % priority
    priority = widget_node.getProperty('collapsePriority');
    jh.setAttribute(com.mathworks.toolstrip.ToolstripSection.PRIORITY, java.lang.Integer(priority));
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
            case 'title'
                jh.setAttribute(com.mathworks.toolstrip.ToolstripSection.TITLE, java.lang.String(value));
        end
        this.notify('RefreshToolGroup');
    end
end
