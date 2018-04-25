classdef UIFigureAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for uifigure
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time.
        OrderSpecificProperties = {}
        
        % the "Value" property of the component
        ValueProperty = [];
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = UIFigureAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        % ---------------------------------------------------------------------
        % get the component run-time default values
        % ---------------------------------------------------------------------
        function defaultValues = getComponentRunTimeDefaults(obj)
            % return a pvPair array of figure properties and their
            % run-time default values
            
            model = appdesigner.internal.componentadapter.uicomponents.adapter.createUIFigure();
            c = onCleanup(@()delete(model));
            defaultValues = get(model);
            
            % AutoResizeChildren property is hidden, it is not returned by 'get'
            defaultValues.AutoResizeChildren = model.AutoResizeChildren;
        end
        
        % ---------------------------------------------------------------------
        % create the Design Time component for getting Design Time default values
        % ---------------------------------------------------------------------
        function component = createDesignTimeComponent(obj, ~)
            component = appdesigner.internal.componentadapter.uicomponents.adapter.createUIFigure();
            
            obj.applyCustomComponentDesignTimeDefaults(component);
        end
        
        function propertyNames = getCodeGenPropertyNames(obj, componentHandle)
            
            % Use an explicit subset of properties from the figure that App
            % Designer supports
            propertyNames = {...                
                % AutoResizeChildren should be listed before SizeChangedFcn to avoid the
                % warning message when both have non-default values
                % (AutoResizeChildren off and SizeChangedFcn non-empty).
                'IntegerHandle'...
                'NumberTitle'...                
                'AutoResizeChildren' ...    
                'Color' ...
                'Colormap' ...
                'Position' ...
                'Name' ...
                'Resize' ...
                'CloseRequestFcn' ...
                'SizeChangedFcn' ...
                'BusyAction' ...
                'Interruptible' ...                
                };
        end
        
        function isDefaultValue = isDefault(obj, componentHandle, propertyName, defaultComponent)
            % ISDEFAULT - Returns a true or false status based on whether
            % the value of the component corresponding to the propertyName
            % inputted is the default value.  If the value returned is
            % true, then the code for that property will not be displayed
            % in the code at all 
            
            
            switch (propertyName)
                case 'CloseRequestFcn'
                    value = componentHandle.(propertyName);
                    isDefaultValue = isempty(value) || strcmp(value, 'closereq');
                    
                otherwise
                    % Call superclass with the same parameters
                    isDefaultValue = isDefault@appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj,componentHandle,propertyName, defaultComponent);
            end
        end
        
        function controllerClass = getComponentDesignTimeController(obj)
            controllerClass = 'matlab.ui.internal.DesignTimeUIFigureController';
        end
    end
    
    methods (Access = protected)
        % Create the Design Time parent component to parent design-time component
        % for getting Design Time default values
        function parent = createDesignTimeParentComponent(~)
            % no-op for uifigure
            parent = [];
        end
        
        function applyCustomComponentDesignTimeDefaults(obj, component)
            % Apply custom design-time component defaults to the component
            
            % Set design-time defatuls to the component
            component.Position = [100 100 640 480];
            component.Color = [.94 .94 .94];
            component.Name =  '';
        end
    end
    
    methods(Static)
        % ---------------------------------------------------------------------
        % Palette Entry Methods
        % ---------------------------------------------------------------------
        function className = getComponentType()
            className = 'matlab.ui.Figure';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/UIFigureModel';
        end
        
        % ---------------------------------------------------------------------
        % Code Gen Methods
        % ---------------------------------------------------------------------        
        function codeSnippet = getCodeGenCreation(~, ~, ~)
            codeSnippet = 'uifigure';
        end
    end
end
