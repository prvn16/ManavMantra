function isDataSetEmpty = isDataSetEmptyForModel(obj)
% Accepts an input argument which is either the block, subsystem, sf chart
% or model node this will return true if ds is empty for the given object,
% else return false. 

% This will not work for variables. The concrete API is in work and will be
% available with new dataset.


%   Copyright 2015 The MathWorks, Inc.

rep = fxptds.FPTRepository.getInstance;
ds = rep.getDatasetForSource(bdroot(obj.getFullName));
results = ds.getResultsFromRuns;
isDataSetEmpty = false;
if isempty(results)
    isDataSetEmpty = true;
end
