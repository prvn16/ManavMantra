classdef ButtonGroupAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for ButtonGroup
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
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
        function obj = ButtonGroupAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        function controllerClass = getComponentDesignTimeController(obj)
            controllerClass = 'matlab.ui.internal.DesignTimeButtonGroupController';
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)        
        function className = getComponentType()
            className = 'matlab.ui.container.ButtonGroup';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/ButtonGroupModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            
            codeSnippet = sprintf('uibuttongroup(%s)', parentName);                        
        end
    end
    
    methods
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
                'BorderWidth',...
                'Clipping',...
                'FontUnits',...
                'HighlightColor',...
                'SelectedObject',...
                'ShadowColor',...
                'UIContextMenu',...
                'Units',...
                }];
            
            % Determine the last properties, as row
            propertiesAtEnd = {'FontUnits', 'FontSize', 'Units', 'Position'};

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
                propertiesAtEnd'...            
            ];
            
        end
    end
    
    methods (Access = protected)
        function applyCustomComponentDesignTimeDefaults(obj, component)
            % Apply custom design-time component defaults to the component
            %            
            % Set design time properties for Position/Title            
            component.Position = [10 10 123 106];
            component.Title = getString(message('MATLAB:ui:defaults:ButtonGroupTitle'));
        end
    end
end

