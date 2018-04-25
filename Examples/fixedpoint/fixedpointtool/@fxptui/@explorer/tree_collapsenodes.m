function tree_collapsenodes(h, nodes)
%TREE_COLLAPSENODES   

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
    h.imme.collapseTreeNode(udd_child);
    childnodes = child.getChildren;
    if(length(childnodes) > 0)
      h.tree_collapsenodes(childnodes);
    end
  end
end

% [EOF]