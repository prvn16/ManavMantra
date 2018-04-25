function allDatasets = getAllDatasets(this)
    % Returns an array of dataset objects stored in the repository.

%   Copyright 2016 The MathWorks, Inc.

    cnt = this.ModelDatasetMap.getCount;
    if cnt > 0
        for i = 1:cnt
            allDatasets(i) = this.ModelDatasetMap.getDataByIndex(i); %#ok<AGROW>
        end
    else
        allDatasets = [];
    end
end