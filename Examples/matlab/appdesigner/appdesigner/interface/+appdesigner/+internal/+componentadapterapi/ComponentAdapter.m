classdef ComponentAdapter < appdesigner.internal.componentadapterapi.ComponentRegistration
    %
    % ComponentAdapter  Base class for all adapters integrated into the Design Environment
    %
    % Copyright 2013-2016 The MathWorks, Inc.
    %
    
    properties(SetAccess=private)
        % a property to signify if this adapter corresponds to a visual or
        % non-visual component
        % its value will be either true or false
        IsVisual
    end
    
    methods
        % Constructor
        function obj = ComponentAdapter(isVisual, varargin)
            % construct a component adapter instance.
            % - The 'isVisual' argument is logical value to indicate if the
            % component is visual or non-visual
            
            % verify the isVisual input arg is logical
            assert(islogical(isVisual),...
                'invalid design-time component type in constructor');
            
            % set the IsVisual property
            obj.IsVisual = isVisual;
        end
    end
    
    methods (Static, Abstract)
        % getCodeGenCreation Returns a generated code snippet that creates
        % the component.
        %
        % Ex:
        %      'uigauge(appWindow, ''circular'')'
        codeSnippet = getCodeGenCreation(parentName);
    end
    
    methods(Abstract)
        % createDesignTimeComponent  Return an instance of a desing-time component
        %    component = createDesignTimeComponent() will return an instance of a
        %                design-time component to be integrated into the Design Area.
        %
        %    Example:
        %        component = matlab.ui.control.Lamp;
        component = createDesignTimeComponent(obj);
        
        % getCodeGenPropertyNames Returns a list of properties that
        % reflects which properties should be used in code generation.
        %
        % The order returned will be the order properties are set.  Any
        % properties with an interdependency on other properties should be
        % set in the appropriate order.
        %
        % The specific guidelines are:
        %
        % - Properties that affect other properties and need to be set
        %   first.
        %
        % - All other properties
        %
        % - Size
        %
        % - Location
        %
        % - The main "value" property of the component.  "Value" means the
        % main property a user would access in a callback to get the
        % component's state, whether it be a numeric value, text, a
        % selected property, etc...
        %
        % Ex:
        %      {'Editable, 'Enabled', 'Size', 'Location', 'Text'}
        propertyNames = getCodeGenPropertyNames(obj);
        
    end
    
end

