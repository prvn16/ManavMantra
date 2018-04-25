classdef ListBoxAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for a ListBox component

    % Copyright 2014-2016 The MathWorks, Inc.

    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time. 
        OrderSpecificProperties = {'Items','ItemsData'};
        
        % the "Value" property of the component
        ValueProperty = 'Value';
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = ListBoxAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)        
        function className = getComponentType()
            className = 'matlab.ui.control.ListBox';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/ListBoxModel';
        end
    end
    
     % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)            
            codeSnippet = sprintf('uilistbox(%s)', parentName);
        end         
    end
end

