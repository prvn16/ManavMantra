function createSlider(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSSlider');
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
    % minimum
    value = action_node.getProperty('minimum');
    jh.setMinimum(value);
    % maximum
    value = action_node.getProperty('maximum');
    jh.setMaximum(value);
    % value
    value = action_node.getProperty('value');
    jh.setValue(value);
    % steps
    % N/A for swing
    % ticks (related to minor ticks)
    ticks = action_node.getProperty('numberOfTicks');
    localSetTick(ticks, jh);
    % labels
    labels = action_node.getProperty('labels');
    locations = action_node.getProperty('locations');
    localSetLabel(labels, locations, jh);
    %% register listeners to Swing driven events
    action_id = char(action_node.getId());
    fcn = {@valueChangedCallback, this, action_id};
    registerSwingListener(this, widget_node, jh, 'StateChanged', fcn);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

function valueChangedCallback(src, ~, this, action_id)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        % Update the action node value
        value = src.getValue();
        action_node.setProperty('value',value);
        % Dispatch a ValueChanged event to notify any listeners
        if ~src.getValueIsAdjusting()
            eventdata = java.util.HashMap;
            eventdata.put('eventType','ValueChanged');
            eventdata.put('Value',value);
            action_node.dispatchPeerEvent('peerEvent',action_node,eventdata);
        end
    end
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
                jh.setEnabled(value);
            case 'minimum'
                jh.setMinimum(value);
            case 'maximum'
                jh.setMaximum(value);
            case 'value'
                this.setValueWithoutFiringEvent('slider', jh.getModel(), value);
            case 'steps'
                % N/A for swing
            case 'numberOfTicks'
                localSetTick(value, jh);
            case 'labels' 
                % ignore 'locations' because it sets first from server side
                widget_node = getWidgetNodeFromId(this, widget_id);
                action_node = getActionNodeFromWidgetNode(this, widget_node);
                labels = action_node.getProperty('labels');
                locations = action_node.getProperty('locations');
                localSetLabel(labels, locations, jh);
            case 'tag'
                jh.setName(value);
        end
    end
end

function localSetLabel(labels, locations, jh)
    if any(labels.size==0)
        jh.setLabelTable([]);
        jh.setPaintLabels(false);
    else
        % create label table
        labeltable = java.util.Hashtable;
        len = length(locations);
        for ct=1:len
            if isjava(locations)
                labeltable.put(java.lang.Integer(locations(ct).intValue),javaObjectEDT('com.mathworks.mwswing.MJLabel',labels(ct)));
            else
                labeltable.put(java.lang.Integer(locations(ct)),javaObjectEDT('com.mathworks.mwswing.MJLabel',labels(ct)));
            end
        end
        % display
        jh.setLabelTable(labeltable);
        jh.setPaintLabels(true);
    end
end

function localSetTick(ticks, jh)
    maximum = jh.getMaximum();
    minimum = jh.getMinimum();
    if ticks<=1
        jh.setMinorTickSpacing(0);
        jh.setPaintTicks(false);
    else
        jh.setMinorTickSpacing((maximum-minimum)/(ticks-1));
        jh.setPaintTicks(true);
    end
end
