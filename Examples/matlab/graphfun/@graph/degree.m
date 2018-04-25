function d = degree(G, nodeids)
%DEGREE Degree of nodes in a graph
%
%   D = DEGREE(G) returns the degree of each node of G, in a column vector.
%
%   D = DEGREE(G, NODEIDS) returns the degree of the nodes specified by
%   NODEIDS. NODEIDS can be a numeric array containing node IDs or a cell
%   array of strings containing node names.
%   D has the same dimensions as NODEIDS.
%
%   Example:
%       % Create a graph, and then compute the degree of its nodes.
%       s = [1 1 1 4 4 6 6 6];
%       t = [2 3 4 5 6 7 8 9];
%       G = graph(s,t);
%       d = degree(G)
%
%   Example:
%       % Create a graph, and then compute the degree of a subset of nodes.
%       s = {'a' 'a' 'a' 'd' 'd' 'f' 'f' 'f'};
%       t = {'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i'};
%       G = graph(s,t)
%       nodeIDs = {'a' 'c' 'e'}';
%       d = degree(G,nodeIDs)
%
%   See also GRAPH, NEIGHBORS, DIGRAPH/INDEGREE, DIGRAPH/OUTDEGREE

%   Copyright 2014-2015 The MathWorks, Inc.

if nargin==1
    d = degree(G.Underlying);
else
    if ischar(nodeids)
        nodeids = {nodeids};
    end
    ids = validateNodeID(G, nodeids);
    d = degree(G.Underlying, reshape(ids, size(nodeids)));
end
