function addNodeToTree(h, sysObj)
%ADDNODETOTREE Adds and populates a node for the specfied system in the tree hierarchy.

%   Copyright 2012 MathWorks, Inc.

% At this point we are only going to be adding models to the tree hierarchy
% with this method and so is very restricted.
if ~isa(sysObj,'Simulink.BlockDiagram')
    return; 
end

% Get the explorer root and add the block diagram to it.
parentNode = h.getRoot;
mdlNode = find(parentNode,'daobject',sysObj,'-isa','fxptui.BAESubMdlNode'); %#ok<GTARG>
if isempty(mdlNode)
    parentNode.addChild(sysObj);
end

% Update the tree view
parentNode.firehierarchychanged;



% [EOF]
