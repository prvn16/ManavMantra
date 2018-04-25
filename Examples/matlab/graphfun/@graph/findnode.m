function ind = findnode(G, N)
%FINDNODE Determine node ID given a name
%   ind = FINDNODE(G, nodeID) returns the numeric nodeID of the node with
%   name nodeID.  nodeID may be a cell array of strings specifying many
%   node names.  If there is no node corresponding to nodeID in G, ind is
%   zero.
%
%   Example:
%       % Create a graph, and then find the numeric indices for two
%       % node names.
%       s = {'AA' 'AA' 'AA' 'AB' 'AC' 'BB'};
%       t = {'BA' 'BB' 'BC' 'BA' 'AB' 'BC'};
%       G = graph(s,t);
%       G.Nodes
%       k = findnode(G,{'AB' 'BC'})
%
%   See also GRAPH, NUMNODES, FINDEDGE

%   Copyright 2014-2015 The MathWorks, Inc.

if graph.isvalidstring(N)
    if ~iscellstr(N), N = {N}; end
    if ~hasNodeNames(G)
        error(message('MATLAB:graphfun:findnode:NoNames'));
    end
    [~,ind] = ismember(N(:), G.NodeProperties.Name);
elseif isnumeric(N)
    N = N(:);
    if ~isreal(N) || any(fix(N) ~= N) || any(N < 1)
        error(message('MATLAB:graphfun:findnode:PosInt'));
    end
    ind = double(N);
    ind(ind > numnodes(G)) = 0;
else
    error(message('MATLAB:graphfun:findnode:ArgType'));
end
