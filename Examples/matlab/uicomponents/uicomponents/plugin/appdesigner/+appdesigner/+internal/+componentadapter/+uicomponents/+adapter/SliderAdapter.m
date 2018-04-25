classdef SliderAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for a Slider component

    % Copyright 2013-2016 The MathWorks, Inc.

    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time. 
        OrderSpecificProperties = {'Limits','MajorTicks','MajorTickLabels'}
        
        % the "Value" property of the component
        ValueProperty = 'Value';
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = SliderAdapter(varargin)
             obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        function controllerClass = getComponentDesignTimeController(obj)
            controllerClass = 'appdesigner.internal.componentcontroller.DesignTimeInteractiveTickComponentController';
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)        
        function className = getComponentType()
            className = 'matlab.ui.control.Slider';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/SliderModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
            codeSnippet = sprintf('uislider(%s)', parentName);                        
        end  
    end
end

