function tree_expandall(h)
%TREE_EXPANDALL

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

children = h.getRoot.getHierarchicalChildren;
h.tree_expandnodes(children);

% [EOF]