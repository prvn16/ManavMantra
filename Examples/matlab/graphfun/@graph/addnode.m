function H = addnode(G, N)
%ADDNODE Add nodes to a graph
%   H = ADDNODE(G,nodeIDs) returns graph H that is equivalent to G but
%   with nodes specified by the string (or cell array of strings) nodeIDs
%   added to it. nodeIDs must specify nodes not already present in G.
%
%   H = ADDNODE(G,N) returns graph H that is equivalent to G but with N
%   nodes added.  N must be a nonnegative numeric scalar.
%
%   H = ADDNODE(G,NodeProps) returns graph H that is equivalent to G but
%   with as many nodes as there are rows in the table NodeProps added to
%   it.  NodeProps must be able to be concatenated with G.Nodes.
%
%   Example:
%       % Construct a graph with named nodes, then add two named nodes.
%       G = graph({'A' 'B' 'C'},{'D' 'C' 'D'})
%       G.Nodes
%       G = addnode(G,{'E' 'F'})
%       G.Nodes
%
%   Example:
%       % Construct a graph with four nodes, then add two nodes.
%       G = graph([1 2 3],[2 3 4])
%       G = addnode(G,2)
%
%   See also GRAPH, NUMNODES, RMNODE, ADDEDGE

%   Copyright 2014-2017 The MathWorks, Inc.

H = G;
[H.NodeProperties, newnodes] = addToNodeProperties(G, N);

if newnodes > 0
    nrNodes = size(H.NodeProperties, 1);
    if ~ismultigraph(H)
        A = adjacency(H.Underlying);
        A(nrNodes, nrNodes) = 0;
        H.Underlying = matlab.internal.graph.MLGraph(A);
    else
        ed = H.Underlying.Edges;
        H.Underlying = matlab.internal.graph.MLGraph(ed(:, 1), ed(:, 2), nrNodes);
    end
end

if nargout < 1
    warning(message('MATLAB:graphfun:addnode:NoOutput'));
end
