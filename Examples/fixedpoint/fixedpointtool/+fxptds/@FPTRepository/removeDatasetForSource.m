function removeDatasetForSource(this,srcName)
%% REMOVEDATASETFORSOURCE function given a source name (model name)
% srcName is a char indicating model name.
    % Removes the mapping between a source and its dataset in the repository.

%   Copyright 2016 The MathWorks, Inc.

    if this.ModelDatasetMap.isKey(srcName)
        this.ModelDatasetMap.deleteDataByKey(srcName);
    end
end