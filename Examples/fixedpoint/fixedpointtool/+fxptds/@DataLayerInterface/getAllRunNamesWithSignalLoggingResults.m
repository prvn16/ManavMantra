function allRunNamesWithSignalLoggingResults = getAllRunNamesWithSignalLoggingResults(~, dataset)
%% GETALLRUNNAMESWITHSIGNALLOGGINGRESULTS function access dataset and returns runnames which has only 
% signal logging results

%   Copyright 2017 The MathWorks, Inc.

    % Access dataset to get all run names
    allRunNames = dataset.getAllRunNames;
    allRunNamesWithSignalLoggingResults = {};
    for idx=1:numel(allRunNames)
        runObject = dataset.getRun(allRunNames{idx});
        results = runObject.getResults;
        % Check if any of the results in the run object have plottable
        % signals (indicating signal logging results)
        if numel(results) > 0 && runObject.hasPlottableSignals
            allRunNamesWithSignalLoggingResults{end+1} = allRunNames{idx}; %#ok
        end
    end
end