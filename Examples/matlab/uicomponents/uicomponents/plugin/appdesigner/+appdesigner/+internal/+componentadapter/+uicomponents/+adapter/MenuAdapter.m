classdef MenuAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for Menu

    % Copyright 2017 The MathWorks, Inc.

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
        function obj = MenuAdapter(varargin)
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
                'Clipping',...
                'Position',...
                'UIContextMenu',...
                }];
            
            % Create the master list
            propertyNames = ...
            [setdiff(allProperties, ...
            [ignoredProperties], 'stable')];

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
            controllerClass = 'matlab.ui.internal.DesignTimeMenuController';
        end
    end

    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.container.Menu';
        end

        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/MenuModel';
        end
    end

    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)

        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            codeSnippet = sprintf('uimenu(%s)', parentName);
        end
    end

end

