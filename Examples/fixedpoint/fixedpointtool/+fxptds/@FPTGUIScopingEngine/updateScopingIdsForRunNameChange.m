function scopingIdsMap = updateScopingIdsForRunNameChange(this, oldRunName, newRunName, datasetSourceName)
%% UPDATESCOPINGIDSFORRUNNAMECHANGE Function updates the scopingIds in the table based on the run name change
%
% Copyright 2016 The MathWorks, Inc.

    % Construct the table record search query
    subsysCriteriaRecord = fxptds.FPTGUIScopingTableRecord;
    subsysCriteriaRecord.DatasetSourceName = {datasetSourceName};
    subsysCriteriaRecord.RunName = {oldRunName};
    
    % Get all the table rows for a given run name and dataset source.
    rowIds = this.getRowIdsForCriteria(subsysCriteriaRecord);
    
    scopingIdsMap = containers.Map(char('a'), char('a'));
    scopingIdsMap.remove('a');
    % For every row that matched the criteria, update the RunName and ID fields
    % to replace the old run name with the new run name. 
    for i = 1:numel(rowIds)
        oldResultID = this.ScopingTable.ID(rowIds(i));
        newResultID = this.getNewIDWithUpdatedRunNameForRow(rowIds(i), oldRunName, newRunName);   
        
        scopingIdsMap(oldResultID{1}) = newResultID{1};
        
        % Update the ID & RunName column values to reflect the new run name.
        this.updateRows(rowIds(i), 'ID', newResultID);
        this.updateRows(rowIds(i), 'RunName', {newRunName});
    end
end

