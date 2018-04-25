 function setTimeSeriesRunID(this, tsID)
 %% SETTIMESERIESRUNID function sets timeseries id received from SDI as SDIRunID in the current run object
 
 % Copyright 2016 The MathWorks, Inc.
    sdiEngine = Simulink.sdi.Instance.engine();
    if sdiEngine.isValidRunID(tsID)
        this.SDITsRunID = tsID;
    end
end