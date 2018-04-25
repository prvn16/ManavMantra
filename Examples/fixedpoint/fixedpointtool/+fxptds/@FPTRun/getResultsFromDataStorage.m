function resultsArray = getResultsFromDataStorage(this)
    % GETRESULTSFROMDATASTORAGE Gets all the results stored in the engine for the run.
    %     Copyright 2012-2017 The MathWorks, Inc.
    
    results = this.getResultsAsCellArray();
    resultsArray = [results{1:numel(results)}];
end
