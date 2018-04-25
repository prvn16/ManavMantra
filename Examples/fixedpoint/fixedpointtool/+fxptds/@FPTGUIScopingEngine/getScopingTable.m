function tbl = getScopingTable(this)
%% GETSCOPINGTABLE function returns the SCOPING table of FPTGUIScopingEngine instance

%   Copyright 2016 The MathWorks, Inc.

    % Before returning scoping table, convert outstanding changesets to
    % ScopingTable
    this.convertChangesetToScopingTableRecords();
    
    tbl = this.ScopingTable;
end