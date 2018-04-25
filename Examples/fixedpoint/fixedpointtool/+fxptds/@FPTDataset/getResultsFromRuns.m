function allresults = getResultsFromRuns(this)
% GETRESULTS Gets the results from the dataset

%     Copyright 2012-2016 The MathWorks, Inc.

    allresults = [];
    runNames = this.getAllRunNames;
    if ~isempty(runNames)
        allResults = {};
        for idx = 1:numel(runNames)
            runObj = this.getRun(runNames{idx});
            results = runObj.getResultsAsCellArray();
            if ~isempty(results)
                allResults = [allResults results]; %#ok
            end
        end
        if ~isempty(allResults)
            allresults = [allResults{:}];
        end
    end
end