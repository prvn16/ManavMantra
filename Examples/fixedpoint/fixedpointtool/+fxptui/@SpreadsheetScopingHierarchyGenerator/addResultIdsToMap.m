function addResultIdsToMap(this, subKey, resultIds, subsysRows)
% ADDRESULTIDSTOMAP Maps the results to the subsystem key.

% Copyright 2016-2017 The MathWorks, Inc.

if ~isempty(subKey)
    % If the table doesn't have any for the results being added, then skip adding them.
    % Added for g1496123
    if isempty(subsysRows)
        if ~this.ResultScopingMap.isKey(subKey)
            this.ResultScopingMap(subKey) = {};
        end
        return;
    end
    ah = fxptds.SimulinkDataArrayHandler;
    datasetSources = unique(subsysRows.DatasetSourceName);
    dsLength = numel(datasetSources);
    if dsLength > 1
        for i = 1:dsLength
            dsName = datasetSources{i};
            blkObj = get_param(dsName, 'Object');
            existingIds = {};
            if isa(blkObj,'Simulink.ModelReference')
                [subResultIds, subResultRows] = fxptui.ScopingTableUtil.getResultIdsForDatasetSource(dsName);
                % exclude the DataObject results from the
                % result list to be added.
                mdlBlkSubsysIds = subResultRows.SubsystemId;
                dataObjIndex = cellfun(@(x)strcmp(x, 'DataObjects'), mdlBlkSubsysIds);
                subResultIds = subResultIds(~dataObjIndex);
                uniqueID = ah.getUniqueIdentifier(struct('Object',blkObj));
                
                blkKey = uniqueID.UniqueKey;
                if this.ResultScopingMap.isKey(blkKey)
                    existingIds = this.ResultScopingMap.values({blkKey});
                end
                existingIds = [existingIds{:}, subResultIds']; %#ok<*AGROW>
                this.ResultScopingMap(blkKey) = unique(existingIds);
            else
                % Extract the result Ids that belong to the
                % model dataset. All the entries extracted will
                % relate to the subKey. Extracting the rows just
                % for the subsystem will not consider nested
                % children.
                resIdx = cellfun(@(x)strcmpi(x, dsName), subsysRows.DatasetSourceName);
                subResultIds = subsysRows.ID(resIdx);
                if this.ResultScopingMap.isKey(subKey)
                    existingIds = this.ResultScopingMap.values({subKey});
                end
                existingIds = [existingIds{:}, subResultIds']; %#ok<*AGROW>
                this.ResultScopingMap(subKey) = existingIds; %
            end
        end
    else
        dsName = datasetSources{1};
        blkObj = get_param(dsName, 'Object');
        sysResultIDs = {};
        if this.ResultScopingMap.isKey(subKey)
            sysResultIDs = this.ResultScopingMap.values({subKey});
        end
        % only append to the existing result set if the results
        % don't belong to a model reference block. Model blocks
        % have the top model as the parent. The parent should
        % not include these results.
        sysResultIDs = [sysResultIDs{:}];
        if ~isa(blkObj, 'Simulink.ModelReference')
            sysResultIDs = [sysResultIDs, resultIds']; %#ok<*AGROW>
        end
        % Remove duplicates before adding it to the map.
        this.ResultScopingMap(subKey) = sysResultIDs;
    end
end
end
