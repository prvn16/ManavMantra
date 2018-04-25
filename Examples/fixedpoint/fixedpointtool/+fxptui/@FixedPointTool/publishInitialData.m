function publishInitialData(this, clientData)
% PUBLISHINITIALDATA Send initial data to the client

% Copyright 2015-2017 The MathWorks, Inc.

    this.TreeController.sendModelHierarchy(clientData);
    addedTree = this.ModelHierarchy.getAddedTreeData;
    this.TreeController.sendAddedTree(addedTree);
    this.StartupController.publishData(clientData);
    this.WorkflowController.publishData;
    this.ResultInfoController.publishData;
    this.DataController.setupVisualizer();
    this.DataController.updateData('allData');
end
