classdef UIAxesAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for UIAxes
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
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
        function obj = UIAxesAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end        
        
        % ---------------------------------------------------------------------
        % Code Gen Method to return an array of property names, in the correct
        % order, as required by Code Gen
        % ---------------------------------------------------------------------
        function propertyNames = getCodeGenPropertyNames(obj, componentHandle)
            % This needs to be overridden to ignore UIAxes'
            % handle properties - XLabel, YLabel, ZLabel, Title, XAxis, YAxis, ZAxis
            
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
                'Colormap',...                
                'SizeChangedFcn',...
                'UIContextMenu',...
                'ButtonDownFcn',...
                'Units',...   
                ... % UI Axes properties to ignore since they are sub-objects
                ... % and code-gen cannot handle sub-objects.
                'XLabel', ...
                'YLabel', ...
                'ZLabel', ...
                'Title', ...
                'Layout'... % Design-time property that does not need code-gen
                }];
            
             % Get properties related to mode so some can be excluded
            [autoModeProperties, ~, manualModeProperties] = ...
                matlab.ui.control.internal.model.PropertyHandling.getModeProperties(propertyValuesStruct);
             modePropertiesToIgnore = [autoModeProperties, manualModeProperties];
            
            propertiesAtEnd = {'Position'};
            
            % Filter out properties to be at the end,otherwise there would
            % be duplicated name in the list, e.g. Position occurs twice
            propertyNames = setdiff(allProperties, [ignoredProperties, propertiesAtEnd modePropertiesToIgnore], 'stable');
            
            %Create the master list
            propertyNames = [...
                ... % UIAxes Design-time properties that need to be looked at
                ... % for code-gen
                {'TitleString', 'XLabelString', 'YLabelString', 'ZLabelString'},...
                propertyNames', ...
                propertiesAtEnd, ...
                ];
            
            
        end
        
        function codeSnippet = getCodeGenPropertySet(obj, component, propertyName, codeName, parentCodeName)
            % GETCODEGENPROPERTYSET - Generates a line of code that would
            % set the property designated in the input propertyName.
            % This method handles any special code generation requirements
            % for specific UIAxes properties. For all other properties, it
            % calls the superclass that handles the code generation in the
            % default manner.
            % E.g. The title property should have the code
            % title(axeshandle, 'myAxes');
            
            switch (propertyName)
                
                case 'TitleString'
                    codeSnippet = sprintf('title(app.%s, ''%s'')',...
                        codeName,...
                        appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(component.Title.String));
                case 'XLabelString'
                    codeSnippet = sprintf('xlabel(app.%s, ''%s'')',...
                        codeName,...
                        appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(component.XLabel.String));
                case 'YLabelString'
                    codeSnippet = sprintf('ylabel(app.%s, ''%s'')',...
                        codeName,...
                        appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(component.YLabel.String));
                case 'ZLabelString'
                    codeSnippet = sprintf('zlabel(app.%s, ''%s'')',...
                        codeName,...
                        appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(component.ZLabel.String));
                otherwise
                    % Call superclass with the same parameters
                    codeSnippet = getCodeGenPropertySet@appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj,component,propertyName, codeName, parentCodeName);
            end
            
        end
        
        
        function isDefaultValue = isDefault(obj, componentHandle, propertyName, defaultComponent)
            % ISDEFAULT - Returns a true or false status based on whether
            % the value of the component corresponding to the propertyName
            % inputted is the default value.  If the value returned is
            % true, then the code for that property will not be displayed
            % in the code at all
            
            % Override to handle the checks for design-time specific
            % properties: XLabelString, YLabelString, ZLabelString, TitleString.
            
            switch (propertyName)
                
                case 'XLabelString'
                    isDefaultValue = strcmp(componentHandle.XLabel.String,'');
                case 'YLabelString'
                    isDefaultValue = strcmp(componentHandle.YLabel.String,'');
                case 'ZLabelString'
                    isDefaultValue = strcmp(componentHandle.ZLabel.String,'');
                case 'TitleString'
                    isDefaultValue = strcmp(componentHandle.Title.String,'');
                    
                otherwise
                    % Call superclass with the same parameters
                    isDefaultValue = isDefault@appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj,componentHandle,propertyName, defaultComponent);
            end
        end
        
    end
    
    methods (Access = protected)
        function applyCustomComponentDesignTimeDefaults(obj, component)
            % Apply custom design-time component defaults to the component
            %            
            % Set design time properties for Position/Title/XLabel/YLabel
            component.Position = [0 0 300 185];
            component.Title.String = getString(message('MATLAB:ui:defaults:UIAxesTitle'));
            component.XLabel.String = getString(message('MATLAB:ui:defaults:UIAxesXLabel'));
            component.YLabel.String = getString(message('MATLAB:ui:defaults:UIAxesYLabel'));
        end
        
        function defaultValues = customizeComponentDesignTimeDefaults(obj, defaultValues)
            % InnerPosition is only for UIAxes Limitations banner now, and
            % it's a readonly property on the UIAxes, so it's needed to be
            % added into the defaults here. In the future it could be
            % removed if not Limitations Banner needed.
            defaultValues.InnerPosition = [62 43 210 130];
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.control.UIAxes';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/UIAxesModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            codeSnippet = sprintf('uiaxes(%s)', parentName);
        end
    end
end

