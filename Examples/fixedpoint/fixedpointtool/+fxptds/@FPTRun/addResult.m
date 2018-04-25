function addResult(this, result)
    % ADDRESULT Adds the specified result to the corresponding run in dataset storage
    % This API is called by two clients - fxptds.FPTRun.createAndUpdateResult and 
    % SimulinkFixedPoint.ApplicationData.updateModelBlkResult. 
        
    % UpdateModelBlkResult API copies results from model reference dataset to model block 
    % dataset for the current run of interest. This API copies the result object 
    % (as a handle object). Each run object has a "source" mapping to Dataset Source name 
    % When updating results from model reference dataset to model block's dataset, the current
    % run object needs to be updated (which is done at line 20). Only when the model block
    % source is updated, the copied result's scoping id can be generated correctly by 
    % FPTGUIScopingEngine. Hence, line 30 of calling RunEventHandler is done after setting the 
    % correct run name for the result
        
    % Copyright 2012-2017 The MathWorks, Inc.
  
    % add result in the data storage
    this.DataStorage(result.UniqueIdentifier.UniqueKey) = result;
    
    % add the result in the nodes list of the data type group interface
    this.dataTypeGroupInterface.addNode(result);
    
    % update result properties
    result.setRun(this);
      
    % Once result's run object is updated, add it to ScopingEngine queue
    % if result's scoping id is empty. Adding to the queue should happen
    % after the result's run is updated as the underlying data source can
    % be different and it will affect the scoping id being generated.
    if isempty(result.getScopingId)
        this.RunEventHandler.notifyAddResult(result);
    end
end
