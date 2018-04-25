function clearScalingResults(this, results)
% CLEARSCALINGRESULTS Clears the proposed data types from the results in the run.

%    Copyright 2012-2017 The MathWorks, Inc.

    for i = 1:length(results)
        results(i).clearProposalData;
    end
    this.clearActionsQueue();
end