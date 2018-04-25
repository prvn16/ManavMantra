function createComboBox(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSComboBox');
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
    % editable
    value = action_node.getProperty('editable');
    jh.setEditable(value);
    % enabled
    value = action_node.getProperty('enabled');
    jh.setEnabled(value);
    % items
    items = action_node.getProperty('items');
    if isa(items,'java.util.HashMap') || isa(items,'java.util.HashMap[]')
        % items are available
        for ct=1:length(items)
            jh.addItem(items(ct).get('label'));
        end
    end
    % selected item
    selectedItem = action_node.getProperty('selectedItem');
    if isempty(selectedItem)
        % no selection
        jh.setSelectedItem(''); 
    elseif isa(items,'java.util.HashMap') || isa(items,'java.util.HashMap[]')
        % honor selection when items are available
        for ct=1:length(items)
            if strcmp(items(ct).get('value'),selectedItem)
                jh.setSelectedItem(items(ct).get('label')); 
                break;
            end            
        end
    end
    %% register listeners to Swing driven events
    action_id = char(action_node.getId());
    fcn = {@selectionChangedCallback, this, action_id};
    registerSwingListener(this, widget_node, jh, 'ActionPerformed', fcn);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

%% Swing event callbacks
function selectionChangedCallback(src, ~, this, action_id)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        % get selected label
        selectedLabel = src.getSelectedItem();
        selectedValue = selectedLabel; % for custom value in editable mode
        % get selected value
        items = action_node.getProperty('items');
        for ct=1:length(items)
            if strcmp(items(ct).get('label'),selectedLabel)
                selectedValue = items(ct).get('value');
                break;
            end            
        end
        % ignore same selection
        currentValue = char(action_node.getProperty('selectedItem'));
        if ~strcmp(currentValue,selectedValue)
            if isempty(selectedValue)
                action_node.setProperty('selectedItem',java.lang.String(''));
            else
                action_node.setProperty('selectedItem',selectedValue);
            end
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
            case 'editable'
                jh.setEditable(value);
            case 'enabled'
                jh.setEnabled(value);
            case 'items'
                % for addItem, removeItem, replaceAllItems methods
                % always reset list 
                jh.removeAllItems();
                % populate only when items are available
                for ct=1:length(value)
                    jh.addItem(value(ct).label);
                end
                % update selection if it exists
                for ct=1:length(value)
                    if value(ct).selected
                        jh.setSelectedItem(value(ct).label);
                        return;
                    end
                end
                % otherwise, set to no selection
                jh.setSelectedItem('');
            case 'selectedItem'
                if isempty(value)
                    jh.setSelectedItem(''); 
                else
                    widget_node = getWidgetNodeFromId(this, widget_id);
                    action_node = getActionNodeFromWidgetNode(this, widget_node);
                    % if value is part of list, use setSelectedItem(label)
                    IsValueInList = false;
                    items = action_node.getProperty('items');
                    if isa(items,'java.util.HashMap') || isa(items,'java.util.HashMap[]')
                        for ct=1:length(items)
                            if strcmp(items(ct).get('value'),value)
                                jh.setSelectedItem(items(ct).get('label')); 
                                IsValueInList = true;
                                break;
                            end            
                        end
                    end
                    % if value is not part of list and editable is true,
                    % use setSelectedItem(value) as label equals value
                    if ~IsValueInList && jh.isEditable()
                        jh.setSelectedItem(value); 
                    end
                end
            case 'tag'
                jh.setName(value);
        end
    end
end
