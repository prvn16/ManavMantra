function deleteRowsForCriteria(this, queryingRecord)
%% DELETEROWSFORCRITERIA function deletes rows of the table which match the querying record criteria
%
% queryingRecord is array of struct containing fields given by getfieldNames
% function of fxptds.FPTGUIScopingTableFactory
% Each struct field can contain multiple querying elements as cell array in
% field value. All field values will be AND-ed in the searching of results
% E.g., 
% c = 
%   struct with fields:
% 
%           SubsystemId: []
%              ResultId: []
%               RunName: {'Run 1'}
%     DatasetSourceName: []
%            ResultName: []
%           SubsystemID: []
%
% b = 
%   struct with fields:
% 
%           SubsystemId: {'4000004000000000::1'}
%              ResultId: {'4041800400000000::Output'}
%               RunName: []
%     DatasetSourceName: []
%            ResultName: []
%
% scopingAdapterObj = fxptds.FPTGUIScopingAdapter.getInstance();
% scopingAdapterObj.deleteRowsForCriteria(b);
% scopingAdapterObj.deleteRowsForCriteria(c);
%
    % Query ScopingTable based on input querying criteria

%   Copyright 2016 The MathWorks, Inc.

    toDelete =  fxptds.FPTGUIScopingEngine.queryTable(this.ScopingTable, queryingRecord);
    
    % Delete the resulting row ids from the table
    this.ScopingTable(toDelete, :) = [];
end
