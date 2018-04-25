function setLastUpdatedRun(models, runName)
    % SETLASTUPDATEDRUN this function sets the last updated run for all
    % models. Models is a cell array of model names, runName is a character
    % that has the run name
    
    % Copyright 2017 The MathWorks, Inc.
    
    for mIndex = 1:numel(models)
        appData = SimulinkFixedPoint.getApplicationData(models{mIndex});
        appData.dataset.setLastUpdatedRun(runName);
    end
    
end