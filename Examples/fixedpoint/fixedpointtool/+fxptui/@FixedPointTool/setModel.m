function setModel(this, modelName)
% SETMODEL Connects the FPT instance with a model.

% Copyright 2015-2017 The MathWorks, Inc.

    this.Model = modelName;
    this.ModelObject = get_param(modelName,'Object');
    bdObj = get_param(modelName, 'Object');
    delete(this.CloseModelListener);
    this.CloseModelListener = handle.listener(bdObj, 'CloseEvent', @(s,e)onModelClose(this));
    delete(this.SimStartListener);
    this.SimStartListener = handle.listener(bdObj, 'EngineSimulationBegin',  @(s,e)recordSignals(this));
    delete(this.SimFailedListener);
    this.SimFailedListener = handle.listener(bdObj, 'EngineCompFailed',  @(s,e)handleCompFailure(this));
    delete(this.SimStopListener);
    this.SimStopListener = handle.listener(bdObj, 'EngineSimulationEnd',  @(s,e)reEnableUI(this,''));
    if ~isempty(this.TreeController)
        this.TreeController.setModel(modelName);
        this.DataController.setModel(modelName);
        this.StartupController.setModel(modelName);
        this.WorkflowController.setModel(modelName);
    end
end
