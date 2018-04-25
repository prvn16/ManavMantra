function tree_expandall(h)
%TREE_EXPANDALL Expands all tree nodes in the selected explorer

%   Copyright 2011 The MathWorks, Inc.

children = h.getRoot.getHierarchicalChildren;
fxptui.tree_expandnodes(h,children);


% [EOF]
