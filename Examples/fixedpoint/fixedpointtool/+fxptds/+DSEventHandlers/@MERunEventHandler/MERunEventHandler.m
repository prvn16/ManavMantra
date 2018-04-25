classdef MERunEventHandler < fxptds.DSEventHandlers.AbstractRunEventHandler
%% MERunEventHandler class that handles all fxptds.FPTRun result creation events for FPT ME client
% All methods have empty implementations as these event handlers are used
% for working with FPTGUIScopingEngine which exists only for JS clients 
    
%   Copyright 2016 The MathWorks, Inc.
    methods
       function notifyAddResult(this, result) %#ok 
       end
       function notifyDeleteResult(this, results) %#ok
       end
       function notifyDeleteAllResults(this, runName, datasetSourceName) %#ok
       end
       function newScopingIdsMap = notifyRunNameChange(this, oldRunName, newRunName, datasetSourceName) %#ok
           newScopingIdsMap = [];
       end
    end
end