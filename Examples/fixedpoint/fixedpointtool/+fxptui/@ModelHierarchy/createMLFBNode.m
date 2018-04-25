function node = createMLFBNode(this, functionID, parentID, parentNode, isDummyID)
% CREATEMLFBNODE Creates a tree node that represents a MATLAB Function

% Copyright 2017 The MathWorks, Inc.

blkObject = functionID.BlockIdentifier.getObject;
[mlClass, mlIcon] = fxptui.ModelHierarchy.getIconClassForMATLABFunction;
node = fxptui.TreeNodeData;
node.Object = functionID;
node.Name = fxptui.removeLineBreaksFromName(functionID.getDisplayName);  
node.MATLABIDForHighlight = functionID.UniqueKey;
node.Class = mlClass;
node.IconClass = mlIcon;
node.IsWithinStateflow = true;
node.ItemFullyLoaded = true; 

if isDummyID
    dummyPath = fxptui.removeLineBreaksFromName([blkObject.getFullName '/' functionID.getDisplayName]);
    dummyIdentifier = sprintf('%s_%s',dummyPath ,'dummy');   
    displayPath = fxptui.ModelHierarchy.getDisplayPathForClient(functionID.BlockIdentifier.getDisplayName);
    node.DisplayPath = fxptui.removeLineBreaksFromName([displayPath '/' functionID.getDisplayName]);    
    node.Path = dummyPath;
    % The Identifier & id property on the tree nodes have to be unique
    % for them to be identified correctly. For codeview to be brough up
    % correctly on the dummy MLFB node, update the MATLABIDForHighlight
    % property to be the UniqueKey of the dummyID object (functionID
    % with instance count set to 1)
    node.Identifier = dummyIdentifier;   
    node.ParentIdentifier = functionID.BlockIdentifier.UniqueKey;
    node.HasChildren = true;       
    node.IsWithinStateflow = true;
    node.Model = this.getModelNameFromPath(blkObject.getFullName);
    node.ChartIdentifier = functionID.BlockIdentifier.UniqueKey;
    [isUnderMask, parent] = fxptui.isUnderMaskedSubsystem(blkObject);
    node.IsUnderMask = isUnderMask;
    node.MaskedParent = parent;   
else   
    displayPath = fxptui.ModelHierarchy.getDisplayPathForClient(parentID.BlockIdentifier.getDisplayName);
    node.DisplayPath = fxptui.removeLineBreaksFromName(sprintf('%s/%s',displayPath, functionID.getDisplayName));    
    node.Path = fxptui.removeLineBreaksFromName(sprintf('%s/%s',parentID.BlockIdentifier.getObject.getFullName,...
                                                      functionID.getDisplayName));    
    node.Identifier = functionID.UniqueKey;
    node.ParentIdentifier = parentNode.Identifier;
    node.IsUnderMask = parentNode.IsUnderMask;
    node.HasChildren = false;     
    node.Model = this.getModelNameFromPath(parentID.BlockIdentifier.getObject.getFullName);
    node.ChartIdentifier = parentID.BlockIdentifier.UniqueKey;
    node.MaskedParent = parentNode.MaskedParent;   
end
parentNode.addChildren(node);
