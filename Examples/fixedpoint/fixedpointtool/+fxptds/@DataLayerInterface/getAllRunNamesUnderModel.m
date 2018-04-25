function runNames = getAllRunNamesUnderModel(this, modelName)
    % GETALLRUNNAMESUNDERMODEL this function returns all run names under a
    % model, including the entire model reference hierarchy. A run name
    % will be returned iff the corresponding run contains results
    
    %   Copyright 2017 The MathWorks, Inc.

    allModels = SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(modelName);
    runNames = {};
    for mIndex = 1:numel(allModels)
        currentRunNames = this.getAllRunNamesUsingModelSource(allModels{mIndex});
        runNames = [runNames currentRunNames]; %#ok<AGROW>
    end
    runNames = unique(runNames);
end