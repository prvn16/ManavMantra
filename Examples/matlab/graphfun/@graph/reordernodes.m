function [H, edgeind] = reordernodes(G, order)
%REORDERNODES Reorder nodes
%
%   H = reordernodes(G, ORDER) returns a graph H with the nodes reordered
%   as defined in ORDER. This corresponds to a symmetric permutation of
%   the adjacency matrix of G.  That is, if A = adjacency(G), then
%   isequal(adjacency(H), A(order, order)) evaluates to true.
%
%   [H, IND] = reordernodes(G, ORDER) additionally returns the permutation
%   vector for the edge indices. For example, if G.Edges has a variable
%   Weight, then H.Edges.Weight == G.Edges.Weight(IND).
%
%   ORDER may be a vector of indices, or a cell array of node names.
%
%   NodeProperties and EdgeProperties of G are carried over to H.
%
%   Example:
%       % Create and plot a graph. Reorder the nodes in order of descending
%       % degree and plot the reordered graph.
%       s = [1 1 1 2 2 2 2 3 4];
%       t = [3 4 2 3 4 5 6 5 6];
%       G = graph(s,t);
%       plot(G)
%       [~,order] = sort(degree(G),'descend')
%       H = reordernodes(G,order);
%       figure, plot(H)
%
%   See also GRAPH, SUBGRAPH

%   Copyright 2014-2017 The MathWorks, Inc.

if ~isvector(order)
    error(message('MATLAB:graphfun:reordernodes:InvalidOrder'));
end
order = validateNodeID(G, order);
if numel(order) ~= numnodes(G) || numel(unique(order)) ~= numel(order)
    error(message('MATLAB:graphfun:reordernodes:InvalidOrder'));
end

edgeprop = [];
if ~ismultigraph(G)
    if size(G.EdgeProperties, 2) == 0 && nargout <= 1
        N = adjacency(G.Underlying);
        N = N(order, order);
    else
        N = adjacency(G.Underlying, 1:numedges(G));
        N = N(order, order);
        edgeind = nonzeros(tril(N));
        edgeprop = G.EdgeProperties(edgeind, :);
    end
    mlg = matlab.internal.graph.MLGraph(N);
else
    invorder(order) = 1:numnodes(G);
    ed = invorder(G.Underlying.Edges);
    ed = sort(ed, 2);
    
    if size(G.EdgeProperties, 2) > 0 || nargout > 1
        [ed, edgeind] = sortrows(ed);
        edgeprop = G.EdgeProperties(edgeind, :);
    end
    mlg = matlab.internal.graph.MLGraph(ed(:, 1), ed(:, 2), numnodes(G));
end

H = graph(mlg, edgeprop);
H.NodeProperties = G.NodeProperties(order, :);
