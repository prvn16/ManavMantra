function H = rmnode(G, N)
%RMNODE Remove nodes from a digraph
%   H = RMNODE(G, NodeID) returns a digraph H equivalent to G with nodes
%   specified by the string (or cell array of strings) or numeric IDs
%   NodeID removed from it.  All edges in G incident upon the nodes to be
%   removed are also removed.
%
%   Example:
%       % Create and plot a digraph. Remove node 'C', and then plot the new
%       % digraph.
%       s = {'A' 'A' 'B' 'C' 'D' 'B' 'C' 'B'};
%       t = {'B' 'C' 'C' 'D' 'A' 'E' 'E' 'D'};
%       G = digraph(s,t)
%       plot(G)
%       G = rmnode(G,'C')
%       figure, plot(G)
%
%   See also DIGRAPH, NUMNODES, ADDNODE, RMEDGE

%   Copyright 2014-2017 The MathWorks, Inc.

ind = findnode(G, N);
ind(ind == 0) = [];

keepNode = true(numnodes(G), 1);
keepNode(ind) = false;

if ~ismultigraph(G)
    if size(G.EdgeProperties, 2) == 0
        N = adjacency(G.Underlying, 'transp');
        N = N(keepNode, keepNode);
        mlg = matlab.internal.graph.MLDigraph(N, 'transp');
        edgeprop = [];
    else
        N = adjacency(G.Underlying, 1:numedges(G), 'transp');
        N = N(keepNode, keepNode);
        mlg = matlab.internal.graph.MLDigraph(N, 'transp');
        edgeind = nonzeros(N);
        edgeprop = G.EdgeProperties(edgeind, :);
    end
else
    % Determine mapping from old to new node indices
    perm = zeros(1, numnodes(G));
    perm(keepNode) = 1:nnz(keepNode);
    
    % Determine which edges are kept
    ed = perm(G.Underlying.Edges);
    edgeind = all(ed > 0, 2);
    
    mlg = matlab.internal.graph.MLDigraph(ed(edgeind, 1), ed(edgeind, 2), nnz(keepNode));
    edgeprop = G.EdgeProperties(edgeind, :);
end

H = digraph(mlg, edgeprop);
H.NodeProperties = G.NodeProperties(keepNode, :);

if nargout < 1
    warning(message('MATLAB:graphfun:rmnode:NoOutput'));
end
