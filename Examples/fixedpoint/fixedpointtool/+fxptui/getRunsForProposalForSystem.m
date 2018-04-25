function runNames = getRunsForProposalForSystem(system)
% GETRUNSFORPROPOSALFORSYSTEM Returns the runs containing range information
% for proposing data types for a selected system in the model.
    
% Copyright 2016-2017 The MathWorks, Inc.

dataLayer = fxptds.DataLayerInterface.getInstance();
runNames = {};
datasetArray = fxptds.getAllDatasetsForModel(system);
% Get all the run names in the datasets
for i = 1:numel(datasetArray)   
    runNamesFromDataset = dataLayer.getAllRunNamesForProposal(datasetArray{i});
    runNames = [runNames, runNamesFromDataset];  %#ok<AGROW
end

% Unique on empty cell array of runNames returns a 0x1 cell array which
% causes test failures. 
if ~isempty(runNames)
    % Filter out empty runNames from the output list of runNames
    % Remove Duplicate run names across model names
    runNames = unique(runNames);
    runNames = sort(runNames);
    idx = ~cellfun('isempty',runNames);
    if any(idx)
        runNames = runNames(idx);
    else
        runNames = {};
    end
end
