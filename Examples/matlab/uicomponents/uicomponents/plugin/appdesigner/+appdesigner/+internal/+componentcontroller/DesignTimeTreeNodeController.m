classdef DesignTimeTreeNodeController < ...
        matlab.ui.container.internal.controller.TreeNodeController  & ...
        appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController  & ...
        appdesservices.internal.interfaces.controller.DesignTimeParentingController
    
    % DesignTimeTreeController is a Visual Component Container 
    % Unlike GBT Containers that extend DesignTimeGbtParentingController
    % it extends DesignTimeParentingController   
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function obj = DesignTimeTreeNodeController(component, parentController, proxyView)
            obj = obj@matlab.ui.container.internal.controller.TreeNodeController(component, parentController, proxyView);
            obj = obj@appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController(component, proxyView);
            factory = appdesigner.internal.componentmodel.DesignTimeComponentFactory;
            obj = obj@appdesservices.internal.interfaces.controller.DesignTimeParentingController( factory );
            
            % Destroy the visual component's runtime listeners.  We will
            % not be needing these during design time.
            delete(obj.Listeners);
            obj.Listeners = [];
            
            % g1625958 - Workaround for the issue where proxyview and 
            % controllers are deleted when tree-nodes are inserted at
            % specific indexes/ re-ordered
            component.setControllerHandle(obj);
        end
        
        function isChildOrderReversed = isChildOrderReversed(obj)
            isChildOrderReversed = false;
        end
    end
    
    methods (Access = 'protected')
        
        function deleteChild(obj, model, child)            
            delete( child );
        end
        
        function model = getModel(obj)            
            model = obj.Model;
        end
        
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
