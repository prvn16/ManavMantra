function listNode = getSelectedListNodes(h)
% Return the MCOS object currently selected in the list view

% Copyright 2013 MathWorks, Inc

listNode = [];
udd_proxy_node = h.imme.getSelectedListNodes;
if ~isempty(udd_proxy_node) && isa(udd_proxy_node,'DAStudio.DAObjectProxy')
    listNode = udd_proxy_node.getMCOSObjectReference;
end
