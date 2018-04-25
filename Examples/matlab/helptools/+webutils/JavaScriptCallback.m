classdef JavaScriptCallback < handle
    properties
        RealCallback
    end
    
    methods
        function obj = JavaScriptCallback(callback)
            obj.RealCallback = callback;
        end
        
        function execute(obj,~,data)
            c = onCleanup(@() obj.delete);
            obj.RealCallback(char(data.getData));
        end
    end
    
end

