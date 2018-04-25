function runObj = getRun(this, runName)
% GETRUN  Returns the internal run object associated with the runID.

%      Copyright 2012  MathWorks, Inc.

if this.RunNameObjMap.isKey(runName)
    runObj = this.RunNameObjMap.getDataByKey(runName);
else
    createRun(this, runName);
    runObj = this.RunNameObjMap.getDataByKey(runName);
end

    


