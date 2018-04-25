function hasAction = hasExecutedAction(~, modelName, runName, action)
   % HASEXECUTEDACTION this function probes the top model's run object for 
   % for the action of interest
   
   % Copyright 2017 The MathWorks, Inc.
   
   % get the application data of the model
   appData = SimulinkFixedPoint.getApplicationData(modelName);
   
   % get the run object of the model using the run name
   runObj = appData.dataset.getRun(runName);
   
   % check if the run object has executed thea action of interest
   hasAction = runObj.actionExists(action);
end