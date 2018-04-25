function mapSDIRunForTs(this, sdiRunID)
%MAPSDIRUNFORTS Maps the runID created in the SDI Engine to store the time-series data.

% Copyright 2012-2016 The MathWorks, Inc.

runName = getCurrentRunName(this);
if this.RunNameTsIDMap.isKey(runName)
    this.RunNameTsIDMap.deleteDataByKey(runName);    
end
this.RunNameTsIDMap.insert(runName, sdiRunID);

runObj = this.getRun(runName);
runObj.setTimeSeriesRunID(sdiRunID);

%------------------------------------------
%[EOF]
