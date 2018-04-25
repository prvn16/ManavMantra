classdef RadioButtonAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for RadioButton
    
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
        function obj = RadioButtonAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        % When a component is added on the client, the client sends a child-added
        % event to MATLAB so the corresponding MCOS object can created.  Data
        % with this event is a set of properties that are set on the new MCOS
        % object.  This method takes as input a structure of those component
        % properties that are to be set.  Here is the opportunity for the
        % adapters to tweek them if needed.
        function processPropertiesStruct = processPropertiesToSet(obj,propertiesStruct)
            % If this radioButton is not the 'Selected' one in the group,
            % then do not set the selected property on the radioButton MCOS
            % object.
            % If this is allowed, the following scenario could occur when
            % opening an App with a radio button group where the first radio
            % button is NOT the selected one.  :
            %    a. On the open, the client adds the radio Button
            %       group.  The client responds and a RadioButton group is
            %       added on the server
            %    b. The client then adds the first radio button to the
            %       group
            %    c. The server responds and creates the radio button and
            %       parents it to the group.  The server logic sets the
            %       Selected State of the radio button to true because it
            %       is the first radio button added.
            %    d. However the actual value of the Selected property in
            %       the propertiesStruct is false, and when 'false' is set
            %       on the MCOS radio button an error condition occurs
            %       and an error thrown
            if ( ~propertiesStruct.Value )
                % remove the Selected property from the set of properties
                % to set on the MCOS object.
                propertiesStruct = rmfield(propertiesStruct,'Value');
                
                % The ValueProperty defined in the adapter is the property
                % that end ups being set last as defined in this method's
                % base implementation.  For this adapter this property
                % is 'Selected'.  Since the 'Selected' property is
                % removed from the struct, the ValueProperty must be set
                % to [] to avoid errors when the properties are set and
                % 'Selected' property is not in the struct
                obj.ValueProperty = [];
            else
                % go back to the default value of the ValueProperty
                obj.ValueProperty = 'Value';
            end
            
            % have the base class finish the processing
            processPropertiesStruct = ...
                processPropertiesToSet@appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj,propertiesStruct);
        end
        
        function defaultValues = getComponentRunTimeDefaults(obj)
            % overload the base  getComponentRunTimeDefaults because this
            % component cannot be parented to uifigure to get runtime
            % defaults
            component = feval(obj.getComponentType());
            defaultValues = get(component);
            delete(component);
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
            className = 'matlab.ui.control.RadioButton';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/RadioButtonModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
            codeSnippet = sprintf('uiradiobutton(%s)', parentName);
        end
    end
    
    methods(Access = protected)
        function parent = createDesignTimeParentComponent(obj)
            % Needs to be parented to ButtonGroup, and then ButtonGroup to
            % be under parent accordingly so all the default values are
            % initialized correctly
            
            % Create UIFigure as a parent to ButtonGroup
            uiFigure = createDesignTimeParentComponent@...
                appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj);
            
            % Create ButtonGroup as a parent for RadioButton
            buttonGroupAdapter = appdesigner.internal.componentadapter.uicomponents.adapter.ButtonGroupAdapter();
            parent = buttonGroupAdapter.createDesignTimeComponent(uiFigure);
        end
        
        function defaultValues = customizeComponentDesignTimeDefaults(obj, defaultValues)
            % The parenting process sets RadioButton to Value == true
            % even through the true default value is Selected == false
            % Manually find 'Value' property and change value to false            
            defaultValues.Value = false;
        end
    end    
end

