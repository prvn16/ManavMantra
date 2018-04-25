function chNodes = generateNodesForMATLABFunction(this, functionID)
% GENERATENODESFORMATLABFUNCTION Creates tree nodes for functions under
% MATLAB Function block discovered after a simulation or range analysis
% workflow.

% Copyright 2017 The MathWorks, Inc.

mlfbBlock = functionID.BlockIdentifier.getObject;
mlfbObj = fxptds.getSFChartObject(mlfbBlock);
modelNodes = [this.TopModelNode this.SubModelNode];
mlfbTreeNode = findobj(modelNodes,'Object', mlfbObj);
% Do not cache the functionIDs in the uniqueID map as we will not be able to
% recreate them without simulating/deriving again.

%The MLFB node might not have been discovered before. When the MLFB is under
% a linked masked subsystem, the MATLAB Function block is not discovered at
% the time of tree construction - SF only returns the linked chart and not
% the MLFB block. Once the link is broken by the user, the MLFB block becomes
% discoverable. See g1567671
if isempty(mlfbTreeNode)
    % mlfbObj is the Stateflow.EMChart object. Get the parent of the
    % wrapping subsystem 
    parentObj = mlfbObj.up.getParent;
    childObjArray = mlfbObj;
    parentObjArray = parentObj;
    parentNode = findobj(modelNodes,'Object', parentObj);
    % Find the ancestor that has an existing treenode
    while isempty(parentNode)
        childObjArray = [childObjArray parentObj]; %#ok<*AGROW>
        parentObj = parentObj.getParent;
        parentObjArray = [parentObjArray parentObj];
        parentNode = findobj(modelNodes,'Object', parentObj);
        if isa(parentObj, 'Simulink.BlockDiagram')
            break;
        end
    end
    if isempty(parentNode)
        parentNode = this.createNode(parentObj);
    end
    % The last child in the childObjArray will be the child of the
    % parentNode. After that, every previous childObjArray element will
    % be the child of the succeding childObjArray element
    % We will not call discoverHierarchy on the parent node as it can be
    % expensive to discover all its children rather than fill the gaps for
    % this very specific MLFB workflow.
    for i = length(childObjArray):-1:1
        node = this.createNode(childObjArray(i));
        parentNode.addChildren(node);
        parentNode.HasChildren = true;
        parentNode = node;
        % if is not under mask, or if it is under mask and if the masked
        % parent and the object itself are equal (meaning it itself has the
        % mask), then add it to the tree.
        if ~node.IsUnderMask || isequal(node.Object, node.MaskedParent)
            this.AddedTree = [this.AddedTree node];
        end
    end
    mlfbTreeNode = findobj(modelNodes,'Object', mlfbObj);
end

if functionID.NumberOfInstances > 1
    dummyID = functionID.copyAndSetInstanceCountToOne(functionID);
    dummyPath = fxptui.removeLineBreaksFromName([dummyID.BlockIdentifier.getObject.getFullName '/' dummyID.getDisplayName]);
    dummyIdentifier = sprintf('%s_%s',dummyPath ,'dummy');
    existingNode = this.findNode('Identifier', dummyIdentifier);
    count = 1;
    if isempty(existingNode)
        chNodes(count) =  this.createMLFBNode(dummyID, [], mlfbTreeNode, true);
        existingNode = chNodes(count);
        count = count + 1;
    end    
    functionNode = this.findNode('Identifier', functionID.UniqueKey);
    if isempty(functionNode) || ~isequal(functionNode.getParent, existingNode)
        chNodes(count) = this.createMLFBNode(functionID, dummyID, existingNode, false);
    else
        chNodes(count) = functionNode;
    end
else
    chNodes = this.findNode('Identifier', functionID.UniqueKey);
    if isempty(chNodes) || ~isequal(chNodes.getParent, mlfbTreeNode)
        chNodes = this.createMLFBNode(functionID, functionID, mlfbTreeNode, false);
    end
end
for i = 1:numel(chNodes)
    if ~chNodes(i).IsUnderMask
        this.AddedTree = [this.AddedTree chNodes(i)];
    end
end
chNodes = this.resolveMLFBHierarchy(chNodes);
end
