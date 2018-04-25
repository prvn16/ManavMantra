function deleteAllResults(this, runName, datasetSourceName)
%% DELETEALLRESULTS function deletes all results that map to the given run name and dataset name from the ScopingTable
%
% runName is char
% runObject is the associated run object in which all results should be deleted

%   Copyright 2016 The MathWorks, Inc.

     % Initialize scoping record object and set run name
      scopingRecordObj = fxptds.FPTGUIScopingTableRecord;
      scopingRecordObj.RunName = {runName};
      
      % query for runobject source name and set scoping record
      % object field
      scopingRecordObj.DatasetSourceName = {datasetSourceName};
      
      % use the scoping record to delete results with a criteria
      this.deleteRowsForCriteria(scopingRecordObj);
end