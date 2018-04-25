function removeRunFromTable(this, runName)
% REMOVERUNFROMTABLE Removes the records for the specified run from the
% table.

% Copyright 2017 The MathWorks, Inc.
    
idx = strcmp(this.ResultDatabase.Run, runName);
this.ResultDatabase(idx,:) = [];

end
