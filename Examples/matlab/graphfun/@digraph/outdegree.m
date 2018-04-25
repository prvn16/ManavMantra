function d = outdegree(G, nodeids)
%OUTDEGREE Out-degree of nodes in a digraph
%
%   D = OUTDEGREE(G) returns the out-degree of each node of G, in a column
%   vector.
%
%   D = OUTDEGREE(G, NODEIDS) returns the out-degree of the nodes specified
%   by NODEIDS. NODEIDS can be a numeric array containing node IDs or a
%   cell array of strings containing node names.
%   D has the same dimensions as NODEIDS.
%
%   Example:
%       % Create a digraph. Compute the out-degree of its nodes.
%       s = [1 3 2 2 4 5 1 2];
%       t = [2 2 4 5 6 6 6 6];
%       G = digraph(s,t)
%       outdeg = outdegree(G)
%
%   Example:
%       % Create a digraph. Compute the out-degree of a subset of nodes.
%       s = {'a' 'c' 'b' 'b' 'd' 'e' 'a' 'b'};
%       t = {'b' 'b' 'd' 'e' 'f' 'f' 'f' 'f'};
%       G = digraph(s,t)
%       nodeID = {'a' 'b' 'f'}';
%       outdeg = outdegree(G,nodeID)
%
%   See also DIGRAPH, INDEGREE, SUCCESSORS, GRAPH/DEGREE

%   Copyright 2014-2015 The MathWorks, Inc.

if nargin == 1
    d = outdegree(G.Underlying);
else
    if ischar(nodeids)
        nodeids = {nodeids};
    end
    ids = validateNodeID(G, nodeids);
    d = outdegree(G.Underlying, reshape(ids, size(nodeids)));
end
