function initializeOnSimulationStart(this, dataWriteMode)
%INITIALIZEONSIMULATIONSTART Perform cleanup on the run at the start of simulation

%   Copyright 2012-2016 The MathWorks, Inc.

    runName = getCurrentRunName(this);
    runObj = this.getRun(runName);
    this.setLastUpdatedRun(runName);
    runObj.cleanupOnSimulation(strcmpi(dataWriteMode,'Merge'));
end

%----------------------------
%[EOF]
