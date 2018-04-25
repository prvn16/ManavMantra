function histogramVisualizationInfo = getHistogramVisualizationInfo(result)
%% GETHISTOGRAMVISUALIZATIONINFO function creates visualization information for every fxptds.AbstractResult
% using histogram bin data, range data and container information

%   Copyright 2017 The MathWorks, Inc.

    % Create range data from result
    rangeData = fxptds.Utils.getRanges(result);
    
    % Create container information from result 
    containerInfo = fxptds.Utils.getContainerType(result);
    
    % Create histogram data from result
    if isempty(result.HistogramData) || isempty(result.HistogramData.BinData)
        histogramData = fxptds.HistogramUtil.getHistogramFromTimeseriesData(result);
    else
        histogramData = result.HistogramData;
    end
    
    % Construct histogram visualization informtion from range, container
    % info and histogram data.
    histogramVisualizationInfo = DataTypeWorkflow.Visualizer.HistogramVisualizationInterface(rangeData.Sim, histogramData);
    hasActualOverflows = ~isempty(result.OverflowWrap) || ~isempty(result.OverflowSaturation) || ~isempty(result.DivideByZero);
    if hasActualOverflows
        histogramVisualizationInfo.HasOverflows = 1;
    end
    histogramVisualizationInfo.addContainerInfo(containerInfo);
end