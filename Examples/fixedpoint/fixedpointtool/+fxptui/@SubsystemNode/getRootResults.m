function results = getRootResults(this, varargin)
% GETROOTRESULTS Gets the results from the node.

% Copyright 2013-2016 The MathWorks, Inc.


appdata = SimulinkFixedPoint.getApplicationData(this.getHighestLevelParent);
ds = appdata.dataset;
if nargin > 1 && ~isempty(varargin{1})
    % Append the run name. All current use cases of getResultsFromRuns
    % is using either a single argument as runName or no arguments.
    results = ds.getResultsFromRun(varargin{1});
else
    results = ds.getResultsFromRuns();
end

