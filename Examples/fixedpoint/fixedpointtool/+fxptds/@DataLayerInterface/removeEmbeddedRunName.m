function removeEmbeddedRunName(~, modelName, embeddedRunName)
    % REMOVEEMBEDDEDRUNNAME this function removes a run name from the
    % catalog of run names that have been marked as embedded for all
    % datasets under the model
    
    % Copyright 2017 The MathWorks, Inc.
    
    allDatasets = fxptds.getAllDatasetsForModel(modelName);
    
    % Get all the run names in the datasets
    for dIndex = 1:numel(allDatasets)
        allDatasets{dIndex}.removeEmbeddedRunName(embeddedRunName);
    end
end