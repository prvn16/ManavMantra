function notifyDeleteAllResults(~, runName, datasetSourceName)
%% NOTIFYDELETEALLRESULTS function notifies FPTGUIScopingEngine to delete
% all results in a run.

%   Copyright 2016 The MathWorks, Inc.
   
   scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
   scopingEngine.deleteAllResults(runName, datasetSourceName);
   
end