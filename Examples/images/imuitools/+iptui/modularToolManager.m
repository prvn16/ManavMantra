%MODULARTOOLMANAGER Create modular tool manager.
%   H = MODULARTOOLMANAGER() creates a modular tool manager
%   to actively manage the refreshing of a set of modular tools.
%
%   methods
%   =======
%   registerTool(h_tool) registers the tool, h_tool, with the manager.
%   enableTools()        enables all modular tools' listeners created using
%                        reactToImageChangesInFig
%   disableTools()       disables all modular tools' listeners created
%                        using reactToImageChangesInFig
%   refreshTools()       calls all modular tools' refresh functions
%
%   See also IMOVERVIEW.

%   Copyright 2008-2010 The MathWorks, Inc.

classdef modularToolManager < handle
    
    properties (SetAccess = 'private', GetAccess = 'private')
        
        tool_list
        
    end % properties
    
    methods
        
        function obj = modularToolManager()
            %modularToolManager  Constructor for modularToolManager.
            obj.tool_list = [];
        end
        
        function registerTool(obj,h_tool)
            %registerTool  Registers a tool with the manager.
            if isempty(obj.tool_list)
                obj.tool_list = h_tool;
            else
                obj.tool_list(end+1) = h_tool;
                obj.tool_list = unique(obj.tool_list);
            end
        end
        
        function enableTools(obj)
            %enableTools  Enables react listeners in all tools.
            enableModularTools(obj.tool_list,true);
        end
        
        function disableTools(obj)
            %disableTools  Disables react listeners in all tools.
            enableModularTools(obj.tool_list,false);
        end
        
        function refreshTools(obj)
            %refreshTools  Refresh all modular tools.
            
            for i = 1:numel(obj.tool_list)
                
                if ishghandle(obj.tool_list(i))
                    
                    cdata_listeners = getappdata(obj.tool_list(i),'CDataChangedListeners');
                    
                    for j = 1:numel(cdata_listeners)
                        
                        this_listener = cdata_listeners(j);
                        if isa(this_listener,'event.listener')
                            src_obj = this_listener.Source{1};
                        elseif isa(this_listener,'handle.listener')
                            src_obj = this_listener.SourceObject;
                        end
                        
                        cb_fun = this_listener.Callback;
                        cb_fun(src_obj,[]);
                        
                    end
                    
                end
            end
            
        end
        
    end % methods
    
end % classdef



function enableModularTools(tool_list,new_enabled_prop)
%enableModularTools enables or disables modular tools.
%   enableModularTools(TOOL_LIST,NEW_ENABLED_PROP) enables or disables all
%   modular tools in the TOOL_LIST.  Valid values for NEW_ENABLED_PROP are
%   true and false.

% disable the listeners in each tool
for i = 1:numel(tool_list)
    
    this_tool = tool_list(i);
    if ishghandle(this_tool)
        
        % image destroy listeners
        listeners = getappdata(this_tool,'ObjectDestroyedListeners');
        iptui.internal.setListenerEnabled(listeners, new_enabled_prop)
        
        % image updated listeners
        listeners = getappdata(this_tool,'CDataChangedListeners');
        iptui.internal.setListenerEnabled(listeners, new_enabled_prop)
        
    end
end

end % enableModularTools

