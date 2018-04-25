% Import export functionality related function
 function restoreFailedResults = restoreRun(this, savedRunName, savedResults)
 %% RESTORERUN function restores run based on the input run name and saved results

%   Copyright 2016 The MathWorks, Inc.

     runObj = this.getRun(savedRunName); % create a run and return the run object

     restoreFailedResults = runObj.restoreResults(savedResults);
 end 
