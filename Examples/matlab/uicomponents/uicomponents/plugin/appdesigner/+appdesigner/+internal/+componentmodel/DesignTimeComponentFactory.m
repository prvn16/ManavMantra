classdef (Hidden) DesignTimeComponentFactory < appdesservices.internal.interfaces.model.DesignTimeModelFactory & ...
     matlab.ui.internal.componentframework.services.optional.ControllerInterface
    % DesignTimeComponentFactory  Factory to create component MCOS component objects
    %                               with a proxyView
    
    % Copyright 2017 The MathWorks, Inc.

    methods
        function component = createModel(obj, parentModel, peerNode)
            % create a component as a child of parentModel
            
            import appdesigner.internal.componentmodel.DesignTimeComponentFactory;
            
            % get component type from the peer node
            componentType = char(peerNode.getType());
            
            component = DesignTimeComponentFactory.createComponent(componentType, parentModel, peerNode);
            
            % The Serializble property is required to properly save/load components.   
            % and without it components cannot be loaded.
            % The original visual components (button, label, gauge,etc) do
            % not yet have the Serializable property so need to add it.
            % GBT components do have this property.
            % The if-check is to :
            %    1. only add this property to components that need it
            %    2.  when the Serializable property is eventually added to all 
            %  components via MCOS,  this property won't exist in a previous release
            %  (forward compatible ) scenario because MCOS strips it away.  
            % This logic puts back the property 
            if ~isprop(component, 'Serializable')
                prop = addprop(component, 'Serializable');
                prop.Hidden = true;
                component.Serializable = 'on';
            end

        end
    end
    
    methods(Static)
        function controller = createController(componentType, component, parentController, proxyView)
            % Make this method be resued by TestFramework for creating
            % designtime controller by passing TestProxyView
            
            import appdesigner.internal.componentmodel.DesignTimeComponentFactory;
            import appdesigner.internal.componentcontroller.*;
            import matlab.ui.internal.*;
            
            adapterInstance = DesignTimeComponentFactory.createAdapter(componentType);
            controllerClass = adapterInstance.getComponentDesignTimeController();
            
            controller = feval(controllerClass, ...
                component, parentController, proxyView);
        end
        
        function adapter = createAdapter(componentType)
            import appdesigner.internal.componentmodel.DesignTimeComponentFactory;
            import appdesigner.internal.componentadapter.uicomponents.adapter.*;
            
            appDesignEvironment = appdesigner.internal.application.getAppDesignEnvironment();
            adapterMap = appDesignEvironment.getComponentAdapterMap();
            
            if ~isKey(adapterMap, componentType)
                error('Unknown component type %s', componentType);
            end
            
            adapterClass = adapterMap(componentType);
            adapter = feval(adapterClass);
        end        
    end
    
    methods (Static, Access = private)            
        function component = createComponent(componentType, parentModel, peerNode)
            
            import appdesigner.internal.componentmodel.DesignTimeComponentFactory;
            
            % Create the component with the given parent or get the 
            % component from loaded objects
            codeName = peerNode.getProperty('CodeName');
            appModel = DesignTimeComponentFactory.getAppModel(parentModel);
            
            isNewComponent = false;
            % Try to get the component from the loaded app data first
            component = appModel.popComponent(codeName);
            
            if isempty(component)
                % It's a new component in a loaded app or a new app, and
                % need to create the component model
                isNewComponent = true;
                
                if strcmp(componentType, 'matlab.ui.Figure')
                    component = appdesigner.internal.componentadapter.uicomponents.adapter.createUIFigure();
                else
                    component = feval(componentType,...
                        'Parent', parentModel);
                end
               
            end
            
            if strcmp(componentType, 'matlab.ui.Figure')
                % Add AppModel property to figure model
                appModelProp = addprop(component, 'AppModel');
                
                % Properties will be transient so that they are not saved
                % to disk
                appModelProp.Transient = true;
                component.AppModel = parentModel;
                % Tell the App Model that it owns this figure
                parentModel.UIFigure = component;
            end
            
            % Create the design time proxy view and controller
            designTimeProxView = appdesigner.internal.componentview.DesignTimeComponentProxyView(peerNode, ...
                DesignTimeComponentFactory.createAdapter(componentType), ~isNewComponent); 
            
            DesignTimeComponentFactory.createController(componentType, component, ...
                parentModel.getControllerHandle(), designTimeProxView);
        end
        
        function appModel = getAppModel(model)
            % Get AppModel through the design time model hierarchy
            appModel = model;
            while ~isa(appModel, 'appdesigner.internal.model.AppModel')
                if isa(appModel, 'matlab.ui.Figure')
                    appModel = appModel.AppModel;
                else
                    appModel = appModel.Parent;
                end
            end            
        end
    end
end

