classdef DesignTimeContainerController < ...
        matlab.ui.control.internal.controller.ContainerController & ...
        appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController
    %DESIGNTIMECONTAINERCONTROLLER - This class contains design time logic
    %specific to Containers
    
    
    methods
        function obj = DesignTimeContainerController(component, parentController, proxyView)                       
            obj = obj@matlab.ui.control.internal.controller.ContainerController(component, parentController, proxyView);
            obj = obj@appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController(component, proxyView);
        
            % Destroy the visual comopnent's runtime listeners.  We will
            % not be needing these during design time.
            delete(obj.Listeners);
            obj.Listeners = [];
            
        end
    end
    
    methods (Access = 'protected')

       function handleDesignTimePropertiesChanged(obj, src, changedPropertiesStruct)
           % HANDLEDESIGNTIMEPROPERTIESCHANGED - Delegates the logic of 
           % handling the event to the runtime controllers via the
           % handlePropertiesChanged method
           handlePropertiesChanged(obj, changedPropertiesStruct);
       end
       
       function handleDesignTimeEvent(obj, src, event)
           % HANDLEDESIGNTIMEEVENT - Delegates the logic of handling the
           % event to the runtime controllers via the handleEvent method
           handleEvent(obj, src, event);
       end
    end
end

