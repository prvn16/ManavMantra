function resultTable = getRowsForCriteria(this, queryingRecord)
%% GETROWSFORCRITERIA function get rows of the table which match the querying record criteria
%
% queryingRecord is an instance of fxptds.FPTGUIScopingTableRecord 
% Each object can can contain multiple querying elements as cell array in
% field value. All field values will be AND-ed in the searching of results
% E.g., 
% c = fxptds.FPTGUIScopingTableRecord
%    FPTGUIScopingTableRecord with properties:
% 
%           SubsystemId: []
%              ResultId: []
%               RunName: {'Run 1'}
%     DatasetSourceName: []
%            ResultName: []
%           SubsystemID: []
%
% b = 
%    FPTGUIScopingTableRecord with properties:
% 
%           SubsystemId: {'4000004000000000::1'}
%              ResultId: {'4041800400000000::Output'}
%               RunName: []
%     DatasetSourceName: []
%            ResultName: []
%
% scopingObj = fxptds.FPTGUIScopingEngine.getInstance();
% result = scopingObj.getRowsForCriteria(b);
% result = scopingObj.getRowsForCriteria(c);
%
   
%   Copyright 2016 The MathWorks, Inc.

    % Convert the changeset to records
    % Add it to the main ScopingTable. Also stash away a changeset to
    % ChangesetTable
    this.convertChangesetToScopingTableRecords();
    
    % Query ScopingTable for records which match the queryingRecord
    resultIndices = fxptds.FPTGUIScopingEngine.queryTable(this.ScopingTable, queryingRecord);
    
    % return the rows which match the query
    resultTable = this.ScopingTable(resultIndices, :);
end