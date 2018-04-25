function discoverSystemHierarchy(this, sysObj, sysNode)
% DISCOVERSYSTEMHIERARCHY Connects the child systems in the model to its parent to form a hierarchy of nodes
    
%   Copyright 2017 The MathWorks, Inc.

if isempty(sysObj) ; return; end
if fxptds.isSFMaskedSubsystem(sysObj)
    sysObj = fxptds.getSFChartObject(sysObj);
end
% We cannot discover Stateflow hierarchies via find_system. Revert to using
% getHierarchicalChildren
if isa(sysObj, 'Stateflow.Object')
    hChildren = fxptui.filter(sysObj.getHierarchicalChildren);
    if sysObj.isLinked
        subsysNames = find_system(sysObj.getFullName,'FollowLinks', 'on','LookUnderMasks','all', 'Variants','AllVariants', 'SearchDepth',1,'BlockType','SubSystem');
        subsysNames = setdiff(subsysNames, sysObj.getFullName);
        hChildren = [];
        if ~isempty(subsysNames)
            for i = 1:numel(subsysNames)
                hChildren = [hChildren get_param(subsysNames{i},'Object')];  %#ok<AGROW>
            end
        end
    end
else
    subsysNames = find_system(sysObj.getFullName,'FollowLinks', 'on','LookUnderMasks','all', 'Variants','AllVariants', 'SearchDepth',1,'BlockType','SubSystem');
    mdlRefNames = find_system(sysObj.getFullName,'FollowLinks', 'on','LookUnderMasks','all','SearchDepth',1, 'BlockType','ModelReference');
    hChildNames = [subsysNames' mdlRefNames'];
    if ~isempty(hChildNames)        
        hChildren(1:numel(hChildNames)) = get_param(hChildNames{1},'Object');
        for i = 2:numel(hChildNames)
            hChildren(i) = get_param(hChildNames{i},'Object');
        end        
    else
        hChildren = [];
    end
end
filteredChildren = fxptui.filter(hChildren);
hiddenChildren = setdiff(hChildren, filteredChildren);
for i = 1:numel(filteredChildren)
    child = filteredChildren(i);
    if fxptds.isSFMaskedSubsystem(child)
        child = fxptds.getSFChartObject(child);
    end
    if ~isequal(child, sysObj)
        childNode = this.createNode(child);
        sysNode.addChildren(childNode);
        sysNode.HasChildren = true;
        if sysObj.isLinked
            % For the results to show up correctly, we will force the linked
            % children to map to the linked entity and not the library
            this.ChildParentMap(childNode.Identifier) = sysNode.Identifier;
        end
        this.discoverSystemHierarchy(child, childNode);
    end
end
for i = 1:numel(hiddenChildren)
    uid = this.getIdentifierObject(hiddenChildren(i));
    parentID = this.getParentIdentifier(hiddenChildren(i));
    this.ChildParentMap(uid.UniqueKey) = parentID;
end
end
