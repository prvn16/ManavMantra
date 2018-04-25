function updateLabels(hObj)
% Update the automatically generated Title, XLabel, and YLabel on the
% Heatmap.

% Copyright 2016 The MathWorks, Inc.

% Get the table variable names.
xName = hObj.XVariableName;
yName = hObj.YVariableName;
cName = hObj.ColorVariableName;

% Update the Title.
if strcmp(hObj.TitleMode,'auto')
    switch hObj.ColorMethod
        case 'none'
            if ~isempty(cName)
                hObj.Title_I = cName;
            end
        case 'count'
            if ~isempty(xName) && ~isempty(yName)
                m = message('MATLAB:graphics:heatmap:CountTitle', yName, xName);
                hObj.Title_I = m.getString;
            end
        case 'mean'
            if ~isempty(cName)
                m = message('MATLAB:graphics:heatmap:MeanTitle', cName);
                hObj.Title_I = m.getString;
            end
        case 'median'
            if ~isempty(cName)
                m = message('MATLAB:graphics:heatmap:MedianTitle', cName);
                hObj.Title_I = m.getString;
            end
        case 'min'
            if ~isempty(cName)
                m = message('MATLAB:graphics:heatmap:MinTitle', cName);
                hObj.Title_I = m.getString;
            end
        case 'max'
            if ~isempty(cName)
                m = message('MATLAB:graphics:heatmap:MaxTitle', cName);
                hObj.Title_I = m.getString;
            end
        case 'sum'
            if ~isempty(cName)
                m = message('MATLAB:graphics:heatmap:SumTitle', cName);
                hObj.Title_I = m.getString;
            end
    end
end

% Update the XLabel
if strcmp(hObj.XLabelMode,'auto')
    if ~isempty(xName)
        hObj.XLabel_I = xName;
    end
end

% Update the YLabel
if strcmp(hObj.YLabelMode,'auto')
    if ~isempty(yName)
        hObj.YLabel_I = yName;
    end
end
end
