function cleanUpAllDatasets(h, runName, visibleModels)
%GETDATASET Get the dataset.

%   Copyright 2007-2012 The MathWorks, Inc.

allDS = h.getAllDatasets;
for idx = 1:length(allDS)
    ds = allDS{idx};
    curModelName = ds.rootmdl.getFullName;
    isModelNonNormalModeVisibility = isempty(visibleModels) || ~ismember(curModelName, visibleModels);
    
    if ~isequal(h.getTopNode.getDAObject, ds.rootmdl) && isModelNonNormalModeVisibility
        ds.clearNonSigResults(runName);
    else
        ds.cleanuprun(runName);
    end    
end

% [EOF]
