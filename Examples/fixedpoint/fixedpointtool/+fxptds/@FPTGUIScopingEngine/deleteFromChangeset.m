function deleteFromChangeset(this, results)
%% DELETEFROMCHANGESET function removes result from the current changeset 
% as they are soon to be deleted in dataset
% This function is called via "NotifyDeleteResult" or
% "NotifyDeleteAllResults" event from the dataset and run object

%   Copyright 2016 The MathWorks, Inc.

    % Collect all invalid results from current scoping changeset and delete
    % them 
    validResultIndices = cellfun(@(x) fxptds.isResultValid(x), ...
                                        this.CurScopingChangeset, ...
                                        'UniformOutput', ...
                                        false);
    
    invalidResultIndices = ~([validResultIndices{:}]);                                
    this.CurScopingChangeset(invalidResultIndices) = [];
    
    % Collect all unique keys from current scoping changeset
    changesetUniqueKeys = cellfun(@(x) x.getUniqueIdentifier.UniqueKey, ...
                                        this.CurScopingChangeset, ...
                                        'UniformOutput', ...
                                        false);
                       
    % Collect all unique keys from input results
    inputUniqueKeys = cellfun(@(x) x.getUniqueIdentifier.UniqueKey, ...
                                        results, ...
                                        'UniformOutput', ...
                                        false);
    
    % Find unique identifiers which are a part of the current scoping changeset
    resultIndicesToRemove = ismember(changesetUniqueKeys, inputUniqueKeys);
    
    if any(resultIndicesToRemove)
        % Remove the results from the scoping changeset
        this.CurScopingChangeset(resultIndicesToRemove) = [];
    end
end