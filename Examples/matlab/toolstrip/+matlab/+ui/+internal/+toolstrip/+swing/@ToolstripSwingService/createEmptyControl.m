function createEmptyControl(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSLabel',' ');
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
end

