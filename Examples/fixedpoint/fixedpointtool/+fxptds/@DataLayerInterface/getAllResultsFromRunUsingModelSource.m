function results = getAllResultsFromRunUsingModelSource(~, modelName, runName)
%% GETALLRESULTSFROMRUNUSINGMODELSOURCE function returns results from a given run name 
% from the dataset mapped for the given modelName 

%   Copyright 2017 The MathWorks, Inc.

    results = [];
    % Access all datasets mapping to a given model name 
    allDatasets = fxptds.getAllDatasetsForModel(modelName);
    for cnt = 1 : numel(allDatasets)
      dataset = allDatasets{cnt};                 
      dsRun = dataset.getRun(runName);
      % Remove invalid results first
      dsRun.deleteInvalidResults();
      % For each dataset, access run object and get results
      curResults = dsRun.getResults;
      results = [results curResults]; %#ok<*AGROW>
    end
end