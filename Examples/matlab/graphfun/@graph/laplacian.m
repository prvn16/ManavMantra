function L = laplacian(G)
%LAPLACIAN Graph Laplacian matrix
%   L = LAPLACIAN(G) returns the graph Laplacian matrix. L is a sparse
%   matrix of size numnodes(G)-by-numnodes(G). The diagonal entries of L
%   are given by the degree of the nodes, L(j,j) = degree(G,j). The
%   off-diagonal entries of L are defined as L(i,j) = L(j,i) = -1 if G has
%   an edge between nodes i and j; otherwise, L(i,j) = L(j,i) = 0.
%   G must be a simple graph with no self-loops.
%
%   Example:
%       % Create a graph, and then compute the graph Laplacian matrix.
%       s = [1 1 1 1 1];
%       t = [2 3 4 5 6];
%       G = graph(s,t)
%       L = laplacian(G)
%
%   See also GRAPH, INCIDENCE

%   Copyright 2014-2017 The MathWorks, Inc.

if ismultigraph(G.Underlying)
    error(message('MATLAB:graphfun:laplacian:Multigraph'));
end
if hasSelfLoops(G.Underlying)
    error(message('MATLAB:graphfun:laplacian:SelfLoops'));
end

% Construct Laplacian matrix as degree matrix - adjacency matrix
nn = numnodes(G);
L = spdiags(degree(G.Underlying,1:nn).',0,nn,nn) - adjacency(G.Underlying);
