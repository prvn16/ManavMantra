function d = indegree(G, nodeids)
%INDEGREE In-degree of nodes in a digraph
%
%   D = INDEGREE(G) returns the in-degree of each node of G, in a column
%   vector.
%
%   D = INDEGREE(G, NODEIDS) returns the in-degree of the nodes specified
%   by NODEIDS. NODEIDS can be a numeric array containing node IDs or a
%   cell array of strings containing node names.
%   D has the same dimensions as NODEIDS.
%
%   Example:
%       % Create a digraph. Compute the in-degree of its nodes.
%       s = [1 3 2 2 4 5 1 2];
%       t = [2 2 4 5 6 6 6 6];
%       G = digraph(s,t)
%       indeg = indegree(G)
%
%   Example:
%       % Create a digraph. Compute the in-degree of a subset of nodes.
%       s = {'a' 'c' 'b' 'b' 'd' 'e' 'a' 'b'};
%       t = {'b' 'b' 'd' 'e' 'f' 'f' 'f' 'f'};
%       G = digraph(s,t)
%       nodeID = {'a' 'b' 'f'}';
%       indeg = indegree(G,nodeID)
%
%   See also DIGRAPH, OUTDEGREE, PREDECESSORS, GRAPH/DEGREE

%   Copyright 2014-2015 The MathWorks, Inc.

if nargin == 1
    d = indegree(G.Underlying);
else
    if ischar(nodeids)
        nodeids = {nodeids};
    end
    ids = validateNodeID(G, nodeids);
    d = indegree(G.Underlying, reshape(ids, size(nodeids)));
end
