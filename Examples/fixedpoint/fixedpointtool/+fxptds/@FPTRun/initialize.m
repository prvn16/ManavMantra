function initialize(this, modelOrSubsystemName)
	% This function performs a lazy initialization of the 
	% run object. 
	% Copyright 2016 The MathWorks, Inc.
    this.deleteInvalidResults();
    % get the meta-data object from the run object
    metaData = this.getMetaData();
    
    % if this is the first time we process this model, initialize the
    % meta-data, else clear the meta-data from previous runs
    if isempty(metaData)
        metaData = fxptds.AutoscalerMetaData;
        this.setMetaData(metaData);
    else
        metaData.clear();
        
        % clear the registered data type groups interface
        this.dataTypeGroupInterface = fxptds.DataTypeGroupInterface();
        
        % get all the results of the run object
        allResults = this.getResults();
        
        % register all the pre-recorded results in the data type group
        % interface as nodes
        % NOTE: as the data typing services will go on, these results will
        % not be rediscovered again and hence these will not get recorded
        % as nodes in the second pass. We need to register them again at
        % initialization phase
        % NOTE2: as we clear the meta-data, we delete the bus object handle
        % map and hence bus element results will get invalid. Later on, we
        % we will recreate these results and hence the interface should not 
        % keep a copy of the invalid results
        % see: g1495502
        for resultIndex = 1:length(allResults)
            if allResults(resultIndex).isResultValid
                this.dataTypeGroupInterface.addNode(allResults(resultIndex));
            end
        end
        
        
        
    end
    
    % initialize the data structure for buses for this model
    metaData.setBusObjectHandleMap(...
        SimulinkFixedPoint.AutoscalerUtils.createBusObjectHandleMap(modelOrSubsystemName));
end