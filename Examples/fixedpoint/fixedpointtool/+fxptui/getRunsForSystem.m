function runNames = getRunsForSystem(system)
% GETRUNSFORSYSTEM Returns the run names for a given system

% Copyright 2017 The MathWorks, Inc.

    runNames = {};
    
    dataLayer = fxptds.DataLayerInterface.getInstance();  
    
    % Query all datasets
    datasetArray = fxptds.getAllDatasetsForModel(system);
    
    for i = 1:numel(datasetArray)
        % Query run names for a given dataset 
        allRuns = dataLayer.getAllRunNamesWithResults(datasetArray{i});
        for kk = 1:numel(allRuns)
            runNames = [runNames, allRuns(kk)];  %#ok<AGROW
        end
    end
end