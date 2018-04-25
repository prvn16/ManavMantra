function clearResultsInRuns(this)
% CLEARRESULTS clear the results from the specified runs.

%   Copyright 2012-2017 The MathWorks, Inc.
    numberOfRuns = this.RunNameObjMap.getCount;
    runNames = cell(numberOfRuns, 1);
    for idx = 1:numberOfRuns
        runName = this.RunNameObjMap.getKeyByIndex(idx);
        runNames{idx} = runName;
        runObj = this.RunNameObjMap.getDataByKey(runName);
        if runObj.isvalid
          runObj.clearResults;
        end
    end
    this.cleanupForRunDeletion(runNames);
end



