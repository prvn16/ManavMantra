function allRunNamesWithResults = getAllRunNamesWithResults(~, dataset)
%% GETALLRUNNAMESWITHRESULTS function accesses dataset APIs to return run names 
% which have a non-zero number of results 

%   Copyright 2017 The MathWorks, Inc.

    % Access all runnames from dataset 
    allRunNames = dataset.getAllRunNames;
    
    % Filter out run names if the result count == 0
    allRunNamesWithResults = {};
    for idx=1:numel(allRunNames)
        runObject = dataset.getRun(allRunNames{idx});
        results = runObject.getResults;
        if numel(results) > 0
            allRunNamesWithResults{end+1} = allRunNames{idx}; %#ok
        end
    end
end