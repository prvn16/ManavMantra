function datasets = getAllDatasets(this)
%GETDATASET Get the dataset.

%   Copyright 2015-2016 The MathWorks, Inc.

datasets = fxptds.getAllDatasetsForModel(this.Model);