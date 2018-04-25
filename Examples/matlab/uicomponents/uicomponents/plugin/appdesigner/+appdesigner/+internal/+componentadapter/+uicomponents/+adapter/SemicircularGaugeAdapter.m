classdef SemicircularGaugeAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for Semicircular Gauge
    
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
        function obj = SemicircularGaugeAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        function controllerClass = getComponentDesignTimeController(obj)
            controllerClass = 'appdesigner.internal.componentcontroller.DesignTimeGaugeComponentController';
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.control.SemicircularGauge';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/SemicircularGaugeModel';
        end
    end
    
     % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
           codeSnippet = sprintf('uigauge(%s, ''semicircular'')', parentName);                                                                                    
        end
    end 
end

