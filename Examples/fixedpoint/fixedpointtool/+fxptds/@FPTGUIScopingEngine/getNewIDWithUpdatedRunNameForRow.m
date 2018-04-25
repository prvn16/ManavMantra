function newResultID = getNewIDWithUpdatedRunNameForRow(this, rowId, oldRunName, newRunName)
%% GETNEWIDWITHUPDATEDRUNNAMEFORROW Returns a new ID for an existing row 
    
% Copyright 2016 The MathWorks, Inc.

    % Replace the old run name information with new run name in the existing ID and return the modified string.
    oldResultID = this.ScopingTable.ID(rowId);
    newResultID = strrep(oldResultID,['#' oldRunName '#'], ['#' newRunName '#']);
end

