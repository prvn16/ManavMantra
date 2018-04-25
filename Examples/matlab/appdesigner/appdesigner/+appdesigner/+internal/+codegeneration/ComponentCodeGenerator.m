classdef ComponentCodeGenerator
    %COMPONENTCODEGENERATOR - This class has all knowledge to use the
    %adapters to assemble code for a component.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Access = 'private', Transient)
        
        % Map of component specific data.  The key is the component type
        % and the value is a struct with three fields
        %   ComponentDefaults - a struct containing default values for each
        %   field of the component
        %   PropertyList - a 1xn cell array of property names for the
        %   component in the order they should appear in the generated code
        %   IsModeSibling - a 1xn logical array containing true if the
        %   Component has a proeprty corresponding to the 
        %   [propertyName 'Mode'] string
        ComponentData = containers.Map();
    end
    
    methods
        function obj = ComponentCodeGenerator()
        end
        
        function generatedCode = getComponentGenerationCode(obj, model, adapter)
            % GETCOMPONENTCODE - This class uses the current state of the
            % model and the adapter to generate a cell array of strings
            % representing the code to generate that component.
            % Example generated code
            %      {'app.ad_CODENAME_ad = uilabel(app.ad_PARENTCODENAME);'}
            %      {'app.ad_CODENAME_ad.Location = [100 20]'}
            
            % Get Code replacement map.
            replaceMap = appdesigner.internal.codegeneration.ComponentCodeGenerator.getCodeReplaceMap();
            componentType = adapter.getComponentType();
            if obj.ComponentData.isKey(componentType)
                
                % Get per component data from the map
                componentData = obj.ComponentData(componentType);
                componentDefaults = componentData.ComponentDefaults;
                propertyList = componentData.PropertyList;
                isPropertyModeSibling = componentData.IsModeSibling;
                
            else
                % Calculate the per component data once, then store it in
                % the ComponentData map
                componentDefaults = adapter.getComponentRunTimeDefaults();
                
                % Property List in the order it should appear in the code
                propertyList = adapter.getCodeGenPropertyNames(model);
                
                % Status of whether the property has a corresponding Mode
                % sibling
                isPropertyModeSibling = adapter.isModeSibling(propertyList, model);
                
                % Store three pieces of component specific information in a
                % struct, then add entry to ComponentData map.
                componentData = struct();
                componentData.ComponentDefaults = componentDefaults;
                componentData.PropertyList = propertyList;
                componentData.IsModeSibling = isPropertyModeSibling;
                
                obj.ComponentData(componentType) = componentData;
            end
            
            % Generate component code using the adapter methods as helpers.
            % componentStr will be something like:
            %    'app.ad_CODENAME_ad = uilabel(app.ad_PARENTCODENAME);'
            componentStr = obj.generateComponentConstructor(...
                model,...
                adapter,...
                replaceMap('CodeName'),...
                replaceMap('ParentCodeName'));
            
            % Generate component code to set the properties on the model
            % propertiesStr will be a cell array, one string per property
            % set, for example:
            %       {'app.ad_CODENAME_ad.Location = [200 200]'}
            %       {'app.ad_CODENAME_ad.Size = [100 20]'}
            propertiesStr = obj.generateComponentProperties(...
                model, ...
                adapter,...
                replaceMap('CodeName'), ...
				replaceMap('ParentCodeName'), ...
                propertyList, ...
                isPropertyModeSibling,...
                componentDefaults);
            
            generatedCode =  [{componentStr}; propertiesStr];
            
        end
    end
    
    methods (Static)
        
        function replaceMap = getCodeReplaceMap()
            % Here is a class that stores the replacement strings code
            % generation will use when components generate code.  The
            % strings will be replaced in a code model object on the client
            % and the code item will update the view if one of these
            % properites changes.
            
            keyValuePairs = {'CodeName', 'ad_CODENAME_ad';...
                'ParentCodeName', 'ad_PARENTCODENAME_ad'};
            
            % Create Map for the replacements.  All entries
            % should be string, so set uniformValues to true
            replaceMap = containers.Map(keyValuePairs(:, 1), keyValuePairs(:, 2), ...
                'uniformValues', true);
            
        end
    end
    
    % The following block contains functions specific to generating code
    %  using the MATLAB component adapters
    methods(Access = private)
        function entireLine = generateComponentConstructor(obj, model, adapter, codeName, parentCodeName)
            % Generates a single line to create the component
            %
            % Ex: app.CircularGauge = uigauge(app.UIFigure, 'circular');
            
            % Ex: app.UIFigure
            parentVariableName = sprintf('app.%s', parentCodeName);
            
            % The right hand side for the component creation
            %
            % Ex: uigauge(UIFigure, 'circular')
            componentCreationSnippet = adapter.getCodeGenCreation( ...
                model, codeName, parentVariableName);
            
            % Create the entire line
            %
            % (indent) app.CircularGauge = (component creation snippet)
            entireLine = sprintf('app.%s = %s;', ...
                codeName, ...
                componentCreationSnippet);
        end
        
        function propertyStr = generateComponentProperties(obj, model, adapter,...            
                codeName, parentCodeName, propertyList, isPropertyModeSibling, defaultComponent)
            
            % The propertyList order should be honored and assumed to be
            % correct.
            %
            % In general we will not generate code if the property value is
            % the same as the default.
            % If the propertyName has a 'Mode' sibling, and the 'Mode'
            % sibling is manual, we should always generate the code for
            % that propertyName.
            
            
            propertyStr = [];
            for index = 1:numel(propertyList)
                propertyName = propertyList{index};
                
                showPropertyCode = adapter.shouldShowPropertySetCode(...
                    isPropertyModeSibling(index), ...
                    model,...
                    propertyName, ...
                    defaultComponent);
                
                if showPropertyCode
                    % Ask adapter how to generate the line of code that
                    % sets this specific value
                    try
                        propertySegment = adapter.getCodeGenPropertySet(model, propertyName, codeName, parentCodeName);

                        % Format the propertySegment to include leading white
                        % space the equivalent of three tabs, add a newline to
                        % the end of the property segment
                        propertyStr = [propertyStr; {propertySegment}];
                    catch e
                    end
                end
            end
            
        end
    end
    
    methods ( Static, Access = {?appdesigner.internal.componentadapterapi.VisualComponentAdapter} )
        
        function valueStr = propertyValueToString(className, value)
            % This function returns a string representing the values to be
            % modified for the component.  The string returned would be:
            % '[105 399]'
            % in order to modify the Location property of app.Pushbutton1:
            % app.PushButton1.Location = [105 399];
            valueStr = '';
            switch(class(value))
                
                case {'logical', 'double'}
                    valueStr = mat2str(value);
                    
                case {'string'}
                     valueStr = sprintf('"%s"', value);
                    
                case {'char'}
                    valueStr = sprintf('''%s''', ...
                        appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(value));
                    
                case {'cell'}
                    % case of empty cell
                    if numel(value) == 0
                        valueStr = '{}';
                        % case of 1x1 cell
                    elseif numel(value) == 1
                        % Values in cell can be string or double
                        % 'States' property can be a double
                        
                        if ischar(value{1})
                            % 1x1 cells containing characters
                            newValue = appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(value{1});
                            valueStr = sprintf('{''%s''}', newValue);
                        elseif (isnumeric(value{1})...
                                || islogical(value{1}))...
                                && numel(value{1}) == 1
                            valueStr = sprintf('{%f}', value{1});
                        end
                        % case of nx1 or 1xn cell array
                    elseif numel(value) == length(value)
                        % case of nx1 cell array
                        
                        if ischar(value{1})
                            newValue = appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(value{1});
                            valueStr = sprintf('{''%s''', newValue);
                        elseif (isnumeric(value{1})...
                                && numel(value{1}) == 1)
                            valueStr = sprintf('{%g', value{1});
                            
                        elseif (islogical(value{1}) && numel(value{1}) == 1)
                            if value{1}
                                valueStr = '{true';
                            else
                                valueStr = '{false';
                            end
                        else
                            assert(false, ...
                                sprintf(...
                                'Unexpected data type found for %s',...
                                className))
                        end
                        
                        % case of 1xn cell array
                        if size(value, 2) == length(value)
                            separator = ',';
                        else
                            separator = ';';
                        end
                        % On a rare occasion, a 1xn cell array may be of
                        % mixed type which is why each value should be
                        % handled separately.
                        for entry = ...
                                reshape(value(2:end), ...
                                1, numel(value(2:end)))
                            if ischar(entry{1})
                                valueStr = ...
                                    sprintf('%s%s ''%s''', ...
                                    valueStr, separator,...
                                    appdesigner.internal.codegeneration.ComponentCodeGenerator.escapeQuote(entry{1}));
                            elseif (isnumeric(entry{1})...
                                    && numel(entry{1}) == 1)
                                valueStr = ...
                                    [valueStr, sprintf('%s %g', ...
                                    separator, entry{1})]; %#ok<AGROW>
                            elseif (islogical(entry{1}) && numel(entry{1}) == 1)
                                if entry{1}
                                    valueStr = ...
                                        [valueStr, sprintf('%s %s', ...
                                        separator, 'true')]; %#ok<AGROW>
                                else
                                    valueStr = ...
                                        [valueStr, sprintf('%s %s', ...
                                        separator, 'false')]; %#ok<AGROW>
                                end
                            else
                                assert(false, ...
                                    sprintf(...
                                    'Unexpected data type found for %s',...
                                    className))
                            end
                        end
                        valueStr = [valueStr, '}'];
                    end   
                   
                otherwise
                    % This will catch future component properties that are
                    % not currently implemented by may be in the future
                    % TODO, deal with LABELS
                    
                    assert(false, ...
                        ['This compare class has '...
                        'not been implemented: %s'],...
                        class(value));
                    
            end
            
            
        end
        
        function str = escapeQuote(str)
                % sprintf will format '' to be ', so this doubles the
                % single quotes so they are preserved through sprintf                
                str = regexprep(str, '''', '''''');
        end
            
        function str = generateStringForPropertySegment(codeName, ...
                thisProperty, value)
            % Example text to add the Location property to HmiFigure1:
            % app.HmiFigure1.Location = [50 50];
            
            % This is the value in the form of a char where feval(valueStr)
            % would help produce a value that is equivalent to the original
            valueStr = appdesigner.internal.codegeneration.ComponentCodeGenerator.propertyValueToString(codeName, value);
            str = sprintf('app.%s.%s = %s;', ...
                codeName, thisProperty, valueStr);
        end
        
    end
end

