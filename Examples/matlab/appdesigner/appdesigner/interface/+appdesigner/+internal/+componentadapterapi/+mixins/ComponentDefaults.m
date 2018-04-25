classdef ComponentDefaults < handle
    % ComponentDefaults  Mixin for managing component defaults:
    %   Design-time component defaults
    %   Runtime component defaults
    %                         
    %
    % Copyright 2017 The MathWorks, Inc.
    %
    
    methods(Access = public, Sealed = true)
        % ---------------------------------------------------------------------
        % get the component Design Time default values
        % This method is sealed since template methods have been provided
        % for sub-class to override or customize behaviours
        % ---------------------------------------------------------------------
        function defaultValues = getComponentDesignTimeDefaults(obj)
            % return a struct of component properties and their
            % design-time default values.  To get the defaults the
            % design-time component is created without realizing the view            
            
            % create the parent of the design time component
            parent = obj.createDesignTimeParentComponent();
            
            % create the component and parent it
            component = obj.createDesignTimeComponent(parent);            
            
            % Callback to delete components, including parents, created
            % during getting defaults
            function deleteDesignTimeComponent(designTimeComponent)
                % Loop up to find the figure parent of the component
                parentComponent = designTimeComponent;
                while ~isempty(parentComponent.Parent) && ...
                        ~isa(parentComponent.Parent, 'matlab.ui.Root') && ...
                        ~isa(parentComponent, 'matlab.ui.Figure')
                    parentComponent = parentComponent.Parent;
                end
                
                delete(parentComponent);
            end
            oc = onCleanup(@()deleteDesignTimeComponent(component));
            
            % create design time controller to get the defaults
            controllerClass = obj.getComponentDesignTimeController();
            controller = feval(controllerClass, ...
                component, [], appdesigner.internal.componentview.EmptyProxyView());
            
             % Get PV pairs of the component
            propertyNameValues = controller.getPVPairsForView(component);
            
            % convert to a struct
            defaultValues = appdesservices.internal.peermodel.convertPvPairsToStruct(...
                propertyNameValues);
            
            % Remove DesignTimeProperties which is added by
            % DesignTimeController
            defaultValues = rmfield(defaultValues, 'DesignTimeProperties');
            
            % Get customized component design-time defaults            
            defaultValues = obj.customizeComponentDesignTimeDefaults(defaultValues);
        end
    end
    
    methods       
        % ---------------------------------------------------------------------
        % create the Design Time component for getting Design Time default values
        % ---------------------------------------------------------------------
        function component = createDesignTimeComponent(obj, parent)
            % design time specific property values that are different from
            % default runtime's
            
            % Parent must be the first one in PV pairs for GBT comonents
            % Create the component, passing in PV Pairs
            component = feval(obj.getComponentType(), 'Parent', parent);
            
            obj.applyCustomComponentDesignTimeDefaults(component);
        end        
                
        % ---------------------------------------------------------------------
        % get the component run-time default values
        % ---------------------------------------------------------------------
        function defaultValues = getComponentRunTimeDefaults(obj)
            % return a struct of component properties and their
            % run-time default values
            
            % get the run time defaults for a component parented to a
            % uifigure
            parentFigure = appdesigner.internal.componentadapter.uicomponents.adapter.createUIFigure();
            % delete the figure
            cf = onCleanup(@()delete(parentFigure));
            component = feval(obj.getComponentType(), ...
                'Parent', parentFigure);
            defaultValues = get(component);
            
            % AutoResizeChildren property is hidden, it is not returned by 'get'
            if(isprop(component, 'AutoResizeChildren'))
                defaultValues.AutoResizeChildren = component.AutoResizeChildren;
            end
            
            delete(component);
        end        
    end
    
    methods (Access = protected)        
        % Create the Design Time parent component to parent design-time component
        % for getting Design Time default values
        function parent = createDesignTimeParentComponent(obj)
            % In most cases, the component is parented to a UIFigure,
            % but for children of TabGroup, ButtonGroup, the parent is
            % different
            parent = appdesigner.internal.componentadapter.uicomponents.adapter.createUIFigure();            
        end        
        
        % Apply custom design-time defaults to the design-time component
        function applyCustomComponentDesignTimeDefaults(obj, component)
            % The sub-class (individual component adapter) implement this
            % function to apply custom design-time component defaults to 
            % the component
            %
            % Set custom value to the component
            %
            % Example Code in sub-class adapter:
            %     % Apply custom design-time value to the property
            %     component.Position = [0 0 300 185];            
        end
        
        % Customize the Design Time component default values
        function defaultValues = customizeComponentDesignTimeDefaults(obj, defaultValues)
            % The sub-class (individual component adapter) implement this
            % function to modify component defaults struct
            %
            % Return a modified default value struct
            %
            % Add value/modify value to the struct directly
            %
            % Example Code in sub-class adapter:
            %     % Modify value on struct because it's read-only on the
            %     %component
            %     defaultValues.InnerPosition = [62 43 210 130];
            %
        end
    end    
end

