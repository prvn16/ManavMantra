classdef TabGroupAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for TabGroup
    
    % Copyright 2014-2017 The MathWorks, Inc.
 
    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time. 
        OrderSpecificProperties = {}
        
        % the "Value" property of the component
        ValueProperty = [];
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = TabGroupAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        % ---------------------------------------------------------------------
        % Code Gen Method to return an array of property names, in the correct
        % order, as required by Code Gen
        % ---------------------------------------------------------------------
        function propertyNames = getCodeGenPropertyNames(obj, componentHandle)
            
            import appdesigner.internal.componentadapterapi.VisualComponentAdapter;
            
             % Get all properties as a struct and get the property names
            % properties as a starting point
            propertyValuesStruct = get(componentHandle);
            allProperties = fieldnames(propertyValuesStruct);
            
            % Properties that are always ignored and are never set when
            % generating code
            %
            % Remove these from both the properties and order specific
            % properties
            readOnlyProperties = VisualComponentAdapter.listNonPublicProperties(componentHandle);

            ignoredProperties = [obj.CommonPropertiesThatDoNotGenerateCode, readOnlyProperties, {...
                'ButtonDownFcn',...
                'SelectedTab',...
                'SizeChangedFcn',...
                'UIContextMenu',...
                'Units',...
                }];
            
            
            % Determine the last properties, as row
            propertiesAtEnd = {'Units',  'Position'};
            
            % List of properties that should be listed first, as row
            propertiesAtBeginning = { ...
                % AutoResizeChildren is hidden so explicitly add it.
                % Should be listed before SizeChangedFcn to avoid the
                % warning message when both have non-default values
                % (AutoResizeChildren off and SizeChangedFcn non-empty).
                'AutoResizeChildren' ...
            };
            
            % Create the master list
            propertyNames = [ ...
                propertiesAtBeginning'; ...
                setdiff(allProperties, ...
                [ignoredProperties, propertiesAtEnd], 'stable');...
                propertiesAtEnd' ...
            ];
            
        end
        
        function status = buildAllChildrenBeforeGrandChildren(obj)
            % This method is used to help code generation determine if the 
            % children of the parent should be created before any 
            % grandchildren of a component is created.  This affects the 
            % order in which the code is generated which will affect the 
            % way the runtime version of the app is constructed.
            status = true;           
        end
        
        function controllerClass = getComponentDesignTimeController(obj)
            controllerClass = 'matlab.ui.internal.DesignTimeTabGroupController';
        end
    end
    
    methods (Access = protected)
        function applyCustomComponentDesignTimeDefaults(obj, component)
            % Apply custom design-time component defaults to the component
            %            
            % Set design time properties for Position
            component.Position = [10 10 260 221];
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)        
        function className = getComponentType()
            className = 'matlab.ui.container.TabGroup';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/TabGroupModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
            codeSnippet = sprintf('uitabgroup(%s)', parentName);                        
        end
    end
end

