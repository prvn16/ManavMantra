function highlightChartWithStateflowData(sfData)
    % Highlights the chart containing the stateflow data
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    % sfData is a Stateflow.Data
    parent = sfData.getParent;
    if fxptds.isStateflowChartObject(parent)
        parentChart = sf('DataChartParent', sfData.Id);
        chartH = sf('Private', 'chart2block', parentChart);
        hilite_system(chartH);
    end
end