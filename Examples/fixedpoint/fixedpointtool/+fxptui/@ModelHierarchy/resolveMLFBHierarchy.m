function mlfbNodes = resolveMLFBHierarchy(this, mlfbNodes)
% RESOLVEMLFBNODES Resolve new mlfb nodes with existing ones. This handles
% specialization design cases.

% Copyright 2017 The MathWorks, Inc.

for i = 1:numel(mlfbNodes)
    childID = mlfbNodes(i).Identifier;
    parentID = mlfbNodes(i).ParentIdentifier;
    idx_child =  regexp(childID, '_dummy$', 'once');
    idx_parent = regexp(parentID, '_dummy$', 'once');
    if ~isempty(idx_child)
        baseChildKey = childID(1:idx_child-1);
        for m = 1:numel(this.AddedTree)
            treeData = this.AddedTree(m);
            if strcmpi(treeData.Path, baseChildKey) && ~strcmpi(treeData.Identifier, childID)
                % Check if the parent is same as childID
                if ~strcmpi(treeData.ParentIdentifier, childID)
                    this.ChildParentMap(treeData.Identifier) = childID;
                    this.AddedTree(m).ParentIdentifier = childID;
                end
            end
        end
    else
        % If there is an existing dummy node parent for the
        % function, e.g., foo & foo_dummy, then foo needs to be
        % moved under foo_dummy
        dummyParent = [regexprep(mlfbNodes(i).Path, '>\d$', ''), '_dummy'];
        if this.ChildParentMap.isKey(dummyParent)
            if ~isequal(parentID, dummyParent)
                mlfbNodes(i).ParentIdentifier = dummyParent;
                % Update the parentID so that it can be
                % correctly mapped after processing.
                parentID = dummyParent;
                for p = 1:numel(this.AddedTree)
                    treeData = this.AddedTree(p);
                    if strcmpi(treeData.Name, mlfbNodes(i).Name) && ~strcmpi(treeData.Identifier, dummyParent)
                        this.AddedTree(p).ParentIdentifier = dummyParent;
                    end
                end
            end
        end
    end
    if ~isempty(idx_parent)
        baseKey = parentID(1:idx_parent-1);
        for n = 1:numel(this.AddedTree)
            treeData = this.AddedTree(n);
            if strcmpi(treeData.Path, baseKey) && ~strcmpi(treeData.Identifier, parentID)
                % Check if the parent is same as childID
                if ~strcmpi(treeData.ParentIdentifier, parentID)
                    this.ChildParentMap(treeData.Identifier) = parentID;
                    this.AddedTree(n).ParentIdentifier = parentID;
                end
            end
        end
    end
    this.ChildParentMap(childID) = parentID;
end
end