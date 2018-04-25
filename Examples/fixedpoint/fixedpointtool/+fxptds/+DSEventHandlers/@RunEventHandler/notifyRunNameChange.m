function scopingIdsMap = notifyRunNameChange(~, oldRunName, newRunName, datasetSourceName)
%% NOTIFYRUNNAMECHANGE function handles fxptds.FPTRun's change of run name 

% This is an interface between the Run object changes and ScopingEngine. It
% updates the records in the scoping engine based on run name changes. 
% eventSrc is the runObject on which the event was issued.
% eventData has the information about the changes that happened on the run
% object

%   Copyright 2016 The MathWorks, Inc.

    scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
    % Update the scoping IDs for the run name change
    scopingIdsMap = scopingEngine.updateScopingIdsForRunNameChange(oldRunName, newRunName, datasetSourceName);          

end
 