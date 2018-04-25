function [sOut, tOut] = findedge(G, s, t)
%FINDEDGE Determine edge index given node IDs
%  [s, t] = FINDEDGE(G) returns the source and target numeric node IDs, s
%  and t, for all of the edges in digraph G.
%
%  idx = FINDEDGE(G, s, t) returns the numeric edge indices, idx, for the
%  edges specified by the source and target node pairs s and t. The edge
%  indices correspond to the rows G.Edges(idx,:) in the G.Edges table
%  of the digraph. An edge index of 0 indicates an edge that is not in the
%  digraph. s and t must be valid node IDs---that is, they must either both
%  be numeric node IDs or character vectors (or cell arrays of character
%  vectors) specifying nodes in the digraph G.
%
%  If the edges (s,t) are present in G, then idx contains the edge indices
%  of edges (s,t), and can be used to get the corresponding edge attributes
%  from G.Edges. If the edges are not in the digraph, then idx is 0. If there
%  are multiple edges (s,t), then all their indices are returned.
%
%  [idx, m] = FINDEDGE(G, s, t) additionally returns vector m, which
%  indicates the node pair (s,t) associated with each element of idx. This
%  is useful when there are multiple edges between the same two nodes.
%
%  [s, t] = FINDEDGE(G, idx) finds the source and target nodes of the edges
%  specified by idx. idx is a vector of edge indices, which are positive
%  integers between 1 and numedges(G).
%
%   Example:
%       % Create a digraph. Find the numeric indices for edges (1, 2) and
%       % (3, 5), and then use the indices to determine their edge weights.
%       s = [1 1 2 4 2 3 3 3];
%       t = [2 3 3 2 5 6 7 5];
%       w = [0.3 0.5 0.1 0.2 0.5 1.3 3.5 1.2];
%       G = digraph(s,t,w);
%       G.Edges
%       idxOut = findedge(G,[1 3],[2 5])
%       G.Edges.Weight(idxOut)
%
%  See also DIGRAPH, FINDNODE, NUMEDGES

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin == 1
    if nargout < 2
        error(message('MATLAB:graphfun:findedge:minLHS'));
    end
    e = G.Underlying.Edges;
    sOut = e(:,1);
    tOut = e(:,2);
elseif nargin == 2
    if nargout < 2
        error(message('MATLAB:graphfun:findedge:minLHS'));
    end
    % Return s/t given an index
    if ~isnumeric(s)
        error(message('MATLAB:graphfun:findedge:nonNumericEdges'));
    end
    s = reshape(s, [], 1);
    ne = numedges(G);
    if ~isreal(s) || any(fix(s) ~= s) || any(s < 1) || any(s > ne)
        error(message('MATLAB:graphfun:findedge:EdgeBounds', ne));
    end
    e = G.Underlying.Edges(s,:);
    sOut = e(:, 1);
    tOut = e(:, 2);
else
    % Return an index given s/t
    if digraph.isvalidstring(s) && digraph.isvalidstring(t)
        % Convert to numerics by looking up.
        if ~hasNodeNames(G)
            error(message('MATLAB:graphfun:findedge:NoNodeNames'));
        end
        if ~iscellstr(s), s = {s}; end
        if ~iscellstr(t), t = {t}; end
        s = convertToIndex(s(:), G.NodeProperties.Name);
        t = convertToIndex(t(:), G.NodeProperties.Name);
    elseif ~isnumeric(s) || ~isnumeric(t)
        error(message('MATLAB:graphfun:findedge:InconsistentNodeNames'));
    end
    if nargout <= 1
        sOut = findedge(G.Underlying, s, t);
    else
        [sOut, tOut] = findedge(G.Underlying, s, t);
    end
end

function sInd = convertToIndex(s, Names)
[isThere, sInd] = ismember(s, Names);
if ~all(isThere)
    badNodes = s(~isThere);
    error(message('MATLAB:graphfun:findedge:UnknownNodeName', badNodes{1}));
end
