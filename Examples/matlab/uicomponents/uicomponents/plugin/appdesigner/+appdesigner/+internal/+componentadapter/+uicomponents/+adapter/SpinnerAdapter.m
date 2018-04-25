classdef SpinnerAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for Spinner
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time. 
        OrderSpecificProperties = {'Step','LowerLimitInclusive','UpperLimitInclusive'}
        
        % the "Value" property of the component
        ValueProperty = 'Value';
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = SpinnerAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
    
        % When a component is added on the client, the client sends a child-added 
        % event to MATLAB so the corresponding MCOS object can created.  Data 
        % with this event is a set of properties that are set on the new MCOS
        % object.  This method takes as input a structure of those component
        % properties that are to be set.  Here is the opportunity for the 
        % adapters to tweek them if needed.
        function processPropertiesStruct = processPropertiesToSet(obj,propertiesStruct)           
            % make sure lower and upper limits are strings as expected by
            % the NumberFieldController
            propertiesStruct.Step = propertiesStruct.Step;
            propertiesStruct.LowerLimit = num2str(propertiesStruct.LowerLimit);
            propertiesStruct.UpperLimit = num2str(propertiesStruct.UpperLimit);
            
            % have the base class finish the processing
            processPropertiesStruct = ...
                processPropertiesToSet@appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj,propertiesStruct);
        end
        
        % ---------------------------------------------------------------------
    end

    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.control.Spinner';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/SpinnerModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)            
            
            codeSnippet = sprintf('uispinner(%s)', parentName);
        end
    end
end

