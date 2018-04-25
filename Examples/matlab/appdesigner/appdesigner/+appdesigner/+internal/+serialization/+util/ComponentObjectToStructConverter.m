classdef ComponentObjectToStructConverter < appdesservices.internal.interfaces.controller.AbstractControllerMixin
    % COMPONENTOBJECTTOSTRUCTCONVERTER - Build component data for sending to client side
    % when loading an app
    %
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties(Access=private)        
        UIFigure        
    end
    
    methods
        % constructor
        function obj = ComponentObjectToStructConverter(uiFigure)
            obj.UIFigure = uiFigure;
        end
                
        function componentData = getConvertedData(obj)
            % return the component data under UIFigure, including itself            
            % walk the UIFigure hierarchy to create a hierarchical
            % structure of structures
            componentData = obj.buildComponentHierarchicalData(obj.UIFigure, []);
        end
    end  
    
    methods (Access = private)
        
        function data = buildComponentHierarchicalData(obj, component, parentController)
            % recursively walk the children to build a structure of structures
            
            % Create controller to get PV pairs for view
            controller = obj.createController(component, parentController);
            
            % Create PV pairs for the component
            data = obj.buildComponentData(component, controller);
            
            % Recursively handle child components                
            if isa(controller, 'appdesservices.internal.interfaces.controller.DesignTimeParentingController')
                % Call getAllChildren() function on the controller to get 
                % all children, regardless of the HandleVisibility. 
                % see g1494748
                children = controller.getAllChildren(component);
                
                order = 1:length(children);
                % reestablish the children in reverse order because HG
                % order is last created component is first child.
                %
                % Ex: The order for TabGroup is not reversed
                if (controller.isChildOrderReversed())
                    order = flip(order);
                end
                
                for i = order
                    childComponent = children(i);
                    data.Children(end+1) = obj.buildComponentHierarchicalData(childComponent, controller);
                end
            end
        end
        
        function componentData = buildComponentData(obj, component, controller)
            % Build component data for client side
            %
            
            % Get PV pairs of the component
            propertyNameValues = controller.getPVPairsForView(component);
            
            % convert the propertyNameValues to a struct with value be JSON
            % compatible
            converterFcn = matlab.ui.control.internal.view.ComponentProxyViewFactory.getPVPairsConverter(...
                appdesservices.internal.peermodel.ValueConverterType.JSON_COMPATIBLE_STRUCT);
            values = converterFcn(propertyNameValues);
            
            % Handle design time properties:
            % Add the design time properties from the DesignTimeProperties
            % structure of the model to the list of properties going to the
            % client for creating components.
            % In this way the client will treat these properties as any other.
            % ALso need to remove the DesignTimeProperties property from
            % the list of properties going to the client
            designTimeProperties = values.DesignTimeProperties;
            
            values = rmfield(values, 'DesignTimeProperties');
            
            % iterate over the design time properties structure and set on
            % the values structure
            fields = fieldnames(designTimeProperties);
            for idx = 1:numel(fields)
                fieldName = fields{idx};
                values.(fieldName) = designTimeProperties.(fieldName);
            end
            
            % create a data structure of following fileds to hold component info
            %    Type - component type
            %    PropertyValues - a struct of pv pairs
            %    Children - an array of structs just like this, where each
            %               struct in the array is a child of the component
            componentData = struct;
            componentData.Type = class(component);
            componentData.PropertyValues = values;
            componentData.Children =...
                struct('Type',{}, 'PropertyValues',{}, 'Children',{});
        end
        
        function controller = createController(obj, component, parentController)
            % Create controller for getting property/value pair to be sent
            % to client side
            componentType = class(component);
            proxyView = appdesigner.internal.componentview.EmptyProxyView();
            
            controller = ...
                appdesigner.internal.componentmodel.DesignTimeComponentFactory.createController(...
                componentType, component, parentController, proxyView);           
        end

    end
end
