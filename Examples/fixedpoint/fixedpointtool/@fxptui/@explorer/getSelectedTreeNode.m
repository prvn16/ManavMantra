function treeNode = getSelectedTreeNode(this)
% Return the MCOS object currently selected in the tree view

% Copyright 2013 MathWorks, Inc

treeNode = [];
udd_proxy_node = this.getTreeSelection;
if ~isempty(udd_proxy_node) && isa(udd_proxy_node,'DAStudio.DAObjectProxy')
    treeNode = udd_proxy_node.getMCOSObjectReference;
end
