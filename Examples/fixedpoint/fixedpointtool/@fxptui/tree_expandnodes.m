function tree_expandnodes(h, nodes)
%TREE_EXPANDNODES 

%   Copyright 2011 The MathWorks, Inc.

n = length(nodes);
for i = 1:n;
  child = nodes(i);
  if(child.isHierarchical)
    h.imme.expandTreeNode(child);
    childnodes = child.getHierarchicalChildren;
    if ~isempty(childnodes)
      fxptui.tree_expandnodes(h,childnodes);
    end
  end
end

% [EOF]
