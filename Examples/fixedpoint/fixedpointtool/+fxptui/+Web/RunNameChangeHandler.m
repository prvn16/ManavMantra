classdef RunNameChangeHandler < handle
 % RUNNAMECHANGEHANDLER Handles changing the run name from the
 % client and updates the client after the backend is changed
 
 % Copyright 2016-2017 The MathWorks, Inc.
       
   methods      
       % This function updates the run names in all the containing datasets. Once done, the client is updated.
       function processChange(~, clientData)
           fptInstance = fxptui.FixedPointTool.getExistingInstance;
           % Get all the datasets for a given top model.
           allDs = fxptds.getAllDatasetsForModel(fxptui.getTopModelFromFPT);
           % Update the datasets contained in the top model with the new run name.
           for i = 1:numel(allDs)
               % The last flag is to tell the API to udpate the SDI Engine as well.
               allDs{i}.updateForRunNameChange(clientData.oldValue, clientData.newValue);
           end
           if ~isempty(fptInstance)
               % Update the client once the runs have been updated.
               fptInstance.getDataController.updateOnRunChange(clientData);
               fptInstance.getExternalViewer.runRenamed(clientData.oldValue, clientData.newValue)
           end
       end
   end
end
