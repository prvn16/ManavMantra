function hierarchyStruct = addToTreeCache(this, hierarchyStruct)
% ADDTOTREECACHE Update the hierarchy mapping based on subsystem
% information in the table. 

% Copyright 2016-2017 The MathWorks, Inc.

% Add to the child-parent mapping
changedHierarchy = struct([]);
% dh = fxptds.SimulinkDataArrayHandler;
for i = 1:numel(hierarchyStruct)
%     modelKey = hierarchyStruct(i).model;
%     modelID = dh.getUniqueIdentifier(struct('blkObj',get_param(modelKey,'Object')));
%     childParentMap = this.TreeHierarchyCache;
    childID = hierarchyStruct(i).identifier;
    parentID = hierarchyStruct(i).parent;
    idx_child =  regexp(childID, '_dummy$', 'once');
    idx_parent = regexp(parentID, '_dummy$', 'once');
    if ~isempty(idx_child)
        baseChildKey = childID(1:idx_child-1);
        for m = 1:numel(this.AddedTreeData)
            treeData = this.AddedTreeData(m);
            if strcmpi(treeData.path, baseChildKey) && ~strcmpi(treeData.identifier, childID)
                % Check if the parent is same as childID
                if ~strcmpi(treeData.parent, childID)
                    this.TreeHierarchyCache(treeData.identifier) = childID;
                    treeData.parent = childID;
                    changedHierarchy = [changedHierarchy, treeData];
                end
            end
        end
    else
        % If there is an existing dummy node parent for the
        % function, e.g., foo & foo_dummy, then foo needs to be
        % moved under foo_dummy
        dummyParent = [hierarchyStruct(i).path '_dummy'];
        if this.TreeHierarchyCache.isKey(dummyParent)
            if ~isequal(parentID, dummyParent)
                hierarchyStruct(i).parent = dummyParent;
                % Update the parentID so that it can be
                % correctly mapped after processing.
                parentID = hierarchyStruct(i).parent;
                for p = 1:numel(this.AddedTreeData)
                    treeData = this.AddedTreeData(p);
                    if strcmpi(treeData.name, hierarchyStruct(i).name) && ~strcmpi(treeData.identifier, dummyParent)
                        this.AddedTreeData(p).parent = dummyParent;
                    end
                end
            end
        end
    end
    if ~isempty(idx_parent)
        baseKey = parentID(1:idx_parent-1);
        for n = 1:numel(this.AddedTreeData)
            treeData = this.AddedTreeData(n);
            if strcmpi(treeData.path, baseKey) && ~strcmpi(treeData.identifier, parentID)
                % Check if the parent is same as childID
                if ~strcmpi(treeData.parent, parentID)
                    this.TreeHierarchyCache(treeData.identifier) = parentID;
                    treeData.parent = parentID;
                    changedHierarchy = [changedHierarchy, treeData]; %#ok<*AGROW>
                end
            end
        end
    end
    this.TreeHierarchyCache(childID) = parentID;
%     this.TreeHierarchyCache(modelID.UniqueKey) = childParentMap;
end
hierarchyStruct = [hierarchyStruct changedHierarchy];
end