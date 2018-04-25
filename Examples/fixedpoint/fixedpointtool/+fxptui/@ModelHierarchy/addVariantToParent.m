function addVariantToParent(this, slVariantObj, slParentObj)
% ADDVARIANTTOPARENT Updates the hierarchy with variant subsystems added
% for MLFB.

% Copyright 2017 The MathWorks, Inc.

parentNode = this.findNode('Object', slParentObj);
variantNode = this.createNode(slVariantObj);
parentNode.addChildren(variantNode);
this.discoverSystemHierarchy(slVariantObj, variantNode);

% At this point, there will be at least one MLFB node that has old
% parenting. This will need to be moved to the new parent.
variantID = variantNode.Identifier;
variantChildren = variantNode.getChildren;
for i = 1:numel(variantChildren)
    variantChild = variantChildren(i);
    existingNode = this.findNode('Object',variantChild.Object);
    % remove the new child from the array of existng nodes
    existingNode = setdiff(existingNode, variantChild, 'stable');
    for m = 1:numel(existingNode)
        if ~strcmp(existingNode(m).ParentIdentifier,variantID)            
            existingChildren = existingNode(m).getChildren;            
            for p = 1:numel(existingChildren)
                % Disconnect from old parent before reparenting.
                existingChildren(p).disconnect
                % Update the child parent map to reflect the new parent
                this.ChildParentMap(existingChildren(p).Identifier) = variantChild.Identifier;
                this.updateDisplayPathOfMLFBNode(existingChildren(p));
            end
            variantChild.addChildren(existingChildren);
            % Since the variantChild is the new version of the MATLAB
            % function block, we also need to cache the old displayPath so
            % that older results (from oldrer runs) have the correct
            % display path.
            if ~iscell(variantChild.DisplayPath)
                newDisplayPath = {variantChild.DisplayPath};
            else
                newDisplayPath = variantChild.DisplayPath;
            end
            oldDisplayPath = {existingNode(m).DisplayPath};
            variantChild.DisplayPath = [oldDisplayPath, newDisplayPath];
            
            % Remove the existing node from the hierarchy since there is a
            % new node to represent its new place in the hierarchy
            oldParent = this.findNode('Identifier',existingNode(m).ParentIdentifier);
            oldChildren = oldParent.getChildren;
            for k = 1:numel(oldChildren)
                oldChildren(k).disconnect;
            end
            updatedChildren = setdiff(oldChildren, existingNode(m));
            if ~isempty(updatedChildren)
                oldParent.addChildren(updatedChildren);
            end
            % This node is already disconnected from parent on line 42
            delete(existingNode(m));
        end
    end
end
this.AddedTree = [this.AddedTree variantNode variantChildren'];
end