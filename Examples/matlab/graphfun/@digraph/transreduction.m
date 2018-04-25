function H = transreduction(G)
%TRANSREDUCTION Transitive reduction
%
%   H = transreduction(G) returns a digraph H, containing the same nodes as
%   G, and different edges: H has the minimal number of edges such that,
%   if there is a path from node i to node j in G, there is also a path 
%   from node i to node j in H.
%   While the number of edges in H is less than or equal the number of
%   edges in G, H may contain an edge that was not in G.
%
%   The transitive reduction of a digraph is not typically unique. If two
%   digraphs G1 and G2 have the same reachability, TRANSREDUCTION returns
%   the same H for both.
%
%   The table G.Nodes is copied to H, while the properties in G.Edges are
%   dropped.
%
%   Example:
%       % Create and plot a digraph, then compute its transitive reduction.
%       G = digraph([1 1 1 1 2 3 3 4], [2 3 4 5 4 4 5 5]);
%       plot(G)
%       H = transreduction(G);
%       figure, plot(H)
%
%   See also TRANSCLOSURE, CONNCOMP.

%   Copyright 2014-2016 The MathWorks, Inc.

[bins, nrbins] = connectedComponents(G.Underlying);

% Permute nodes by bin numbers
[tmp, ind] = sort(bins);
start_block = find(diff([0 tmp]));
end_block = [start_block(2:end)-1, numel(bins)];

% For every connected component, construct cycle connecting all nodes
%   Construct sparse matrix: edges (1, 2), (2, 3), ..., (nr_comp, nr_comp+1)
nn = numnodes(G);
I = 1:nn;
J = 2:nn+1;

%   For every edge moving between components: redirect to start of component:
if ~isempty(start_block)
    J(end_block) = start_block;
end

%   Components of size 1 result in diagonal entries, remove these here:
diag_entries = (I == J);
I = I(~diag_entries);
J = J(~diag_entries);

% Compute edges between connected components by constructing condensation
edges = bins(G.Underlying.Edges);
edges(edges(:, 1) == edges(:, 2), :) = [];
M = sparse(edges(:, 2), edges(:, 1), 1, nrbins, nrbins);

cond = matlab.internal.graph.MLDigraph(M, 'transp');

Mcond = transitiveReductionDAG(cond);
[Jcond, Icond] = find(Mcond);

% If there is an edge from component i to component j, connect first node of i to first node of j:
I_ = start_block(Icond);
J_ = start_block(Jcond);

% Construct adjacency matrix
Mnew = sparse(ind([J(:); J_(:)]), ind([I(:); I_(:)]), ones(numel(I)+numel(I_), 1), nn, nn);

H = digraph(matlab.internal.graph.MLDigraph(Mnew, 'transp'));
H.NodeProperties = G.NodeProperties;