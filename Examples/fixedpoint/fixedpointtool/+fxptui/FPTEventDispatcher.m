classdef FPTEventDispatcher < handle
    % Defines events that is used to comminicate information between the data &
    % view
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties(Constant,GetAccess=private)
        % Stores the class instance as a constant property
        FPTEventDispatcherInstance = fxptui.FPTEventDispatcher;
    end
    
    events (NotifyAccess=private)
        FunctionAddedEvent;
        UpdatedResultObjects;
        UpdatedResultsOnProposedOrApplyChange
    end
    
    events
        DataUpdated
    end
    
    methods (Static)
        function obj = getInstance
            % Returns the stored instance of the repository.
            obj = fxptui.FPTEventDispatcher.FPTEventDispatcherInstance;
        end
    end
    
    methods
        function broadcastEvent(this, eventName, eventData)
            notify(this, eventName, eventData);
        end
    end
    
    methods (Access=private)
        function this = FPTEventDispatcher
            mlock; % Prevents clearing of the class from MATLAB.
        end
    end
end