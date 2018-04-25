function createList(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jModel = javaObjectEDT('javax.swing.DefaultListModel');
    jh = javaObjectEDT('com.mathworks.toolstrip.components.TSList',jModel);
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
    % selection mode
    value = action_node.getProperty('selectionMode');
    if(strcmpi(value, 'single'))
        jh.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
    else
        jh.setSelectionMode(javax.swing.ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
    end
    % items
    items = action_node.getProperty('items'); % hashmap or its array when not empty
    if isa(items,'java.util.HashMap') || isa(items,'java.util.HashMap[]')
        % items are available
        for ct=1:length(items)
            jh.getModel().addElement(items(ct).get('label'));
        end
    end
    % selected items
    selectedItems = action_node.getProperty('selectedItems'); % java string array when not empty
    if isa(selectedItems,'java.lang.String') || isa(selectedItems,'java.lang.String[]')
        if isa(items,'java.util.HashMap') || isa(items,'java.util.HashMap[]')
            selected = [];
            selections = cellfun(@char,cell(selectedItems),'UniformOutput',false);
            for i = 1:length(items)
                if(any(strcmpi(items(i).get('value'), selections)))
                    selected = [selected; i];
                end
            end
            if isempty(selected)
                jh.setSelectedIndices(-1);
            else
                jh.setSelectedIndices(selected-1);
            end
        end
    end
    %% register listeners to Swing driven events
    action_id = char(action_node.getId());
    fcn = {@valueChangedCallback, this, action_id};
    registerSwingListener(this, widget_node, jh, 'ValueChanged', fcn);
    %% register listeners to MCOS driven events
    fcn = {@propertySetCallback, this, widget_id};
    registerPeerNodeListener(this, widget_node, action_node, fcn);
end

%% Swing event callbacks
function valueChangedCallback(src, ~, this, action_id)
    action_node = getActionNodeFromId(this, action_id);
    if ~isempty(action_node)
        items = action_node.getProperty('items');
        selectedIndices = double(src.getSelectedIndices()) + 1;
        % ignore non-selection because it will never happen from UI
        % it will prevent round trip from MCOS driven property change
        if ~isempty(selectedIndices)
            selectedItems = cell(numel(selectedIndices), 1);
            for ct = 1:length(selectedItems)
                selectedItems{ct} = items(selectedIndices(ct)).get('value');
            end
            java_value = matlab.ui.internal.toolstrip.base.Utility.convertFromMatlabToJava(selectedItems);
            action_node.setProperty('selectedItems',java_value);
        end
    end
end

%% MCOS event callbacks
function propertySetCallback(~, data, this, widget_id)
    % check originator
    originator = data.getOriginator();
    % set property value ONLY If it is a MCOS driven event
    if isa(originator, 'java.util.HashMap') && strcmp(originator.get('source'),'MCOS')
        % get data
        structure = matlab.ui.internal.toolstrip.base.Utility.convertFromHashmapToStructure(data.getData());
        % get swing widget
        jh = this.Registry.getWidgetById(widget_id);
        value = structure.newValue;
        % set swing property
        switch structure.key
            case 'description'
                this.setSwingTooltip(jh,value);
            case 'enabled'
                jh.setEnabled(value);
            case 'items'
                % for addItem, removeItem, replaceAllItems methods
                model = jh.getModel();
                % reset list
                model.removeAllElements();
                for ct=1:length(value)
                    model.addElement(value(ct).label);
                end
                % update selection
                selected = [];
                for ct=1:length(value)
                    if value(ct).selected
                        selected = [selected; ct]; %#ok<*AGROW>
                    end
                end
                if isempty(selected)
                    jh.setSelectedIndices(-1);
                else
                    jh.setSelectedIndices(selected-1);
                end
            case 'selectedItems'
                items = data.get('target').getProperty('items');
                if isa(items,'java.util.HashMap') || isa(items,'java.util.HashMap[]')
                    selected = [];
                    for ct = 1:length(items)
                        if(any(strcmpi(items(ct).get('value'), value)))
                            selected = [selected; ct];
                        end
                    end
                    if isempty(selected)
                        jh.setSelectedIndices(-1);
                    else
                        jh.setSelectedIndices(selected-1);
                    end
                end
            case 'tag'
                jh.setName(value);
        end
    end
end
