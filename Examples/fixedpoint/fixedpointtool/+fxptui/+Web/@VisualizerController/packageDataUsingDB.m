function packageDataUsingDB(this, doPackageMetaDataFlag)
%% PACKAGEDATAUSINGDB interfaces with VisualizerEngine to compute metadata and data fields for publishing to 
% FPT GUI 
    % Compute RGB data

%   Copyright 2017 The MathWorks, Inc.

    this.VisualizerEngine.generateRGBUsingDB();

    if(doPackageMetaDataFlag)
        % Compute metadata
        this.computeMetaData();
    end
        
    % Compute Data - soon to be moved to packageData()
    startIndex = this.VisualizerEngine.StartIndex;
    endIndex = this.VisualizerEngine.EndIndex;
    this.VisualizerEngine.LastIndex  = endIndex;
    histogramData = this.VisualizerEngine.RGBData(startIndex:endIndex);

    % 1. Update DBManager with RGB
    % 2. Update Filter RGB
    for idx=1:numel(histogramData)
        histogramData{idx} =  flipud(histogramData{idx}');
    end
    % VisualizerEngine.GlobalYLimits = ylimits of RGB data [2x256] arrays where 
    % RGB[2, 1] = first bin's (-128) data
    % RGB[2, 256] = 256ths bins (127) data

    % VisuslizerEngine.VisualYLimits = limits flipped up down
    this.Data = struct('Data', {histogramData}, ...
                        'IsInScope', this.VisualizerEngine.InScopeData, ...
                        'YLimits', this.VisualizerEngine.VisualYLimits, ...
                        'LimitsForYAxisScale', this.VisualizerEngine.GlobalYLimits, ...
                        'CanvasPosition', this.VisualizerEngine.StartIndex);
end