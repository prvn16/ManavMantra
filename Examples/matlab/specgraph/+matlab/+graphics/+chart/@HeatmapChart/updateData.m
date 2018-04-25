function updateData(hObj)
% Recalculate the data from the table and then update the XData,
% YData, and ColorData with the results.

% Copyright 2016-2017 The MathWorks, Inc.

import matlab.graphics.chart.internal.heatmap.aggregateData

% Check if we are in table mode and the data are dirty.
if hObj.UsingTableForData && hObj.DataDirty
    % Call aggregateData to do the actual aggregation.
    [xData, yData, colorData, counts] = aggregateData(hObj.SourceTable, ...
        hObj.XVariableName, hObj.YVariableName, ...
        hObj.ColorVariableName, hObj.ColorMethod);
    
    % Record the calculated XData/YData/ColorData for use later.
    hObj.CalculatedXData = xData;
    hObj.CalculatedYData = yData;
    hObj.CalculatedColorData = colorData;
    hObj.CalculatedCounts = counts;
    
    % Update the ColorData
    hObj.ColorData_I = colorData;
    
    % Update the XData
    hObj.XData_I = xData;
    
    % Update the YData
    hObj.YData_I = yData;
    
    % Mark the data clean.
    hObj.DataDirty = false;
end

end
