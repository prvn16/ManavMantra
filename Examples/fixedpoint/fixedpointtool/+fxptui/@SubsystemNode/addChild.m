function child = addChild(this, blkObj)
% ADDCHILD Adds the simulink component to the node hierarchy 

% Copyright 2013-2014 The MathWorks, Inc.
    
    child = fxptui.createNode(blkObj);
    this.ChildrenMap.insert(child.getKeyAsDoubleType, child);
    % Connects the parent and child nodes in the MCOS tree
    % hierarchy
    this.addChildren(child);
end
