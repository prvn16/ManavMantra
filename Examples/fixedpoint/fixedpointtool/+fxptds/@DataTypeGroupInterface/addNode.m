function addNode(this, node)
    % ADDNODE function adds a node in the graph infrastructure of the data
    % type group interface
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    % the keys of the map are the unique identifiers of the nodes
    % (AbstractResult)
    nodeKey = node.UniqueIdentifier.UniqueKey;
    
    % if the node has not been registered before, register the node
    if ~this.nodes.isKey(nodeKey)
        this.nodes(nodeKey) = node;
    end
end