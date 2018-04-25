function tree_expandnodes(h, nodes)
%TREE_EXPANDNODES   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

n = length(nodes);
for i = 1:n;
  child = nodes(i);
  if ~isa(child,'DAStudio.DAObjectProxy')
      udd_child = h.getUDDNodeFromME(child);
  else
      udd_child = child;
  end
  if(child.isHierarchical)
    h.imme.expandTreeNode(udd_child);
    childnodes = child.getHierarchicalChildren;
    if(length(childnodes) > 0)
      h.tree_expandnodes(childnodes);
    end
  end
end

% [EOF]