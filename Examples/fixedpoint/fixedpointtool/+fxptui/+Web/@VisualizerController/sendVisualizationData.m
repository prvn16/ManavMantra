function sendVisualizationData(this, runName, results, resultRenderingOrder)
%% SENDVISUALIZATIONDATA function collects visualization data from a given run name's
% results in the given result rendering order and publishes data to JS
% Client

%   Copyright 2016-2017 The MathWorks, Inc.
     % Query and Package data matching results for a given run name 
    this.packageData(runName, results, resultRenderingOrder);
    
    this.publishData(true);
end