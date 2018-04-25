function deleteResult(this, results)
%% DELETERESULT function deletes all results that map to the given scoping id in ScopingTable
%
% results is an array of fxptds.AbstractResult which need to be deleted
% runObject is the associated run object in which these scoping ids should
% be deleted

%   Copyright 2016 The MathWorks, Inc.

      scopingIds = {};
      resultsToDelete = {};
      for idx = 1:numel(results)
          % get the result 
          result = results(idx);
          
          % Query for scoping id 
          scopingId = result.getScopingId; 
      
          % For results with no scoping id, add it to resultsToDelete list
          if isempty(scopingId)
              resultsToDelete{end+1} = result;%#ok
          else
              % If scoping id is present, they are likely to be in scoping
              % table already. So add it to scopingIds list
              scopingIds{end+1} = scopingId{1}; %#ok
          end
      end
      
      % delete all results from the current scoping changeset that match
      % the results in resultsToDelete list
      this.deleteFromChangeset(resultsToDelete);
      
      % delete all rows from scoping table which match the scoping ids list
      this.deleteFromScopingTable(scopingIds);
end