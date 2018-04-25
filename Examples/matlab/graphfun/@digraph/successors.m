function sucids = successors(G, nodeid)
%SUCCESSORS Successors of a node in a digraph
%   SUCIDS = SUCCESSORS(G, NODEID) returns the IDs of all nodes forming
%   directed edges that have the SUCIDS as their targets and the NODEID
%   as their source. SUCIDS is a column vector.
%   NODEID can be a numeric ID or a string containing a node name.
%
%   Example:
%       % Create and plot a directed graph, and then determine the
%       % successor nodes of node 'a'.
%       s = [1 1 1 2 2 3 3 7 8];
%       t = [2 3 4 5 6 7 8 5 5];
%       names = {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'};
%       G = digraph(s,t,[],names)
%       plot(G)
%       sucIDs = successors(G,'a')
%
%   See also DIGRAPH, PREDECESSORS, OUTDEGREE, GRAPH/NEIGHBORS

%   Copyright 2014-2015 The MathWorks, Inc.

id = validateNodeID(G, nodeid);
sucids = successors(G.Underlying, id);
if ~isnumeric(nodeid)
    sucids = G.Nodes.Name(sucids);
end
