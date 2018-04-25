function createRun(this, runName)
    % CREATERUN Creates a run to hold results.
    
    %     Copyright 2012-2016 The MathWorks, Inc.
    
    this.runID = this.runID + 1;
    runObj = fxptds.FPTRun(runName, this.runID);
    runObj.setSource(this.Source);
    this.RunNameObjMap.insert(runName, runObj);
end

