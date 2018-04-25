function c = condensation(g)
%CONDENSATION Graph condensation
%   C = CONDENSATION(G) returns the condensation of digraph G such that
%   each node of digraph C represents a strongly connected component of G.
%   There is an edge (I,J) in C if there is an edge from any node in
%   component I to any node in component J of G. C is acyclic and
%   topologically sorted.
%
%   See also: CONNCOMP, BCTREE

%   Copyright 2016-2017 The MathWorks, Inc.

[bins, nrbins] = connectedComponents(g.Underlying);
% bins is in reverse topological order, revert again:
bins = nrbins - bins + 1;

edges = bins(g.Underlying.Edges);
edges(edges(:, 1) == edges(:, 2), :) = [];
M = sparse(edges(:, 2), edges(:, 1), 1, nrbins, nrbins);

c = digraph(matlab.internal.graph.MLDigraph(M, 'transp'));

