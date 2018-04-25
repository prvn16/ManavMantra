function histogramData = getHistogramData(result)
%% GETHISTOGRAMDATA function returns histogram information from the result

%   Copyright 2016 The MathWorks, Inc.

    histogramData = result.HistogramData;
    if isempty(histogramData) || isempty(histogramData.BinData)
         % If result does not have histogramData, check if
         % result has timeseries data
         histogramData = fxptds.HistogramUtil.getHistogramFromTimeseriesData(result);
    end
end