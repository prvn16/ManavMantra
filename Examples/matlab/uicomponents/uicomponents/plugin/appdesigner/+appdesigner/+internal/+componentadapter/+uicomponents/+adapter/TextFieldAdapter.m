classdef TextFieldAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for TextField
    
    % Copyright 2013-2016 The MathWorks, Inc.

    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time. 
        OrderSpecificProperties = {}
        
        % the "Value" property of the component
        ValueProperty = 'Value';
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = TextFieldAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.control.EditField';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/TextFieldModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
            codeSnippet = sprintf('uieditfield(%s, ''text'')', parentName);                        
        end
    end
end

