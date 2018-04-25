function [map, filteredHierarchyStuct] = generateMappingForTable(this, scopingTable)
% GENERATEMAPPINGFORTABLE Create/update the mapping between subsystems and
% results they parent. This mapping is used to decide what results to show
% when a node is clicked in the UI.

% Copyright 2016-2017 The MathWorks, Inc.

map = this.ResultScopingMap;
filteredHierarchyStuct = struct([]);

if isempty(scopingTable)
    return
end
allKeys = this.TreeHierarchyCache.keys;
tableSubsysKeys = unique(scopingTable.SubsystemId);
dataObjectKey = 'DataObjects';
if ~isempty(tableSubsysKeys)
    additionalKeysToBeProcessed = setdiff(tableSubsysKeys, [allKeys, {dataObjectKey, 'Empty'}]);
    
    if ~isempty(additionalKeysToBeProcessed)
        % If the subsystem Ids that are in the table are not
        % part of the model hierarchy captured, then capture
        % them as part of the tree if they belong to the top
        % model or its referenced models. This condition
        % triggers when:
        %   * You have MATLAB sub function entries in the table
        %   * You have entries for subsystems under functional
        %     masks
        scopingEngine = fxptds.FPTGUIScopingEngine.getInstance;
        for i = 1:numel(additionalKeysToBeProcessed)
            if this.isIDMemberOfCurrentModel(additionalKeysToBeProcessed{i})
                uniqueID = scopingEngine.getSubsystemIdentifier(additionalKeysToBeProcessed{i});
                this.TreeData.generateParentChildMapping(uniqueID);
           end
        end
    end
        subsysKeys = this.TreeHierarchyCache.keys;
        parentKeys = this.TreeHierarchyCache.values;
               
        for i = 1:numel(subsysKeys)
            subKey = subsysKeys{i};
            parentKey = parentKeys{i};
            tempRows = struct([]);
                       
            [newSubsysResultIDs, childSubsysRows] = fxptui.ScopingTableUtil.getResultIdsForSystemId(subKey);
            if isempty(newSubsysResultIDs)
                continue;
            end
            this.addResultIdsToMap(subKey, newSubsysResultIDs, childSubsysRows);
            % Get the result IDs from the map after adding the
            % new set. The scoping table might not have results for
            % the key, but the map might have results due to
            % hierarchical information
            if this.ResultScopingMap.isKey(subKey)
                newSubsysResultIDs = this.ResultScopingMap(subKey)';
            end
            newSubsysResultIDs = unique(newSubsysResultIDs, 'stable');
            % Rebuild the subsysRows based on the resultIds.
            % The previously returned childSubsysRows will only
            % contain its immediate child's subsys rows. We need to consider nested children too.
            for n = 1:numel(newSubsysResultIDs)
                tempRows = [tempRows; table2struct(fxptui.ScopingTableUtil.getRowForResultID(newSubsysResultIDs{n}))];
            end
            if ~isempty(tempRows)
                childSubsysRows = [childSubsysRows; struct2table(tempRows)];
            end
            
            % (NR) Don't add FPTRoot to the map since no results are supposed
            % to show up in spreadsheet
            if ~isempty(parentKey) && ~strcmp(parentKey, 'FPTRoot')
                [newParentResultIDs, parentSubsysRows] = fxptui.ScopingTableUtil.getResultIdsForSystemId(parentKey);
                % For every subsystem, get its parent and update the parent
                % map to include the results for the subsystem as well as the
                % parent results EXCEPT when the node is a model reference
                % instance - then we don't include the instance results in
                % the parent view. This is to keep consistent behavior
                % between old FPT & new FPT.
                this.addResultIdsToMap(parentKey, [newSubsysResultIDs;newParentResultIDs], [childSubsysRows;parentSubsysRows]);
                
                % Add the result set to all ancestors of the
                % parent. This will ensure correct result sets
                % even if the subsystem/parent pairs are not
                % processed in order.
                 % Added for g1465800, g1467760
                this.updateMappingOfAllAncestors(this.TreeHierarchyCache, parentKey, [newSubsysResultIDs;newParentResultIDs], [childSubsysRows;parentSubsysRows]);
            end
        end
        
        % MATLAB functions can have different identifiers for
        % the same function depending on how the model was
        % run. Consolidate all the results across the IDs.
        this.unifyResultMappingForMATLABFunctions; 
        
        % There could be data objects that are from a different model that
        % gets added to this result map. This is because, the scoping table
        % can contain DataObject entries from multiple models. We can't
        % distinguish unless we have the entire model list.
        % Note that although those dataObject are added to the
        % DataObjects, FPT does not show those dataObjects results when
        % selecting the Data Objects node because only the results
        % belonging to the current model are sent to the client.
        dsSourceNames = unique(scopingTable.DatasetSourceName);
        for i = 1:numel(dsSourceNames)
            % Don't process model reference block datasets. We will only
            % look at top models and sub models.
            if isempty(strfind(dsSourceNames{i}, ':'))
                [newSubsysResultIDs, subsysRows] = fxptui.ScopingTableUtil.getResultIdsForSystemInDataset(dataObjectKey, dsSourceNames{i});
                this.addResultIdsToMap(dataObjectKey, newSubsysResultIDs, subsysRows);
            end
        end
end
end
