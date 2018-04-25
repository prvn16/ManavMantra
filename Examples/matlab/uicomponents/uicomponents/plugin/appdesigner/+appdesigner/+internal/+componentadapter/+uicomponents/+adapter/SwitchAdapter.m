classdef SwitchAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for Slider Switch
    
    % Copyright 2013-2016 The MathWorks, Inc.

    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time. 
        OrderSpecificProperties = {'Items','ItemsData'}
        
        % the "Value" property of the component
        ValueProperty = 'Value';
    end

    % ---------------------------------------------------------------------
    % Constructor methods
    % ---------------------------------------------------------------------
    methods
        function obj = SwitchAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        function controllerClass = getComponentDesignTimeController(obj)
            controllerClass = 'appdesigner.internal.componentcontroller.DesignTimeStateComponentController';
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.control.Switch';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/SliderSwitchModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
          codeSnippet = sprintf('uiswitch(%s, ''slider'')', parentName);
        end 
    end
end

