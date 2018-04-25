function addNodeToTree(h, sysObj)
%ADDNODETOTREE Adds and populates a node for the specfied system in the tree hierarchy.

%   Copyright 2012 MathWorks, Inc.

% At this point we are only going to be adding models to the tree hierarchy
% with this method and so is very restricted.
if ~isa(sysObj,'Simulink.BlockDiagram')
    return; 
end

% Get the explorer root and add the block diagram to it.
parentNode = h.getFPTRoot;
childNodes = parentNode.getModelNodes;
mdlNode = findobj(childNodes,'DAObject',sysObj,'-isa','fxptui.ModelNode');
if isempty(mdlNode)
    parentNode.populate(sysObj);
end

% update the BAExplorer tree as well
bae = fxptui.BAExplorer.getBAExplorer;
if ~isempty(bae)
    addNodeToTree(bae,sysObj);
    hDlg = bae.getDialog;
    bae.loadShortcut(hDlg);
end

% Update the tree view
parentNode.fireHierarchyChanged;





