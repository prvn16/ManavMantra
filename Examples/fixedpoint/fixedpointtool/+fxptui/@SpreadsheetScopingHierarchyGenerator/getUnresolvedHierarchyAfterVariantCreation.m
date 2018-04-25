function unresolvedHierarchy = getUnresolvedHierarchyAfterVariantCreation(this, clientIDs)
% GETUNRESOLVEDHIERARCHYAFTERVARIANTCREATION Get the tree data structure
% that was not carried over with the new MATLAB Function block variant
% creation.

% Copyright 2016-2017 The MathWorks, Inc.

unresolvedHierarchy = [];
for k = 1:numel(this.AddedTreeData)
    if any(strcmp(clientIDs, this.AddedTreeData(k).parent))
        unresolvedHierarchy = [unresolvedHierarchy this.AddedTreeData(k)]; %#ok<AGROW>
        % Update the hierarchy with the new path to the
        % block. This is used to trim the relative name of the
        % result.
        if ~isempty(this.AddedTreeData(k).chartID)
            unresolvedHierarchy(end).path = sprintf('%s/%s',fxptds.getBlockPathFromIdentifier(this.AddedTreeData(k).chartID, 'Stateflow'),...
                this.AddedTreeData(k).name);
        end
    end
end

end