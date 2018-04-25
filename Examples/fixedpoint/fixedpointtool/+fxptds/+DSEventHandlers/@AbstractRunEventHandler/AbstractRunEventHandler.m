classdef AbstractRunEventHandler < handle
%% AbstractRunEventHandler class that handles all fxptds.FPTRun result creation events
    
%   Copyright 2016 The MathWorks, Inc.
   methods(Abstract)
       notifyAddResult(this, result);
       notifyDeleteResult(this, results);
       notifyDeleteAllResults(this, runName, datasetSourceName);
       newScopingIdsMap = notifyRunNameChange(this, oldRunName, newRunName, datasetSourceName);
   end      
end