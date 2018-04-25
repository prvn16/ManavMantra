classdef VisualComponentAdapter < appdesigner.internal.componentadapterapi.ComponentAdapter & ...
                                  appdesigner.internal.componentadapterapi.mixins.ComponentDefaults 
    %
    % VisualComponentAdapter  Base class for all visual component adapters integrated
    %                         into the AppDesigner
    %
    % ComponentDefaults mixin provides all component property defaults
    % related functionalities, like, get design-time defaults, get runtime
    % defaults, etc.
    %
    % Copyright 2013-2017 The MathWorks, Inc.
    %
    
    properties (Abstract, SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and
        % instantiating the design-time MCOS component.  Adapters that
        % do not have order specific properties will set this property to
        % be an empty cell array {}
        OrderSpecificProperties
        
        % the "Value" property of the component.  For example, a Lamp's
        % ValueProperty is 'Value' and a TextField's ValueProperty is
        % 'Text'.
        % Adapters that do not have a "Value" property will set this to
        % empty []
        ValueProperty
    end
    
    properties
        % an array of common properties that code is not be generated for
        CommonPropertiesThatDoNotGenerateCode = {...
            'Children',...
            'CreateFcn',...
            'DeleteFcn',...
            'DesignTimeProperties',...
            'InnerPosition', ...
            'OuterPosition',...          
            'Parent', ...
            'Tag', ...
            'UserData', ...
            };
    end
   
    
    methods
        function obj = VisualComponentAdapter(varargin)
            % construct a visual component adapter
            % the first arg passed to the base class is 'true' indicating
            % it is a Visual Component
            obj@appdesigner.internal.componentadapterapi.ComponentAdapter(...,
                true, varargin{:});
        end
             
        % ---------------------------------------------------------------------
        % Code Gen Method to return an array of property names, in the correct
        % order, as required by Code Gen
        % ---------------------------------------------------------------------
        function propertyNames = getCodeGenPropertyNames(obj, componentHandle)
            % The algorithm builds the property names the following way:
            %
            % - Explicit OrderSpecific properties
            %
            % - All other properties
            %
            % - Position
            %
            % - Value Property
            
            import appdesigner.internal.componentadapterapi.VisualComponentAdapter;
            
            % Get all properties as a struct and get the property names
            % properties as a starting point 
            propertyValuesStruct = get(componentHandle);
            allProperties = fieldnames(propertyValuesStruct);
            
            readOnlyProperties = VisualComponentAdapter.listNonPublicProperties(componentHandle);
            
            allProperties = setdiff(allProperties, readOnlyProperties, 'stable');
            
            % Properties that are always ignored and are never set when
            % generating code
            %
            % Remove these from both the properties and order specific
            % properties
            ignoredProperties = obj.CommonPropertiesThatDoNotGenerateCode;
            
            % Get properties related to mode so some can be excluded
            [autoModeProperties, ~, manualModeProperties] = ...
                matlab.ui.control.internal.model.PropertyHandling.getModeProperties(propertyValuesStruct);
            
            % Rationale for excluding sets for specific mode properties:
            %
            % When a property is 'auto', then there is no need to generate
            % code for either corresponding sibling property nor the mode.
            %
            %     Ex: A Gauge with autocalculatd MajorTicks and
            %         MajorTicksMode = 'auto'
            %
            %     The generated code should not reflect either of these
            %     properties, as setting MajorTicks will result in the
            %     'mode' being flipped.  Setting MajorTicksMode to 'auto'
            %     would be redundant, as that is the default value for all
            %     'Mode' properties.
            %
            % When a property is 'manual', then there is no need to generate
            % code for the mode, and the mode property is excluded.
            %
            %     Ex: A Gauge with custom MajorTicks and MajorTicksMode =
            %         'manual'
            %
            %     The generated code should reflect only the MajorTicks
            %     being set.  Setting MajorTicks ensures the users custom
            %     value is honored, and will as a side effect flip the mode
            %     to manual.  The user does not need to see the mode being
            %     set to manual, as that is redundant as well as noisy.
            modePropertiesToIgnore = [autoModeProperties, manualModeProperties];
            
            if isempty(obj.OrderSpecificProperties)
                firstProperties = obj.OrderSpecificProperties;
            else
                % 'stable' preserves order (maintaining the user's order)
                %
                % otherwise, it would be alphabetical
                firstProperties = setdiff(obj.OrderSpecificProperties, ignoredProperties, 'stable');
            end
            
            % Determine the last properties, as row
            propertiesAtEnd = {'Position'};
            
            if ~isempty(obj.ValueProperty)
                % Specific property is specified, it will be last
                propertiesAtEnd{end+1} = obj.ValueProperty;
            end
            
            % Find all properties that are not in a specific location
            % Remove the mode properties from the list of
            % allOtherProperties
            allOtherProperties = setdiff(allProperties, ...
                [ignoredProperties, firstProperties, ...
                propertiesAtEnd, modePropertiesToIgnore], 'stable');
            
            % Remove mode properties from first and end so they are not
            % automatically written.  Doing these set diffs on a smaller set
            % is more efficient than operating on the set.
            if ~isempty(firstProperties)
                firstProperties = setdiff(firstProperties, modePropertiesToIgnore, 'stable');
            end
            if ~isempty(propertiesAtEnd)
                propertiesAtEnd = setdiff(propertiesAtEnd, modePropertiesToIgnore, 'stable');
            end
            
            
            % Create the master list
            propertyNames = [...
                firstProperties, ...
                allOtherProperties', ...
                propertiesAtEnd, ...
                ];
            
        end
        
        % ---------------------------------------------------------------------
        % Code Gen Method that has the logic of whether the code should
        % show for that property.  This takes into consideration if the
        % property is a mode sibling or if it is a default.
        % ---------------------------------------------------------------------
        function showPropertyCode = shouldShowPropertySetCode(obj,isPropertyModeSibling, componentHandle,propertyName, defaultComponent)
            
            showPropertyCode = false;
            
            %  Sometimes an app file contains a dynamic property on the model
            %  unknown to the release.  In this situation,  code will try to be generated
            % for it causing an exception and code gen to stop.
            
            % The software now catches the exception  and return false for the
            % "shouldShowPropertySetCode() method.
            
            % Need to do a try-catch here, to allow isDefault() method
            % inside the try-catch to be executed becuase some components
            % overload it
            try
                
                % If the propertyName has a Mode sibling, and the Mode
                % sibling value is manual, always generate the code.
                if isPropertyModeSibling
                    if strcmp(componentHandle.([propertyName, 'Mode']), 'manual')
                        % Only show a mode sibling property if the Mode is
                        % manual.  When a mode sibling is 'auto' the code
                        % should not appear.
                        showPropertyCode = true;
                    end
                else
                    
                    % Property should only be written if value is different
                    % than the default value
                    isDefaultValue = obj.isDefault(componentHandle, propertyName, defaultComponent);
                    
                    if ~isDefaultValue
                        
                        showPropertyCode = true;
                    end
                end
                
            catch err
                % if the propertyName is not on the default component, then it is an unknown dynamic property
                % so don't try to generate code
                if ~isfield(defaultComponent,propertyName)
                    % If not a field, make sure showPropertyCode is set to false,
                    showPropertyCode = false;
                else
                    % otherwise its an unexpected error so rethrow it
                    rethrow(err);
                end
                
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
            % This method is overwritten by components where the
            % propertyName isn't on the component itself.. for instance
            % TitleString on the axes
            
            value = componentHandle.(propertyName);
            
            defaultValue = defaultComponent.(propertyName);
            
            % If the current value and the default value of the
            % component are the same,isDefaultValue should be true
            % If both properties are empty, but different data
            % types or sizes, this should be interpretted as that
            % they are the same.
            isDefaultValue = isequal(value, defaultValue) || ...
                ... Special case, both values are empty, but different dimensions
                all([isempty(value), isempty(defaultValue)]);
            
        end
        
        % ---------------------------------------------------------------------
        % Code Gen Method to return an array of property names, in the correct
        % order, as required by Code Gen
        % ---------------------------------------------------------------------
        
        function codeSnippet = getCodeGenPropertySet(obj,component,propertyName, codeName, parentCodeName)
            % GETCODEGENPROPERTYSET - Generates a line of code that would
            % set the property designated in the input propertyName.
            %
            % Components may want to dictate how specific properties appear
            % in the code the default implementation may look something
            % like this:
            % app.CodeName.Property = 'string';
            %
            % Where the axes may want the option to set the property
            % someother way:
            % convenienceFunction(app)
            %
            % One example is for the title of an Axes
            % Default: app.Axes2.Title.String = 'Title of my App';
            % Alternate: title('Title of my App');
            
            % Requirements/ Best practices
            % * The codeSnippet should be a string with no new lines.
            % * Leading white space and trailing new line is not required
            % and not recommended. The code will be formatted for spacing
            % requirements in the ComponentInitCode object
            % * It is best practice to include a trailing semi-colon in the
            % codeSnippet if the code you are producing would display
            % anything
            % * Your code should not produce mlint warnings, the
            % codeSnippet is directly user facing.
            % *
            
            value = component.(propertyName);
            codeSnippet = ...
                appdesigner.internal.codegeneration.ComponentCodeGenerator.generateStringForPropertySegment(...
                codeName, propertyName, value);
            
        end
        
        
        % ---------------------------------------------------------------------
        % When a component is added on the client, the client sends a child-added
        % event to MATLAB so the corresponding MCOS object can created.  Data
        % with this event is a set of properties that are set on the new MCOS
        % object.  This method takes as input a structure of those component
        % properties that are to be set.  Here is the opportunity for the
        % adapters to tweek them if needed.
        % ---------------------------------------------------------------------
        function processPropertiesStruct = processPropertiesToSet(obj,propertiesStruct)
            % the default implementation of this method is to reorder the
            % properties as defined by the OrderSpecificProperties
            % and Value properties of the adapter.
            
            % create an array of properties to be set in a specific order.
            % The "ValueProperty" is always to be last in the array
            if isempty(obj.ValueProperty)
                lastProperty = {};
            else
                lastProperty = obj.ValueProperty;
            end
            
            % need to remove the OrderSpecificProperties and ValueProperty
            % from the propertiesStruct passed in and then add them back in
            % a specific order
            
            % first get the property names in the structure
            propertyNames = fieldnames(propertiesStruct);
            
            % remove the orderedProperties and lastProperty from the cell array of property names
            trimmedPropertyList = setdiff(propertyNames,[obj.OrderSpecificProperties, lastProperty] );
            
            % add them back in propertyNames cell array in a specific order
            updatedPropertyList = [obj.OrderSpecificProperties, trimmedPropertyList', lastProperty];
            
            % only apply properties that belong to both the changed
            % properties and the list of properties to generate code
            propertiesOfInterestToModel = intersect(fieldnames(propertiesStruct), updatedPropertyList);
            
            % order the fields in the propertiesStruct according to the new
            % updatedPropertyList
            processPropertiesStruct = orderfields(propertiesStruct, propertiesOfInterestToModel);
        end
        
        % Return component design-time controller class for creating
        % design-time component
        % The base class implementation provides a standard way to
        % construct a design-time controller class:
        %     appdesigner.internal.componentcontroller.DesignTimeCOMPONENTNAMEController
        %     For example:
        %     appdesigner.internal.componentcontroller.DesigntimeCheckBoxController
        %
        % If a component's design-time controller doesn't follow the rule,
        % its adapter can override this method to return its controller
        % class
        function controllerClass = getComponentDesignTimeController(obj)
            componentType = obj.getComponentType();
            componentName = split(componentType, '.');
            componentName = componentName{end};
            
            controllerClass = ['appdesigner.internal.componentcontroller.DesignTime' ...
                componentName 'Controller'];            
        end
    end
    
    methods(Static)
        
        % ---------------------------------------------------------------------
        % Code Gen Method to return a status of whether the propertyName
        % entered has a 'Mode' sibling.  If the propertyName is YTick, and
        % YTickMode exists, the status will be true. propertyList is
        % expected to be a cell array of strings
        % ---------------------------------------------------------------------
        
        function isModeSibling = isModeSibling(propertyList, component)
            % ISMODESIBLING - Returns an array of booleans the same size as
            % propertyList.  It returns 1 if the propertyName + 'Mode'
            % property exists on the component.
            
            isModeSibling = false(size(propertyList));
            componentProperties = properties(component);
            
            for index = 1:numel(propertyList)
                
                propertyName = [propertyList{index}, 'Mode'];
                
                % Use 'properties' method, as that only introspects public
                % properties
                %
                % HG Objects have Hidden underlying mode properties which
                % are not relevant code generation.  Code Generation is
                % only concerned with properties that have an
                % auto-calculating behavior, like Ticks + TicksMode.
                isModeSibling(index) = any(strcmp(propertyName, componentProperties));
            end
            
        end
        
        %------------------------------------------------------------------
        
        function readOnlyProperties = listNonPublicProperties(componentHandle)
            % Filter out read-only properties
            mc = metaclass(componentHandle);
            % If SetAccess is not a string, it means only a list of classes
            % that have SetAccess to the property
            % Otherwise it would be 'private' or 'protected'.
            % In the metaclass, there's no Access information, only
            % SetAccess and GetAccess, and so only check SetAccess to see
            % if it's a readonly propery or not
            readOnlyPropertyIxs = find(arrayfun(@(x) ~ischar(x.SetAccess) || ~strcmp(x.SetAccess, 'public'), mc.PropertyList));
            readOnlyProperties = arrayfun(@(x) mc.PropertyList(x).Name, readOnlyPropertyIxs, 'UniformOutput', false)';
        end
        %------------------------------------------------------------------
        
    end
    
end

