function mcodeConstructor(hObj, code)
% Generate code to recreate the heatmap.

% Copyright 2017 The MathWorks, Inc.

% Call the superclass mcodeConstructor to handle position properties.
mcodeConstructor@matlab.graphics.chart.internal.SubplotPositionableChartWithAxes(hObj, code)

% Use the 'heatmap' command to create HeatmapChart objects.
setConstructorName(code, 'heatmap')

% Remove the table properties from the list of name-value pairs. They will
% be added later if necessary.
ignoreProperty(code, 'SourceTable');
ignoreProperty(code, 'XVariable');
ignoreProperty(code, 'YVariable');
ignoreProperty(code, 'ColorVariable');

% ColorDisplayData is read-only.
ignoreProperty(code, 'ColorDisplayData');

% Check for table vs. matrix workflow.
if strcmp(hObj.ColorDataMode, 'manual')
    % Matrix syntax
    %   heatmap(cdata, Name, Value)
    %   heatmap(xdata, ydata, cdata, Name, Value)
    
    % If both XData and YData are manually specified, add them to the
    % convenience arguments passed into heatmap.
    %   heatmap(xdata, ydata, cdata, Name, Value)
    if strcmp(hObj.XDataMode, 'manual') && strcmp(hObj.YDataMode, 'manual')
        % Add the XData and YData input arguments.
        addArgument(hObj, code, 'XData', 'xdata')
        addArgument(hObj, code, 'YData', 'xdata')
    end
    
    % Add the ColorData input argument.
    addArgument(hObj, code, 'ColorData', 'colordata')
else
    % Table syntax
    %   heatmap(tbl, xvar, yvar, Name, Value)
    
    % Add the SourceTable input argument.
    addArgument(hObj, code, 'SourceTable', 'tbl')
    
    % Add the XVariable and YVariable input arguments.
    addArgument(hObj, code, 'XVariable', 'xvar')
    addArgument(hObj, code, 'YVariable', 'yvar')
    
    % Process the ColorVariable
    if ~isempty(hObj.ColorVariable)
        % ColorVariable is not empty, so add the ColorVariable input
        % argument as a name-value pair. Specify it as a parameter so that
        % it is used as an input argument in the generated code.
        
        % Add ColorVariable property name argument.
        arg = codegen.codeargument('Value', 'ColorVariable', ...
            'ArgumentType', codegen.ArgumentType.PropertyName);
        addConstructorArgin(code, arg);
        
        % Add ColorVariable property value argument.
        arg = codegen.codeargument('Name', 'colorvar', 'Value', hObj.ColorVariable, ...
            'IsParameter', true, 'Comment', 'ColorVariable', ...
            'ArgumentType', codegen.ArgumentType.PropertyValue);
        addConstructorArgin(code, arg);
    end
end

% Ignore any property with the mode set to 'auto'.
propsWithModes = {'Title', 'XLabel', 'YLabel', ...
    'XLimits', 'YLimits', 'ColorLimits', ...
    'XData', 'YData', 'ColorData', 'ColorMethod', ...
    'XDisplayData', 'YDisplayData'};
for p = 1:numel(propsWithModes)
    % Build the property name and mode property name.
    propName = propsWithModes{p};
    modePropName = [propName 'Mode'];
    
    % Check if the mode is auto.
    if strcmp(hObj.(modePropName), 'auto')
        % Ignore the property.
        ignoreProperty(code, propName);
    end
end

% Make sure XDisplayData is added to the list of name-value pairs ahead of
% both XDisplayLabels or XLimits.
movePropertyBefore(code, 'XDisplayData', {'XDisplayLabels','XLimits'});

% Make sure YDisplayData is added to the list of name-value pairs ahead of
% both YDisplayData or YLimits.
movePropertyBefore(code, 'YDisplayData', {'YDisplayLabels','YLimits'});

% Remove the XDisplayLabels if they have not been customized.
if isequal(hObj.XDisplayData, hObj.XDisplayLabels)
    ignoreProperty(code, 'XDisplayLabels');
end

% Remove the YDisplayLabels if they have not been customized.
if isequal(hObj.YDisplayData, hObj.YDisplayLabels)
    ignoreProperty(code, 'YDisplayLabels');
end

% Add the remaining name-value pair arguments.
generateDefaultPropValueSyntax(code);

end

function addArgument(hObj, code, prop, name)
% Add a convenience argument.

% Add the input argument.
arg = codegen.codeargument('Name', name, 'Value', hObj.(prop), ...
    'IsParameter', true, 'Comment', prop);
addConstructorArgin(code, arg);

% Ignore the property so it is not added twice.
ignoreProperty(code, prop);

end
