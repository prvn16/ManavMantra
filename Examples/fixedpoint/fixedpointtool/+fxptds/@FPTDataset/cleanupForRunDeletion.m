function cleanupForRunDeletion(this, runNames)
% CLEANUPFORRUNDELETION Cleans up the internal maps when a run is deleted by the user.

% Copyright 2012-2017 The MathWorks, Inc.

for i = 1:length(runNames)
    run = runNames{i};
    if this.RunNameObjMap.isKey(run)
        this.RunNameObjMap.deleteDataByKey(run);
    end
    if this.RunNameTsIDMap.isKey(run)
        this.RunNameTsIDMap.deleteDataByKey(run);
    end
    
    this.removeEmbeddedRunName(run);
end
