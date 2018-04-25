function results = getResultsFromRun(this, runName)
%% GETRESULTSFROMRUN function returns results from a given run

%   Copyright 2016 The MathWorks, Inc.

    runObj = this.getRun(runName);
    results = runObj.getResults;
end