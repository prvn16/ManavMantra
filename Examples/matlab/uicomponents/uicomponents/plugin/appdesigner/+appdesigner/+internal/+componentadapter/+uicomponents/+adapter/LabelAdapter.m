classdef LabelAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for Label
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time.
        OrderSpecificProperties = {}
        
        % the "Value" property of the component
        ValueProperty = 'Text';
    end
 
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = LabelAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        % ---------------------------------------------------------------------
        % Extend Code Gen Method in VisualComponentAdapter to handle
        % single-line Text
        % ---------------------------------------------------------------------
        
        function codeSnippet = getCodeGenPropertySet(obj, component, propertyName, codeName, parentCodeName)
            
            codeSnippet = getCodeGenPropertySet@appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj, component, propertyName, codeName, parentCodeName);
            
            value = component.(propertyName);
            
            switch (propertyName)
                
                case 'Text'
                    if numel(value)==1 && iscell(value)
                        % If value is something like {'single line'}
                        % Generated the code for 'single line' which
                        % does not have a cell
                        value = value{1};
                    end
                    codeSnippet = ...
                        appdesigner.internal.codegeneration.ComponentCodeGenerator.generateStringForPropertySegment(...
                        codeName, propertyName, value);
                    
            end
        end
        
        
        % ---------------------------------------------------------------------
        % Code Gen Method to return a status of whether the value
        % represents the default value of the component. If isDefault
        % returns true, no code will be generated for that property
        % ---------------------------------------------------------------------
        
        function isDefaultValue = isDefault(obj,componentHandle,propertyName, defaultComponent)
            % ISDEFAULT - Returns a true or false status based on whether
            % the value of the component corresponding to the propertyName
            % inputted is the default value.  If the value returned is
            % true, then the code for that property will not be displayed
            % in the code at all
            
            
            value = componentHandle.(propertyName);
            
            defaultValue = defaultComponent.(propertyName);
            
            % If the current value and the default value of the
            % component are the same,isDefaultValue should be true
            % If both properties are empty, but different data
            % types or sizes, this should be interpretted as that
            % they are the same.
            if strcmp('Text', propertyName)
                % Text will be presented as a string in code when possible,
                % even if the value is a 1x1 cell array.                
                
                isDefaultValue = isequal(value, defaultValue) || ...
                    ... The default value is a string and the actual value is a 1x1 cell array with that string
                    (numel(value)==1 && iscell(value) && isequal(value, {defaultValue})) ||...
                    ... Special case, both values are empty, but different dimensions
                    all([isempty(value), isempty(defaultValue)]);
                
            else
                
                isDefaultValue = isequal(value, defaultValue) || ...
                    ... Special case, both values are empty, but different dimensions
                    all([isempty(value), isempty(defaultValue)]);
            end
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.control.Label';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/LabelModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
            codeSnippet = sprintf('uilabel(%s)', parentName);
        end
    end
end

