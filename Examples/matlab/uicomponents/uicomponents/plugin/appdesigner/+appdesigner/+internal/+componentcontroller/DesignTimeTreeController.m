classdef DesignTimeTreeController < ...
        matlab.ui.container.internal.controller.TreeController  & ...
        appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController & ...
        appdesservices.internal.interfaces.controller.DesignTimeParentingController
    
    % DesignTimeTreeController is a Visual Component Container 
    % Unlike GBT Containers that extend DesignTimeGbtParentingController
    % it extends DesignTimeParentingController
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function obj = DesignTimeTreeController(component, parentController, proxyView)
            obj = obj@matlab.ui.container.internal.controller.TreeController(component, parentController, proxyView);
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
        
        function changedPropertiesStruct = handleSizeLocationPropertyChange(obj, changedPropertiesStruct)
            % Handles change of Position related properties
            % Override of the method defined in
            % PositionableComponentController (runtime)
            
            % Call super first
            changedPropertiesStruct = handleSizeLocationPropertyChange@matlab.ui.control.internal.controller.mixin.PositionableComponentController(obj, changedPropertiesStruct);
            
            % Design time specific business logic
            % This needs to be done after the call to super because the run
            % time method will update Position / InnerPosition /
            % OuterPosition, and the set below relies on those properties
            % being updated
            %
            % To keep Position up to date in the client, need to
            % update it after things like move, resize , etc...
            obj.ProxyView.setProperties({
                'Position', obj.Model.Position, ...
                'InnerPosition', obj.Model.InnerPosition, ...
                'OuterPosition', obj.Model.OuterPosition});
        end
        
    end
    
    methods
        
        function excludedProperties = getExcludedPositionPropertyNamesForView(obj)
            % Get the position related properties that should be excluded
            % from the list of properties sent to the view
            
            excludedProperties = getExcludedPositionPropertyNamesForView@matlab.ui.control.internal.controller.mixin.PositionableComponentController(obj);
            
            % The runtime controller removes Position, Inner/OuterPosition.
            % Since those properties need to be sent to the view at design
            % time (e.g. for the inspector), remove those properties from
            % the list of excluded properties
            positionProperties = {...
                'Position', ...
                'InnerPosition', ...
                'OuterPosition', ...
                };
            
            excludedProperties = setdiff(excludedProperties, positionProperties);
        end
        
    end
end
