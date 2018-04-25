function node = createNode(this, sysObj)
% CREATENODE Creates the node object for a given system

% Copyright 2017 The MathWorks, Inc.

uniqueID = this.getIdentifierObject(sysObj);
node = fxptui.TreeNodeData;
node.Object = sysObj;
node.Identifier = uniqueID.UniqueKey;
node.Name = fxptui.removeLineBreaksFromName(sysObj.getDisplayLabel);

displayPath = fxptui.ModelHierarchy.getDisplayPathForClient(uniqueID.getDisplayName);
node.DisplayPath = fxptui.removeLineBreaksFromName(displayPath);
                    
node.Path = fxptui.removeLineBreaksFromName(sysObj.getFullName);
node.ParentIdentifier = this.getParentIdentifier(sysObj);
node.Class = class(sysObj);
node.IconClass = fxptui.ModelHierarchy.getIconClass(sysObj);
node.ItemFullyLoaded = false;
node.HasChildren = false;
node.IsWithinStateflow = node.isWithinStateflowParent;
[isUnderMask, parent] = fxptui.isUnderMaskedSubsystem(sysObj);
node.IsUnderMask = isUnderMask;
node.MaskedParent = parent;
node.Model = this.getModelNameFromPath(sysObj.getFullName);

% Add the relationship to the map
this.ChildParentMap(node.Identifier) = node.ParentIdentifier;
end
