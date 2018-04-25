function H = subgraph(G, ind)
%SUBGRAPH Extract a subgraph
%
%   H = subgraph(G, IND) returns graph H induced by the nodes given in
%   IND. IND can be a vector of indices or a cell array containing node
%   names. Node J in H corresponds to node IND(J) in G; edges between
%   nodes from IND are retained. The node and edge properties in G are
%   also retained in H.
%
%   H = subgraph(G, ISIN) takes the logical vector ISIN, and
%   returns a subgraph containing only nodes J for which ISIN(J) is
%   true. The index of node J in H is IND(J), where IND = find(ISIN).
%
%   Example:
%       % Create and plot a graph. Extract and plot a subgraph.
%       s = [1 1 1 1 2 2 2 2 2 2 2 2 2 2 15 15 15 15 15];
%       t = [3 5 4 2 14 6 11 12 13 10 7 9 8 15 16 17 19 18 20];
%       G = graph(s,t);
%       plot(G,'Layout','force')
%       idx = [2 15 16 17 18 19 20 1 3 4 5];
%       H = subgraph(G,idx);
%       figure, plot(H,'Layout','force')
%
%   See also GRAPH, RMNODE, REORDERNODES

%   Copyright 2014-2017 The MathWorks, Inc.

if ~isvector(ind) && ~isequal(size(ind), [0 0])
    error(message('MATLAB:graphfun:subgraph:InvalidInd'));
end
if islogical(ind)
    if isvector(ind) && length(ind) == numnodes(G)
        ind = ind(:);
    else
        error(message('MATLAB:graphfun:subgraph:InvalidInd'));
    end
else
    ind = validateNodeID(G, ind);
    if numel(unique(ind)) ~= numel(ind)
        error(message('MATLAB:graphfun:subgraph:InvalidInd'));
    end
end

edgeprop = [];
if ~ismultigraph(G)
    if size(G.EdgeProperties, 2) == 0
        N = adjacency(G.Underlying);
        N = N(ind, ind);
    else
        N = adjacency(G.Underlying, 1:numedges(G));
        N = N(ind, ind);
        edgeind = nonzeros(tril(N));
        edgeprop = G.EdgeProperties(edgeind, :);
    end
    mlg = matlab.internal.graph.MLGraph(N);
else
    perm = zeros(1, numnodes(G));
    perm(ind) = 1:nnz(ind);
    
    ed = perm(G.Underlying.Edges);
    edgeind = find(all(ed, 2));
    
    ed = ed(edgeind, :);
    ed = sort(ed, 2);
    
    if size(G.EdgeProperties, 2) > 0
        [ed, ei] = sortrows(ed);
        edgeind = edgeind(ei);
        edgeprop = G.EdgeProperties(edgeind, :);
    end
    mlg = matlab.internal.graph.MLGraph(ed(:, 1), ed(:, 2), nnz(ind));
end

H = graph(mlg, edgeprop);
H.NodeProperties = G.NodeProperties(ind, :);
