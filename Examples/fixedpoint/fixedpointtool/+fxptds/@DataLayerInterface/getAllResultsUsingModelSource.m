function results = getAllResultsUsingModelSource(~, modelName)

%   Copyright 2017 The MathWorks, Inc.

    results = [];
    allDatasets = fxptds.getAllDatasetsForModel(modelName);
    for cnt = 1 : numel(allDatasets)
      dataset = allDatasets{cnt};                 
      curResults = dataset.getResultsFromRuns;
      results = [results curResults]; %#ok<*AGROW>
    end
end