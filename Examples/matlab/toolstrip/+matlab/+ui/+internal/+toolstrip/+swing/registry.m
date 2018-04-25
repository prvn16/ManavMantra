classdef (Sealed) registry < handle
    % Toolstrip Swing Component Registry Service (singleton, one per MATLAB
    % session).  For internal use only.
    %
    % Constructor:
    %   N/A
    %
    % Properties:
    %   N/A
    %
    %   <a href="matlab:help matlab.ui.internal.toolstrip.swing.registry.hasWidgetById">hasWidgetById</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.swing.registry.getWidgetById">getWidgetById</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.swing.registry.getWidgetByPollingId">getWidgetByPollingId</a>

    % Author(s): Rong Chen
    % Revised:
    % Copyright 2010-2011 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:43 $
    
    properties (SetAccess = private, Hidden)
        WidgetMap
        ServerListenerMap
        ClientListenerMap
        ButtonGroupMap
    end
    
    methods
        
        %% constructor
        function this = registry()
            reset(this);
        end
        
        %% search
        function id = findIdByWidget(this, widget)
            % peer node id = this.findIdByWidget(swing handle)
            id = '';
            keys = this.WidgetMap.keys;
            for ct=1:this.WidgetMap.length
                value = this.WidgetMap(keys{ct});
                if ~isempty(value)
                    if value == widget
                        id = keys{ct};
                        break;
                    end
                end
            end
        end
        
        function value = hasWidgetById(this, key)
            % true/false = this.hasWidgetById(peer node id)
            value = this.WidgetMap.isKey(key);
        end
        
        function result = hasWidgetByProperty(this, property, value)
            % true/false = this.hasWidgetByProperty(property, value)
            result = false;
            for widget = this.WidgetMap.keys
                if widget.getProperty(property) == value
                    result = true;
                    break;
                end
            end
        end
        
        function value = getWidgetById(this, key)
            % swing handle = this.getWidgetById(key)
            value = this.WidgetMap(key);
        end
        
        function value = getWidgetByPollingId(this, key)
            % swing handle = this.getWidgetByPollingId(peer node id)
            value = localPolling(this.WidgetMap, key);
        end
        
        %% registration
        function register(this, type, key, value)
            map = this.([type 'Map']);
            if isKey(map, key)
                % if key exists, append value
                old_value = map(key);
                map(key) = [old_value;value]; %#ok<*NASGU>
            else
                % new key
                map(key) = value;
            end
        end
        
        function unregister(this, type, key)
            if isKey(this.([type 'Map']), key)
                remove(this.([type 'Map']), key);
            end
        end
        
        function reset(this)
            this.WidgetMap = containers.Map();
            this.ServerListenerMap = containers.Map();
            this.ClientListenerMap = containers.Map();
            this.ButtonGroupMap = containers.Map();
        end
        
        function value = getSize(this)
            value1 = this.WidgetMap.Count;
            value2 = this.ServerListenerMap.Count;
            value3 = this.ClientListenerMap.Count;
            value4 = this.ButtonGroupMap.Count;
            value = [value1 value2 value3 0 value4];
        end

    end
    
end

function value = localPolling(map, key)
    while true
        if map.isKey(key)
            value = map(key);
            break;
        end
        pause(0.001);
    end
end