function [edgeid, n] = inedges(G, nodeid)
%INEDGES Incoming edges of a node in a digraph
%   EID = INEDGES(G, NODEID) returns the IDs of all incoming edges from
%   node NODEID. EID is a column vector of indices into the edge table,
%   G.Edges(EID,:). NODEID can be a numeric node ID or a string containing
%   a node name.
%
%   [EID, NID] = INEDGES(G, NODEID) additionally returns the predecessor
%   nodes NID that are connected to NODEID by the edges EID. If there are
%   several edges connecting NODEID to the same node, it appears in vector
%   NID several times.
%
%   Example:
%       % Create and plot a directed graph, and then determine the
%       % incoming edges of node 'e'.
%       s = [1 1 1 2 2 3 3 7 8];
%       t = [2 3 4 5 6 7 8 5 5];
%       names = {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'};
%       G = digraph(s,t,[],names)
%       plot(G)
%       [eid, nid] = inedges(G,'e')
%
%   See also DIGRAPH, OUTEDGES, PREDECESSORS, SUCCESSORS, GRAPH/OUTEDGES

%   Copyright 2017 The MathWorks, Inc.

id = validateNodeID(G, nodeid);

[edgeid, n] = inedges(G.Underlying, id);

if nargout > 1 && ~isnumeric(nodeid)
    n = G.Nodes.Name(n);
end
