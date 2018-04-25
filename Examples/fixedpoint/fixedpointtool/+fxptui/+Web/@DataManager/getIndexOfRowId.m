function idx = getIndexOfRowId(this, rowId)
% GETINDEXOFROWID Get the index of the rowId given the last known sort
% order
    
% Copyright 2017 The MathWorks, Inc.

idx = find(strcmp(this.LastScopedTable(this.LastSortIndices, 'id').id, rowId));

end
