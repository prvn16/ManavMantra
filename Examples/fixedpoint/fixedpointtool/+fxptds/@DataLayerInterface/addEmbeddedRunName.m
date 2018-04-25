function addEmbeddedRunName(~, modelName, embeddedRunName)
    % ADDEMBEDDEDRUNNAME this function marks a run name as embedded on all
    % the data sets that correspond to the model
    
    % Copyright 2017 The MathWorks, Inc.
    
    allDatasets = fxptds.getAllDatasetsForModel(modelName);
    
    % Get all the run names in the datasets
    for dIndex = 1:numel(allDatasets)
        allDatasets{dIndex}.addEmbeddedRunName(embeddedRunName);
    end
end