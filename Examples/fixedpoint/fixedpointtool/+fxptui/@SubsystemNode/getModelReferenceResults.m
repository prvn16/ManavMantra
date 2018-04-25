function results = getModelReferenceResults(this, varargin)
% GETMODELREFERENCERESULTS Gets the results from the model reference blocks contained in the node.

% Copyright 2013-2016 The MathWorks, Inc.

    results = [];
    appdata = SimulinkFixedPoint.getApplicationData(this.getHighestLevelParent);
    subDatasetMap = appdata.subDatasetMap.values;
    
    runName = {};
    if nargin > 1 && ~isempty(varargin{1})
        % Append the run name. All current use cases of getResultsFromRuns
        % is using either a single argument as runName or no arguments. 
        runName(end+1) = varargin{1};
    end
    for k = 1:length(subDatasetMap)
        ds = subDatasetMap{k};
        if ~isempty(runName)
            results = [results ds.getResultsFromRun(runName)]; %#ok
        else
            results = [results ds.getResultsFromRuns]; %#ok 
        end
    end
end

