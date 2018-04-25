function [edgeid, n] = outedges(G, nodeid)
%OUTEDGES Outgoing edges of a node in a digraph
%   EID = OUTEDGES(G, NODEID) returns the IDs of all outgoing edges from
%   node NODEID. EID is a column vector of indices into the edge table,
%   G.Edges(EID,:). NODEID can be a numeric node ID or a string containing
%   a node name.
%
%   [EID, NID] = OUTEDGES(G, NODEID) additionally returns the successor
%   nodes NID that are connected to NODEID by the edges EID. If there are
%   several edges connecting NODEID to the same node, it appears in vector
%   NID several times.
%
%   Example:
%       % Create and plot a directed graph, and then determine the
%       % outgoing edges of node 'a'.
%       s = [1 1 1 2 2 3 3 7 8];
%       t = [2 3 4 5 6 7 8 5 5];
%       names = {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'};
%       G = digraph(s,t,[],names)
%       plot(G)
%       [eid, nid] = outedges(G,'a')
%
%   See also DIGRAPH, INEDGES, SUCCESSORS, PREDECESSORS, GRAPH/OUTEDGES

%   Copyright 2017 The MathWorks, Inc.

id = validateNodeID(G, nodeid);

[edgeid, n] = outedges(G.Underlying, id);

if nargout > 1 && ~isnumeric(nodeid)
    n = G.Nodes.Name(n);
end
