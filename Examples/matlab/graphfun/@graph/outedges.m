function [edgeid, n] = outedges(G, nodeid)
%OUTEDGES Edges connected to a node in a graph
%   EID = OUTEDGES(G, NODEID) returns the IDs of all edges connected to the
%   node NODEID. EID is a column vector of indices into the edge table,
%   G.Edges(EID,:). NODEID can be a numeric node ID or a string containing
%   a node name.
%
%   [EID, NID] = OUTEDGES(G, NODEID) additionally returns the neighboring
%   nodes NID that are connected to NODEID by the edges EID. If there are
%   several edges connecting NODEID to the same node, it appears in vector
%   NID several times.
%
%   Example:
%       % Create and plot a graph, and then determine the edges connected
%       % to node 10.
%       G = graph(bucky);
%       plot(G)
%       [eid,nid] = outedges(G,10)
%
%   See also GRAPH, NEIGHBORS, DEGREE, DIGRAPH/OUTEDGES, DIGRAPH/INEDGES

%   Copyright 2017 The MathWorks, Inc.

id = validateNodeID(G, nodeid);

[edgeid, n] = outedges(G.Underlying, id);

if nargout > 1 && ~isnumeric(nodeid)
    n = G.Nodes.Name(n);
end
