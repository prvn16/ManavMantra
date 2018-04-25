classdef TreeAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for a Tree component
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time.
        OrderSpecificProperties = {};
        
        % the "Value" property of the component
        ValueProperty = [];
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = TreeAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.container.Tree';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/TreeModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            codeSnippet = sprintf('uitree(%s)', parentName);
        end
    end
    
end
