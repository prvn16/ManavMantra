function [mf,FG,cs,ct] = maxflow(G,s,t)
%MAXFLOW Maximum flow in an undirected graph
%   MF = MAXFLOW(G,S,T) returns the maximum flow between two nodes S and T.
%   MF is equal to zero if no flow exists between nodes S and T.
%
%   All edge weights must be non-negative. If the graph G has no weights,
%	MAXFLOW treats all edges as having weight equal to 1.
%
%   [MF,GF] = MAXFLOW(G,S,T) also returns a digraph of flows GF formed only
%   from those edges of G that have non-zero flow values.
%
%   [MF,GF,CS,CT] = MAXFLOW(G,S,T) also returns two vectors of node ids, CS
%   and CT, representing a minimum cut associated with the maximum flow.
%   A minimum cut partitions the graph nodes into two sets CS and CT,
%   such that the sum of the weights of all edges connecting CS and CT
%   (weight of the cut) is minimized.
%   The entries of CS indicate the nodes of G associated with node S.
%   The entries of CT indicate the nodes of G associated with node T.
%   The weight of the minimum cut is equal to the maximum flow value MF
%   and NUMEL(CS) + NUMEL(CT) = NUMNODES(G).
%
%   Example:
%       % Create and plot a weighted graph whose edge weights represent
%       % flow capacities. Compute the maximum flow from node 1 to node 6.
%       s = [1 1 2 2 3 4 4 4 5];
%       t = [2 3 3 4 5 3 5 6 6];
%       weights = [0.77 0.44 0.67 0.75 0.89 0.90 2 0.76 1];
%       G = graph(s,t,weights);
%       plot(G,'EdgeLabel',G.Edges.Weight)
%       mf = maxflow(G,1,6)
%
%   See also GRAPH

%   Copyright 2014-2017 The MathWorks, Inc.

if hasEdgeWeights(G)
    w = G.EdgeProperties.Weight;
else
    w = [];
end

% Create a symmetric directed graph by adding parallel edges of same weight.
if ~ismultigraph(G)
    if isempty(w)
        A = logical(adjacency(G.Underlying));
    else
        A = adjacency(G.Underlying, double(w));
    end
else
    ed = G.Underlying.Edges;
    n = numnodes(G.Underlying);
    
    if isempty(w)
        A = sparse(ed(:, 1), ed(:, 2), 1, n, n); % Treat every edge as having weight 1
    else
        A = sparse(ed(:, 1), ed(:, 2), double(w), n, n);
    end
    
    % This duplicates weights of self-loops, but self-loops are ignored anyway
    A = A + A';
end

if ~hasNodeNames(G)
    Gsym = digraph(A);
else
    Gsym = digraph(A,G.NodeProperties.Name);
end
if isa(w,'single')
    Gsym.Edges.Weight = single(Gsym.Edges.Weight);
end

if nargout <= 1
    mf = maxflow(Gsym,s,t);
elseif nargout == 2
    [mf,FG] = maxflow(Gsym,s,t);
else
    [mf,FG,cs,ct] = maxflow(Gsym,s,t);
end
