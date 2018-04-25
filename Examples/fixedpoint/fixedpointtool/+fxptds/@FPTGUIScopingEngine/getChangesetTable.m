function changesetTable = getChangesetTable(this)
%% GETCHANGESETTABLE function returns the current changeset table of FPTGUIScopingEngine instance

%   Copyright 2016 The MathWorks, Inc.

    % Convert outstanding changesets to changeset table
    this.convertChangesetToScopingTableRecords();
    
    changesetTable = this.ChangesetTable;
    
    % Clearing changeset table once requested. 
    this.ChangesetTable = [];
end