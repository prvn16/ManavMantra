function clearSignalResults(this, results)
% CLEARSIGNALRESULTS clears the time-series information from the results in the run.

%   Copyright 2012-2016 The MathWorks, Inc.

for i = 1:length(results)
    results(i).clearSignalLogData;
    if ~results(i).hasInterestingInformation
        results(i).setVisibility(false);
    end
end

