function notifyAddResult(~, result)
%% NOTIFYADDRESULT function notifies FPTGUIScopingEngine on a fxptds.FPTRun's 
% result creation event.
% It gets fxptds.AbstractResult and adds the result's
% resultId, runName, subsystemId and datasetSourceName in
% fxptds.FPTRepository's ScopingTable.

%   Copyright 2016 The MathWorks, Inc.

    scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
    scopingEngine.addResultToChangeset(result);

end
