function createSpinner(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSSpinner');
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
    % value
    value1 = action_node.getProperty('value');
    % minimum
    value2 = action_node.getProperty('minimum');
    % maximum
    value3 = action_node.getProperty('maximum');
    % minorStepSize
    value4 = action_node.getProperty('minorStepSize');
    % numberFormat
    numberformat = action_node.getProperty('numberFormat');
    if strcmpi(numberformat,'integer')
        % set model with double precision
        jh.setModel(javaObjectEDT('javax.swing.SpinnerNumberModel',java.lang.Integer(value1),java.lang.Integer(value2),java.lang.Integer(value3),java.lang.Integer(value4)));
    else
        % set model with double precision
        jh.setModel(javaObjectEDT('javax.swing.SpinnerNumberModel',value1,value2,value3,value4));
    end
    %% register listeners to Swing driven events
    action_id = char(action_node.getId());
    fcn = {@valueChangedCallback, this, action_id};
    registerSwingListener(this, widget_node, jh, 'StateChanged', fcn);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

function valueChangedCallback(src, ~, this, action_id)
    % When a spinner arrow is clicked for the first time, two state changed
    % events are fired.  that is the default behavior for JSpinner.
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        % Update the action node value
        oldvalue = action_node.getProperty('value');
        newvalue = src.getValue();
        if oldvalue ~= newvalue
            action_node.setProperty('value',newvalue);
            % Dispatch a ValueChanged event to notify any listeners
            eventdata = java.util.HashMap;
            eventdata.put('eventType','ValueChanged');
            eventdata.put('Value',newvalue);
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
        mdl = jh.getModel();
        isDouble = isa(mdl.getNumber(),'java.lang.Double');
        value = structure.newValue;
        % set swing property
        switch structure.key
            case 'description'
                this.setSwingTooltip(jh,value);
            case 'enabled'
                jh.setEnabled(value);
            case 'minimum'
                if isDouble
                    javaMethodEDT('setMinimum',mdl,java.lang.Double(value));
                else
                    javaMethodEDT('setMinimum',mdl,java.lang.Integer(value));
                end
            case 'maximum'
                if isDouble
                    javaMethodEDT('setMaximum',mdl,java.lang.Double(value));                
                else
                    javaMethodEDT('setMaximum',mdl,java.lang.Integer(value));                
                end
            case 'value'
                if isDouble
                    this.setValueWithoutFiringEvent('spinner', mdl, java.lang.Double(value));
                else
                    this.setValueWithoutFiringEvent('spinner', mdl, java.lang.Integer(value));
                end
                txt = jh.getEditor().getTextField();
                javaMethodEDT('setText',txt,java.lang.String(num2str(value)));
            case 'minorStepSize'
                if isDouble
                    javaMethodEDT('setStepSize',mdl,java.lang.Double(value));
                else
                    javaMethodEDT('setStepSize',mdl,java.lang.Integer(value));
                end
            case 'tag'
                jh.setName(value);
        end
    end
end
