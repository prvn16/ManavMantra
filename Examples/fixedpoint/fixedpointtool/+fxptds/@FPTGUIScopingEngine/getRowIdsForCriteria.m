function rowIds = getRowIdsForCriteria(this, queryingRecord)
%% GETROWSIDSFORCRITERIA function gets rows of the table which match the querying record criteria
%
% queryingRecord is an instance of fxptds.FPTGUIScopingTableRecord 
% Each object can can contain multiple querying elements as cell array in
% field value.
% 
% rowIds is an array of indices into scoping table. 

%   Copyright 2016 The MathWorks, Inc.

    % Convert the changeset to records
    % Add it to the main ScopingTable. Also stash away a changeset to
    % ChangesetTable
    this.convertChangesetToScopingTableRecords();
    
    % Query for matching row ids and 
    rowIds = fxptds.FPTGUIScopingEngine.queryTable(this.ScopingTable, queryingRecord);
end