function blkDgmNodes = getBlkDgmNodes(h)
%GETTOPNODE Get the top node, could be top model or model FPT launched from
%   OUT = GETAPPDATA(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.

rootNode = h.getFPTRoot;

if isa(rootNode, 'fxptui.ExplorerRoot')
    blkDgmNodes = rootNode.getHierarchicalChildren;
else
    % isa(rootNode, 'fxptui.blkdgmnode')
    blkDgmNodes = rootNode;
end

% should assert of any other kinds of nodes were found 

% [EOF]
