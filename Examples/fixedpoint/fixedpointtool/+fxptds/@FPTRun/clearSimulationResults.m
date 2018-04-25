function clearSimulationResults(~, results)
% CLEARSIMULATIONRESULTS  clears the simulation min/max and overflow information from the results.

%   Copyright 2012-2016 The MathWorks, Inc.
for i = 1:length(results)
    results(i).clearInstrumentationData;
end


