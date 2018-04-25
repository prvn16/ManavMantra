function hasValidBins = hasValidHistogramBins(result)
%% HASVALIDHISTOGRAMBINS function checks if histogram data has valid bins from
% instrumentation data or timeseries data

%   Copyright 2016 The MathWorks, Inc.

    hasValidBins = false;
    
    % Check if result is valid 
    isResultValid = fxptds.isResultValid(result);
    
    if isResultValid
        % Check if result has valid instrumentation bin data
        hasValidInstrumentationBinData = (isprop(result, 'HistogramData') && ...
                                            ~isempty(result.HistogramData) && ...
                                            ~isempty(result.HistogramData.BinData));

        binData = [];
        
        % If instrumentation data has no bins, check timeseries data
        if ~hasValidInstrumentationBinData
            % Get histogram data from timeseries data
            histogramFromTimeseriesData = fxptds.HistogramUtil.getHistogramFromTimeseriesData(result);

            % check if timeseries data has valid bins 
            if ~isempty(histogramFromTimeseriesData) && ~isempty(histogramFromTimeseriesData.BinData)
                binData = histogramFromTimeseriesData.BinData;
            end
        else
            binData = result.HistogramData.BinData;
        end
        
        % If valid bin data found
        if ~isempty(binData)
           hasValidBins = true;
        end
    end
end