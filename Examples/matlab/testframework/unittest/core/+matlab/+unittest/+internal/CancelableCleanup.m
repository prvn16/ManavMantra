classdef CancelableCleanup < handle
    % This class is undocumented.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        Task function_handle = @()[];
    end
    
    properties(SetAccess=private)
        Cancelled = false;
    end
    
    methods
        function obj = CancelableCleanup(functionHandle)
            obj.Task = functionHandle;
        end
        
        function cancel(obj)
            obj.Cancelled = true;
        end
        
        function cancelAndInvoke(obj)
            obj.cancel;
            obj.Task();
        end
        
        function delete(obj)
            if ~obj.Cancelled
                obj.Task();
            end
        end
    end
end