function deleteControllers(this)
    % DELETECONTROLLERS Deletes the controllers that communicate with the
    % client
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    delete(this.TreeController);
    delete(this.DataController);
    delete(this.StartupController);
    delete(this.WorkflowController);
    delete(this.ResultInfoController);
    this.TreeController = [];
    this.DataController = [];
    this.ResultInfoController = [];
    this.StartupController = [];
    this.WorkflowController = [];
    this.isReadyPostCallback = false;
end
