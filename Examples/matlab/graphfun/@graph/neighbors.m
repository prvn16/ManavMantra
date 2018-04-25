function n = neighbors(G, nodeid)
%NEIGHBORS Neighbors of a node in a graph
%   N = NEIGHBORS(G, NODEID) returns the IDs of all nodes connected by
%   an edge to the node specified by NODEID. N is a column vector.
%   NODEID can be a numeric ID or a string containing a node name.
%
%   Example:
%       % Create and plot a graph. Compute the neighbors of node 10.
%       G = graph(bucky);
%       plot(G)
%       n = neighbors(G,10)
%
%   See also GRAPH, DEGREE, DIGRAPH/SUCCESSORS, DIGRAPH/PREDECESSORS

%   Copyright 2014-2015 The MathWorks, Inc.

id = validateNodeID(G, nodeid);
n = neighbors(G.Underlying, id);
if ~isnumeric(nodeid)
    n = G.Nodes.Name(n);
end
