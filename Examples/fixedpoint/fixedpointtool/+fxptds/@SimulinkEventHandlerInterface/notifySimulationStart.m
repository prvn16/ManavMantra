function notifySimulationStart(this, modelObject)
%% NOTIFYSIMULATIONSTART function handles notifying simulation start event to a dataset object
% model is a Simulink Block Diagram object

%   Copyright 2016 The MathWorks, Inc.

    % get full name from the model object 
    model = modelObject.getFullName;
    
    % Query for the dataset that matches the model name 
    fptrepo = fxptds.FPTRepository.getInstance();
    datasetObject = fptrepo.getDatasetForSource(model);
    
    % if dataset object exists, notify Sim Start event
    if ~isempty(datasetObject)
        writeMode = get_param(model, 'MinMaxOverflowArchiveMode');
        datasetObject.initializeOnSimulationStart(writeMode);
        this.LastDatasetAccessed = datasetObject;
    end
end