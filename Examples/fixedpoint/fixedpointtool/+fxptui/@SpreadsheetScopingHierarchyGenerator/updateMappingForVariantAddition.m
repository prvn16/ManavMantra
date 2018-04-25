function updateMappingForVariantAddition(this, updatedTreeArray)
% UPDATEMAPPINGFORVARIANTADDITION Update the result mapping for the variant
% subsystem addition (MATLAB function workflow).

% Copyright 2016-2017 The MathWorks, Inc.

subsysResultMap = this.ResultScopingMap;
% modelCache = this.TreeHierarchyCache;
% dh = fxptds.SimulinkDataArrayHandler;
for idx = 1:numel(updatedTreeArray)
    updatedTree = updatedTreeArray{idx};
    dataLength = numel(updatedTree);
    childIDs = {};
    parentIDs = {};
    childIDs(1:dataLength) = {''};
    parentIDs(1:dataLength) = {''};
    % The updated tree inforamtion for each structure always
    % belongs to one model.
%     modelID = dh.getUniqueIdentifier(struct('blkObj',get_param(updatedTree(1).model,'Object')));
    for i = 1:numel(updatedTree)
        childIDs{i} = updatedTree(i).identifier;
        parentIDs{i} = updatedTree(i).parent;
        % If the child ID exists in the previous scoping map, then
        % check to see if the parent also has the same mapping.
        if subsysResultMap.isKey(childIDs{i})
            childResultIds = subsysResultMap(childIDs{i});
            parentResultIds = childResultIds;
            if subsysResultMap.isKey(parentIDs{i})
                parentResultIds = unique([parentResultIds subsysResultMap(parentIDs{i})]);
            end
            subsysResultMap(parentIDs{i}) = parentResultIds;
        end
    end
%     if modelCache.isKey(modelID.UniqueKey)
%         subsysParentCache = modelCache(modelID.UniqueKey);
%         keys = modelCache.keys;
%         val = modelCache.values;
%         for m = 1:numel(childIDs)
%             % If the child ID already exists in the map, make
%             % sure the cached parent is the same as the new
%             % one. If not, update it.
%             modelCache(childIDs{m}) = parentIDs{m};
%             % Find the indices of the parent in the previous
%             % map
%             index = find(cellfun(@(x)(isequal(x,parentIDs{m})), val) == 1);
%             for k = index
%                 % if we cannot find the key within the new
%                 % hierarchy with the same parent, then it must
%                 % no longer exist. Remove it from the key.
%                 if sum(strcmp(keys(k), childIDs) == 0)
%                     if modelCache.isKey(keys(k))
%                         modelCache.remove(keys(k));
%                     end
%                 end
%             end
%         end
%         this.UnresolvedVariantHierarchy = [this.UnresolvedVariantHierarchy this.getUnresolvedHierarchyAfterVariantCreation(childIDs)];
%     end
end
end