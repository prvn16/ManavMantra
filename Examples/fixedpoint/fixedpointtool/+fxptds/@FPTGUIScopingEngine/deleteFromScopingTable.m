function deleteFromScopingTable(this, scopingIds)
%% DELETEFROMSCOPINGTABLE function deletes rows mapping to scopingIds 

%   Copyright 2016 The MathWorks, Inc.

      idCol = this.ScopingTable.ID;

      % initialize ids to delete to empty
      idsToDelete = zeros(numel(idCol), 1);

      % for each scoping Ids, check if idCol has it
      for idx = 1:numel(scopingIds)
         cmpIndices = strcmp(idCol, scopingIds{idx});

         % logical or indices to get union of all ids to delete
         idsToDelete = idsToDelete | cmpIndices;
      end

      if ~isempty(find(idsToDelete == 1, 1))
        % delete them from scoping table
        this.ScopingTable(idsToDelete, :) = [];
      end      
end