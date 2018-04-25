function c = edgecount(G, s, t)
%EDGECOUNT Determine number of edges between two nodes
%
%  C = EDGECOUNT(G,s,t) returns the number of edges from node s to node t.
%
%  See also FINDEDGE

%   Copyright 2017 The MathWorks, Inc.

if graph.isvalidstring(s) && graph.isvalidstring(t)
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

c = edgecount(G.Underlying, s, t);

function sInd = convertToIndex(s, Names)
[isThere, sInd] = ismember(s, Names);
if ~all(isThere)
    badNodes = s(~isThere);
    error(message('MATLAB:graphfun:findedge:UnknownNodeName', badNodes{1}));
end
