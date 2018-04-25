function H = transclosure(G)
%TRANSCLOSURE Transitive closure
%
%   H = transclosure(G) returns a digraph H, containing the same nodes as
%   G, and additional edges: If there is a path from node i to node j in G,
%   there is an edge from node i to node j in H.
%
%   The table G.Nodes is copied to H, while the properties in G.Edges are
%   dropped.
%
%   Example:
%       % Create and plot a digraph, then compute its transitive closure.
%       G = digraph([1 2 3 4 4 4 5 5 5 6 7 8],[2 3 5 1 3 6 6 7 8 9 9 9]);
%       plot(G)
%       H = transclosure(G);
%       figure, plot(H)
%
%   See also TRANSREDUCTION, CONNCOMP.

%   Copyright 2014-2016 The MathWorks, Inc.

[bins, nrbins] = connectedComponents(G.Underlying);

edges = bins(G.Underlying.Edges);
edges(edges(:, 1) == edges(:, 2), :) = [];
M = sparse(edges(:, 2), edges(:, 1), 1, nrbins, nrbins);

cond = matlab.internal.graph.MLDigraph(M, 'transp');

Mcond = transitiveClosureDAG(cond);

Mnew = Mcond(bins, bins);

% Remove self-loop from all nodes that are not part of a cycle:
scalarComponents = accumarray(bins', 1) == 1;
scalarCompNodes = find(scalarComponents(bins));
Mnew(sub2ind(size(Mnew), scalarCompNodes, scalarCompNodes)) = 0;

H = digraph(matlab.internal.graph.MLDigraph(Mnew, 'transp'));
H.NodeProperties = G.NodeProperties;
