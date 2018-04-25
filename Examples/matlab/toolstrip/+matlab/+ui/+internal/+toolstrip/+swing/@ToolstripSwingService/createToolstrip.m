function createToolstrip(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    % create toolstrip swing widget only if it is not part of toolgroup
    if isempty(this.SwingToolGroup)
        jh = javaObjectEDT('com.mathworks.toolstrip.DefaultToolstrip');            
        %% register widget (key: widget_id, value: swing handle)
        this.Registry.register('Widget', widget_id, jh);
        %% set swing component properties
        % displayState
        switch lower(char(widget_node.getProperty('displayState')))
            case 'expanded'
                value = javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','EXPANDED');
            case 'collapsed'
                value = javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','COLLAPSED');
        end
        jh.setAttribute(com.mathworks.toolstrip.Toolstrip.STATE, value);
        %% register listeners to Swing driven events
        panels = getComponents(jh.getComponent());
        fcn = {@attributeChangedCallback, this, widget_id};
        registerSwingListener(this, widget_node, panels(1), 'AttributeChanged', fcn);
        %% register listeners to MCOS driven events
        fcn = {@propertySetCallback, this, widget_id};
        registerPeerNodeListener(this, widget_node, [], fcn);
    else
        this.Registry.register('Widget',widget_id,[]);
    end
end

function attributeChangedCallback(src, data, this, widget_id)
    % to do for stand-alone toolstrip
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
            case 'displayState'
                switch lower(value)
                    case 'expanded'
                        jvalue = javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','EXPANDED');
                    case 'collapsed'
                        jvalue = javaMethodEDT('valueOf','com.mathworks.toolstrip.Toolstrip$State','COLLAPSED');
                end
                jh.setAttribute(com.mathworks.toolstrip.Toolstrip.STATE, jvalue);
        end
    end
end

