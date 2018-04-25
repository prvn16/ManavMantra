classdef DesignTimeComponentController < appdesigner.internal.controller.DesignTimeController
    %DESIGNTIMECOMPONENTCONTROLLER - This class contains design time logic
    %specific to components
    
    methods
        function obj = DesignTimeComponentController(varargin)
            obj = obj@appdesigner.internal.controller.DesignTimeController(varargin{:});
        end        
    end
    
    methods (Abstract, Access = 'protected')
       % HANDLEDESIGNTIMEPROPERTIESCHANGED - Delegates the logic of 
       % handling the event to the runtime controllers via the
       % handlePropertiesChanged method       
       handleDesignTimePropertiesChanged(obj, src, valuesStruct);
       
       handleDesignTimeEvent(obj, src, event);
    end
    
    methods(Access = 'protected')
        function handleComponentPropertiesSet(obj, src, valuesStruct)
            % Handle Property Change events explicitly
            obj.handleDesignTimePropertiesChanged(src, valuesStruct);            
        end
        
        function handleComponentPeerEvent(obj, src, event)
            % Handler for 'peerEvent' from the Peer Node
            
            % Delegate to the abstract method which will be implemented by
            % the subclass
            obj.handleDesignTimeEvent(src, event);
        end
    end
end

