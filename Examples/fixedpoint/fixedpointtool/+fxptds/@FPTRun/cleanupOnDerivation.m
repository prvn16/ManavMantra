function cleanupOnDerivation(this)
% CLEANUPONDERIVATION Cleans up the relevant information before range analysis.

%   Copyright 2012-2017 The MathWorks, Inc.

% To improve performance, retreive the results once and do the cleanup.
results = this.getResults;
this.clearScalingResults(results);
this.clearRangeAnalysisResults(results);


results = this.getResults;
for i = 1:length(results)
    results(i).updateVisibility;
end
% Clear RootFunctionIDsMap
this.RootFunctionIDsMap.Clear;


