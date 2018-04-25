function createDataset(this, model)
%% CREATEDATASET function creates a dataset given a model name 
% It checks if the model is a valid SimulinkModel and initializes a simulink event listener
% which will listen to simulation start event
    
%   Copyright 2016-2017 The MathWorks, Inc.

   datasetObj  = fxptds.FPTDataset(model);
   this.ModelDatasetMap.insert(model, datasetObj);
end
