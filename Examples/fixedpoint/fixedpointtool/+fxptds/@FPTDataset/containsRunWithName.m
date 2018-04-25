function containsRun = containsRunWithName(this, runName)
% CONTAINSRUNWITHNAME returns true if the dataset contains a run with name specified by runName.

% Copyright 2012 MathWorks, Inc.

containsRun = false;
for i = 1:this.RunNameObjMap.getCount
    if strcmp(this.RunNameObjMap.getKeyByIndex(i), runName)
        containsRun = true;
        return;
    end
end
