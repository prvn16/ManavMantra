function updatedata(h, runs)
%UPDATEDATA refreshes data

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

% get the latest run that was created and refresh any figures associated with it.
runName = h.getFPTRoot.getDAObject.FPTRunName;
runs = h.getdataset.getRunNumberForRun(runName);

if ~isempty(runs)
    results = h.getresults(runs);
    for r = 1:numel(results)
        result = results(r);
    end
end
   

% [EOF]
