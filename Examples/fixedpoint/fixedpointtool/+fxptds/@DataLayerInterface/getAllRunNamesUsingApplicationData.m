function allRunNames = getAllRunNamesUsingApplicationData(this, applicationData)
%% GETALLRUNNAMESUSINGAPPLICATIONDATA function accesses dataset via ApplicationData and returns 
% all runnames which have non-zero number of results 

%   Copyright 2017 The MathWorks, Inc.

    % Access all run names for ApplicationData's dataset mapped for the
    % model source
    allRunNames = this.getAllRunNamesWithResults(applicationData.dataset);

    % Access all run names for all the sub-model datasets in the model
    % reference hierarchy
    subDatasets = applicationData.subDatasetMap.values;
    for i=1:length(subDatasets)
        runNamesForCurDataset = this.getAllRunNamesWithResults(subDatasets{i});
        allRunNames = [allRunNames(:) ; runNamesForCurDataset(:)];
    end
    allRunNames = unique(allRunNames(~cellfun(@isempty,allRunNames)));
end