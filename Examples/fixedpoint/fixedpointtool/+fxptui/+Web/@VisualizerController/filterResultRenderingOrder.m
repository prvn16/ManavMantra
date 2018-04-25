function filteredOrder = filterResultRenderingOrder(~, results, runName)
%% FILTERRESULTRENDERINGORDER function filters the input results wrt the last updated run 

%   Copyright 2016 The MathWorks, Inc.

    % filter results to given run name
    results = fxptds.Utils.filterResultsByRunName(runName, results);

    % get ScopingIds of results
    scopingIds = cellfun(@(x) x.getScopingId, results, 'UniformOutput', false);
    filteredOrder = scopingIds;
end
