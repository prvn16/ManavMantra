function resultTable = getChangesetForCriteria(this, queryingRecord)
%% GETCHANGESETFORCRITERIA function gets rows of the ChangesetTable which match the querying record criteria
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
% result = scopingObj.getChangesetForCriteria(b);
% result = scopingObj.getChangesetForCriteria(c);
%
   
%   Copyright 2016 The MathWorks, Inc.

    % If changeset is not empty, convert the changeset to records
    % Add it to the main ScopingTable. Also stash away a changeset to
    % ChangesetTable
    this.convertChangesetToScopingTableRecords();
    
    % Query ChangesetTable for records which match the queryingRecord
    resultIndices = fxptds.FPTGUIScopingEngine.queryTable(this.ChangesetTable, queryingRecord);
    
    % Return records which match the changesetTable
    resultTable = this.ChangesetTable(resultIndices, :);
    
    % Clear changesetTable for matching records
    this.ChangesetTable(resultIndices, :)  = [];
end
