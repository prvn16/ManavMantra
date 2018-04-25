function updateSourceNameForDataset(this, oldSourceName, newSourceName)
%% UPDATESOURCENAMEFORDATASET function updates source name of dataset to newSourceName from oldSourceName in fxptds.FPTRepository ModelDatasetMaps
%
% oldSourceName is a char
% newSourceName is a char

%   Copyright 2016-2017 The MathWorks, Inc.

    if ~strcmp(oldSourceName, newSourceName)
        if this.ModelDatasetMap.isKey(oldSourceName)
            ds = this.ModelDatasetMap.getDataByKey(oldSourceName);
            if this.ModelDatasetMap.isKey(newSourceName)
                % If the new source is already in the map (can
                % happen when the UI gets refreshed and calls are
                % made to getChildren and there is a Signal or Bus
                % object in the list), retreive the dataset,
                % disassociate the mapping and ultimately delete
                % the previous dataset to avoid recursive deletes
                % (due to cycle detection and subsequent deletion
                % of key from map) that can cause memory leaks &
                % segvs.  
                old_ds = this.ModelDatasetMap.getDataByKey(newSourceName);
                this.ModelDatasetMap.insert(newSourceName,handle([]));
                this.ModelDatasetMap.deleteDataByKey(newSourceName);
                delete(old_ds);
            end
            ds.updateSourceName(newSourceName);
            this.ModelDatasetMap.insert(newSourceName, ds);
            % remove association with the old name.
            this.ModelDatasetMap.insert(oldSourceName,handle([]));
            this.ModelDatasetMap.deleteDataByKey(oldSourceName);
        end
    end
end
