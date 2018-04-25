function notifyDeleteResult(~, results)
%% NOTIFYDELETERESULT function notifies FPTGUIScopingEngine of a delete result event in FPTRun
% 
% It gets a cell array of results that need to be deleted
% from ScopigngTable of fxptds.GUIScopingEngine

%   Copyright 2016 The MathWorks, Inc.

   scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
   scopingEngine.deleteResult(results);
end