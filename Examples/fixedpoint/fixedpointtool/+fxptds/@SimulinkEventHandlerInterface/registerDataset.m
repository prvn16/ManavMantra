function registerDataset(this, datasetObject)
%% REGISTERDATASET function adds model->FPTDataset entry in ModelDatasetMap 
% after validating that model is a valid simulink block diagram
% It also listens to SimulationStart event on the model and notifies
% FPTDataset object of the event

% datasetObject is a fxptds.FPTDataset object instance

%   Copyright 2016-2017 The MathWorks, Inc.

    % get model object 
    modelObj = get_param(Simulink.ID.getModel(datasetObject.getSource),'Object');
    if isa(modelObj,'Simulink.Object')
        % If model object is a simulink object, add a listener on "Sm
        % Start" event of the object
         this.ModelListeners{end+1} = handle.listener(modelObj,'EngineSimulationBegin',@(s,e)notifySimulationStart(this, s));
    end
end
