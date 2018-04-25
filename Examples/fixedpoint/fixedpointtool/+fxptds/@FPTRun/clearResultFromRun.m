function clearResultFromRun(this, result)
    % CLEARRESULTFROMRUN Delete the result from the run.
    % Remove the result from the map.
    % Use the cached value of the owner since getting it from the data object
    % could return an invalid handle.
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    % remove the result to be deleted from the group interface first
    this.dataTypeGroupInterface.deleteResultFromGroup(result);
    
    % get the unique key for the result
    uniqueID = result.getUniqueIdentifier.UniqueKey;
    
    % delete the result from the data set as well
    if isvalid(result) && this.DataStorage.isKey(uniqueID)
        % Delete all references to a given result in FPTGUIScopingEngine
        this.RunEventHandler.notifyDeleteResult(result);
        
        % Delete result in the given run from the data storage
        this.DataStorage.remove(uniqueID);
        
        % delete the object
        delete(result);
    end
end