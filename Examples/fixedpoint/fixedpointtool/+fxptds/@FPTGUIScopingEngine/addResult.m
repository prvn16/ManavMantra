function addResult(this, result, runObject)
%% ADDRESULT function adds details of resultId, runName, subsystemId and datasetSourceName 
% Function takes in result and runobject for which a result is created and
% adds a scopingTableRecord to FPTRepository's ScopingTable.
%
% result is an instance of fxptds.AbstractResult
% runObject is an instance of fxptds.FPTRun

%   Copyright 2016 The MathWorks, Inc.

    % get associated scoping table record from input result and runobject 
    scopingTableObj = fxptds.FPTGUIScopingAdapter.getScopingTableRecord(result, runObject);
    
    % Query if the record is present in the table.
    queryResults = this.getRowsForCriteria(scopingTableObj);
    
    if isempty(queryResults)
        % add the scoping table record as a row to the member ScopingTable
        this.addScopingTableRow(scopingTableObj);
        
        % add ID property in result
        result.addScopingId(scopingTableObj.ID);
    end
end