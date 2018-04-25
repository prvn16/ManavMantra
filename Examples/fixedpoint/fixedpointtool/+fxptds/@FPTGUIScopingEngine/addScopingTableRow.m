function addScopingTableRow(this, scopingTableRecordObj)
%% ADDSCOPINGTABLEROW function adds a row to ScopingTable member in fxptds.FPTGUIScopingTableAdapter
%
% this is an instance of fxptds.FPTGUIScopingAdapter
%
% scopingTableRecord is an instance of
% fxptds.FPTGUIScopingTableFactory.getRecord() struct.
%
    % convert the object to a cell array

%   Copyright 2016 The MathWorks, Inc.

    cArray = fxptds.FPTGUIScopingAdapter.getCellArrayFromScopingTableRecord(scopingTableRecordObj);
    
    % input is a cell, convert it to table entry 
    tableRow = cell2table(cArray);
    
    % change the variable names of tableRow to that of ScopingTable
    tableRow.Properties.VariableNames = this.ScopingTable.Properties.VariableNames;
    
    % add table entry as a row to existing table.
    this.ScopingTable = [this.ScopingTable; tableRow];
end