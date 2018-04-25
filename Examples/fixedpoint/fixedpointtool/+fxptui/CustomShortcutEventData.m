
classdef CustomShortcutEventData < event.EventData
    %CUSTOMSHORTCUTData returns the new custom shortcut that can be
    %passed with eventdata to client
    
    %   Copyright 2016 The MathWorks, Inc.
    
    properties
        CustomShortcut
        Action
    end
    
    methods
        function this = CustomShortcutEventData(shortcutName, action)
            this.CustomShortcut = {shortcutName};
            this.Action = action;
        end
    end
    
end

