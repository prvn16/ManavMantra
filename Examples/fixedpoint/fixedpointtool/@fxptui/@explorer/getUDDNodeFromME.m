function uddNode = getUDDNodeFromME(this, mcosNode)
% GETUDDNODEFROMME Gets the UDD node from the model explorer tree that wraps the MCOS tree node

% Copyright 2013 MathWorks, Inc

uddRoot = this.getRoot;
uddNode = getUDDNode(uddRoot, mcosNode);
end

function node = getUDDNode(uddChild, mcosNode)
node = [];
uddChildren = uddChild.getHierarchicalChildren;
for i = 1:length(uddChildren)
    mcosObj = uddChildren(i).getMCOSObjectReference;
    if isequal(mcosObj, mcosNode)
        node = uddChildren(i);
        return;
    end
    node = getUDDNode(uddChildren(i), mcosNode);
    if ~isempty(node); break; end
end
end
