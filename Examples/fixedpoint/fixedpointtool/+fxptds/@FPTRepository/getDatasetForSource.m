function datasetObj = getDatasetForSource(this, srcName)
    % Returns the dataset object associated with the source.

%   Copyright 2016 The MathWorks, Inc.
    datasetObj = [];
    if ~isempty(srcName)    
        if ~this.ModelDatasetMap.isKey(srcName)
            this.createDataset(srcName);
        end
        datasetObj = this.ModelDatasetMap.getDataByKey(srcName);
    end
end
