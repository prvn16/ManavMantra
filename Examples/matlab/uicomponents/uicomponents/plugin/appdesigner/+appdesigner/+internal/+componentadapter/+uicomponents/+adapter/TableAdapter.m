classdef TableAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for Table

    % Copyright 2015-2017 The MathWorks, Inc.

    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time.
        OrderSpecificProperties = {}

        % the "Value" property of the component
        % @ToDo maybe Data should be here.
        ValueProperty = [];
    end

    properties(Constant)                
        % an PV pairs of customized property/values for the design time
        % component
        CustomDesignTimePVPairs = {'Position', [0 0 302 185], ...
            'RowName', [], ...
            'ColumnName', {...
            getString(message('MATLAB:ui:defaults:UITableColumn1Name')), ...
            getString(message('MATLAB:ui:defaults:UITableColumn2Name')), ...
            getString(message('MATLAB:ui:defaults:UITableColumn3Name')), ...
            getString(message('MATLAB:ui:defaults:UITableColumn4Name'))...
            }, ...
            };
    end
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = TableAdapter(varargin)
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

            % 'RowName' is not in the inspector so normally it would be an ignored property.  However code is generated for it anyways 
            % to set its value to empty to override its default of 'numbered' because 'numbered' is not yet supported.
            % That is done in the DesignTimeTableController
            ignoredProperties = [obj.CommonPropertiesThatDoNotGenerateCode, readOnlyProperties, {...
                'BackgroundColor',...
                'ButtonDownFcn',...
                'ColumnFormat',...
                'Data'...
                'FontUnits',...
                'KeyPressFcn',...
                'KeyReleaseFcn',...
                'RearrangeableColumns',...
                'TooltipString'...
                'UIContextMenu',...
                'Units',...
                }];

            % Determine the last properties, as row
            propertiesAtEnd = {'FontSize',  'Position'};
            
            % Filter out properties to be at the end,otherwise there would
            % be duplicated name in the list, e.g. Position occurs twice
            propertyNames = setdiff(allProperties, [ignoredProperties, propertiesAtEnd], 'stable');            
        
            % Create the master list
            propertyNames = [...
                propertyNames', ...
                propertiesAtEnd, ...
                ];

        end
        
         function isDefaultValue = isDefault(obj, componentHandle, propertyName, defaultComponent)
            % ISDEFAULT - Returns a true or false status based on whether
            % the value of the component corresponding to the propertyName
            % inputted is the default value.  If the value returned is
            % true, then the code for that property will not be displayed
            % in the code at all
            
            % Override to handle the checks for design-time specific
            % properties: DataSize            
            
            switch (propertyName)             
                 
                case 'DataSize'
                    isDefaultValue = isequal(componentHandle.Data, []);
               
                otherwise
                    % Call superclass with the same parameters
                    isDefaultValue = isDefault@appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj,componentHandle,propertyName, defaultComponent);
            end
         end
        
         function controllerClass = getComponentDesignTimeController(obj)
             controllerClass = 'matlab.ui.internal.DesignTimeTableController';
         end
    end
    
    methods (Access = protected)
        function applyCustomComponentDesignTimeDefaults(obj, component)
            % Apply custom design-time component defaults to the component
            %            
            % Set design time properties
            component.Position = [0 0 302 185];
            component.RowName = [];
            component.ColumnName = {...
                getString(message('MATLAB:ui:defaults:UITableColumn1Name')), ...
                getString(message('MATLAB:ui:defaults:UITableColumn2Name')), ...
                getString(message('MATLAB:ui:defaults:UITableColumn3Name')), ...
                getString(message('MATLAB:ui:defaults:UITableColumn4Name'))...
                };
        end
    end

    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.control.Table';
        end

        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/TableModel';
        end
    end

    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)

        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            codeSnippet = sprintf('uitable(%s)', parentName);
        end
    end
end

