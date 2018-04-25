function collectdata(h)
%COLLECTDATA Post processing of simulation data collected.

%   Copyright 2006-2016 The MathWorks, Inc.

 bd = h.getTopNode.getDAObject;

% Delete all previous listeners that are needed for the UI to react to
% signal logging changes in the datasets. They will be added on the most
% current dataset objects after the data collection is done. 
if ~isempty(h.DatasetListener)
    delete(h.DatasetListener);
    h.DatasetListener = [];
end

% re-populate the referenced models if they were previously closed
loadReferencedModels(h);

SimulinkFixedPoint.ApplicationData.doPostRangeCollectionTasks(bd, bd.FPTRunName);

allDatasets = h.getAllDatasets;
try
    SimulinkFixedPoint.Autoscaler.collectPostSimData(allDatasets, bd.FPTRunName);
catch fpt_exception%#ok<NASGU>
end

h.HasCompletedDataCollection = true;

%----------------------------------------------------------------------------
% [EOF]

