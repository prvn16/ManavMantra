function H = rmnode(G, N)
%RMNODE Remove nodes from a graph
%   H = RMNODE(G, nodeID) returns a graph H equivalent to G with nodes
%   specified by the string (or cell array of strings) or numeric IDs
%   nodeID removed from it.  All edges in G incident upon the nodes to be
%   removed are also removed.
%
%   Example:
%       % Create and plot a graph. Remove node 'C', and then plot the new
%       % graph.
%       s = {'A' 'A' 'B' 'C' 'D' 'B' 'C' 'B'};
%       t = {'B' 'C' 'C' 'D' 'A' 'E' 'E' 'D'};
%       G = graph(s,t)
%       plot(G)
%       G = rmnode(G,'C')
%       figure, plot(G)
%
%   See also GRAPH, NUMNODES, ADDNODE, RMEDGE

%   Copyright 2014-2017 The MathWorks, Inc.

ind = findnode(G, N);
ind(ind == 0) = [];

keepNode = true(numnodes(G), 1);
keepNode(ind) = false;

if ~ismultigraph(G)
    if size(G.EdgeProperties, 2) == 0
        N = adjacency(G.Underlying);
        N = N(keepNode, keepNode);
        mlg = matlab.internal.graph.MLGraph(N);
        edgeprop = [];
    else
        N = adjacency(G.Underlying, 1:numedges(G));
        N = N(keepNode, keepNode);
        mlg = matlab.internal.graph.MLGraph(N);
        edgeind = nonzeros(tril(N));
        edgeprop = G.EdgeProperties(edgeind, :);
    end
else
    % Determine mapping from old to new node indices
    perm = zeros(1, numnodes(G));
    perm(keepNode) = 1:nnz(keepNode);
    
    % Determine which edges are kept
    ed = perm(G.Underlying.Edges);
    edgeind = all(ed > 0, 2);
    
    mlg = matlab.internal.graph.MLGraph(ed(edgeind, 1), ed(edgeind, 2), nnz(keepNode));
    edgeprop = G.EdgeProperties(edgeind, :);
end

H = graph(mlg, edgeprop);
H.NodeProperties = G.NodeProperties(keepNode, :);

if nargout < 1
    warning(message('MATLAB:graphfun:rmnode:NoOutput'));
end
