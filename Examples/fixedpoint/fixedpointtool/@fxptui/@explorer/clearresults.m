function clearresults(h, varargin)
%CLEARRESULTS clear results

%   Copyright 2006-2016 The MathWorks, Inc.

% clear by passing in run number of run name

% get all datasets in the model hierarchy
blkDgms = h.getBlkDgmNodes;
if nargin > 1
    runName = varargin{1};
end
for idx = 1:length(blkDgms)
    curAppData = SimulinkFixedPoint.getApplicationData(blkDgms(idx).getHighestLevelParent);
    ds = curAppData.dataset;
    if nargin > 1
        ds.deleteRun(runName);
    else
        ds.clearResultsInRuns();
    end
    
    % recurse to model block dataset as well
    if curAppData.subDatasetMap.Count > 0        
        subDatasets = curAppData.subDatasetMap.values;
        for in_idx = 1:length(subDatasets)
           subDs =  subDatasets{in_idx};
           if nargin > 1
               subDs.deleteRun(runName);
           else
               subDs.clearResultsInRuns();
           end
        end
    end
end

h.getFPTRoot.fireHierarchyChanged;
h.ExternalViewer.runsDeleted(varargin); 
h.updateactions;

% [EOF]

% LocalWords:  datasets
