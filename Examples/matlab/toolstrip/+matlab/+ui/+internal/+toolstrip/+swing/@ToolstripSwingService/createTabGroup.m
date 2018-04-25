function createTabGroup(this, widget_node)
    %% get widget peer node id
    widget_id = char(widget_node.getId());
    %% create swing widget
    jh = javaObjectEDT('com.mathworks.toolstrip.DefaultToolstripTabGroup');
    %% register widget (key: widget_id, value: swing handle)
    this.Registry.register('Widget', widget_id, jh);
    %% initialize swing component properties
    % skip updating SelectedTab if the toolstrip is part of toolgroup
    if isempty(this.SwingToolGroup)                
        tabId = char(widget_node.getProperty('selectedTab'));
        if ~isempty(tabId)
           tab = this.Registry.getWidgetByPollingId(tabId);
           jh.setCurrentTab(tab.getName());
        end
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
            case 'selectedTab'
                if isempty(this.SwingToolGroup)                
                    if isempty(value)
                        jh.setCurrentTab('');
                    else
                        tab = this.Registry.getWidgetById(value);
                        if ~strcmp(char(jh.getCurrentTab),char(tab.getName()))
                            jh.setCurrentTab(tab.getName());
                        end
                    end
                else
                    if isempty(value)
                        this.SwingToolGroup.setCurrentTab('');
                    else
                        tab = this.Registry.getWidgetById(value);
                        if ~strcmp(char(this.SwingToolGroup.getCurrentTab),char(tab.getName()))
                            this.SwingToolGroup.setCurrentTab(tab.getName());
                        end
                    end
                end
        end
    end
end
