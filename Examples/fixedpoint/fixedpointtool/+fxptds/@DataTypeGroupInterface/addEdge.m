function addEdge(this, nodeA, nodeB)
   % ADDEDGE this function adds an edge in the internal group infrastructure 
   % of the data type group interface
   
   % Copyright 2016 The MathWorks, Inc.
   
   % an edge consists of two nodes. We register the edge making sure that
   % the nodes are lexicographically sorted to make comparison of edges
   % easier
   sortedNodes = sort({nodeA, nodeB});
   
   % use a delimiter for readability of the edges and debugging
   keyForMap = [sortedNodes{1} '-' sortedNodes{2}];
   
   if ~this.edges.isKey(keyForMap)
      this.edges(keyForMap) = sortedNodes; 
   end
end