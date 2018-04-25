function datasetSource = getDatasetSource(runObject)
%% GETDATASETSOURCE function returns the name of the dataset given a fxptds.FPTRun instance
%
% runObject is an instance of fxptds.FPTRun
% datasetSource is a cell array representing the dataset source name associated
% with fxptds.FPTRun object

%   Copyright 2016 The MathWorks, Inc.

    datasetSource = {''};
    if isvalid(runObject)
        datasetSource = {runObject.Source};
    end
end