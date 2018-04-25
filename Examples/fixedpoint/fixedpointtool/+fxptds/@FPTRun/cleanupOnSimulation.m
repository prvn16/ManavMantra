function cleanupOnSimulation(this, isMerged)
% CLEANUPONSIMULATION Cleans up the relevant information when simulation is performed.

%   Copyright 2012-2017 The MathWorks, Inc.


% To improve performance, retreive the results once and do the cleanup.
results = this.getResults;

this.clearSignalResults(results);
if ~isMerged
    this.clearSimulationResults(results);
end
this.clearScalingResults(results);


results = this.getResults;
for i = 1:length(results)
    results(i).setAsReadOnly(false);
end
% Clear RootFunctionIDsMap
this.RootFunctionIDsMap.Clear;


