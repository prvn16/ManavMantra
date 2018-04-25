function preids = predecessors(G, nodeid)
%PREDECESSORS Predecessors of a node in a digraph
%   PREIDS = PREDECESSORS(G, NODEID) returns the IDs of all nodes forming
%   directed edges that have the PREIDS as their sources and the NODEID
%   as their target. PREIDS is a column vector.
%   NODEID can be a numeric ID or a string containing a node name.
%
%   Example:
%       % Create and plot a directed graph, and then determine the
%       % predecessor nodes of node 'e'.
%       s = [1 1 1 2 2 3 3 7 8];
%       t = [2 3 4 5 6 7 8 5 5];
%       names = {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'};
%       G = digraph(s,t,[],names)
%       plot(G)
%       preIDs = predecessors(G,'e')
%
%   See also DIGRAPH, SUCCESSORS, INDEGREE, GRAPH/NEIGHBORS

%   Copyright 2014-2017 The MathWorks, Inc.

id = validateNodeID(G, nodeid);
preids = predecessors(G.Underlying, id);
if ~isnumeric(nodeid)
    preids = G.Nodes.Name(preids);
end
