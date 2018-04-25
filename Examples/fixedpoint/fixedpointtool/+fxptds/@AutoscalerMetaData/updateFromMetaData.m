function updateFromMetaData(this, otherMetaData)
    % updateFromMetaData(metaData, otherMetaData) updates the internal
    % fields of the meta-data based on an another meta-data object
    % Copyright 2016 The MathWorks, Inc.
    if isa(otherMetaData, 'fxptds.AutoscalerMetaData')
        
        sourceSet = otherMetaData.getResultSetsForAllSources;
        for i = 1:numel(sourceSet)
            if ~isempty(sourceSet(i).ResultSet)
                this.ResultSetForSourceMap.insert(sourceSet(i).Handle, sourceSet(i).ResultSet);
            end
        end
    end
end
% LocalWords:  fxptds Autoscaler