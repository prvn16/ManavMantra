function h = flipedge(g, s, t)
%FLIPEDGE Flip edge directions
%   H = FLIPEDGE(G) returns digraph H, which contains the same edges as
%   digraph G, with reversed directions. H has the same node and edge
%   properties as G.
%
%   H = FLIPEDGE(G,S,T) reverses the direction of edges specified by
%   pairs of node IDs S and T. If there are multiple edges specified by S
%   and T, they are all reverted.
%
%   H = FLIPEDGE(G,IND) reverses the direction of edges specified by the
%   edge indices IND.
%
%  See also: DIGRAPH

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin <= 1
    if size(g.EdgeProperties, 2) == 0
        h = digraph(flipedge(g.Underlying), g.EdgeProperties, g.Nodes);
    else
        [mlg, eind] = flipedge(g.Underlying);
        h = digraph(mlg, g.EdgeProperties(eind, :), g.Nodes);
    end
else
    % Determine the indices of the edges to be removed.
    if nargin == 2
        edgeind = s;
        % Reuse input checking in findedge
        [~, ~] = findedge(g, edgeind);
    else
        edgeind = findedge(g, s, t);
        
        useNodeNames = hasNodeNames(g) && ~isnumeric(s);
        
        % Error if edge doesn't exist
        if any(edgeind == 0)
            ind = find(edgeind == 0, 1);
            if ~useNodeNames
                error(message('MATLAB:graphfun:flipedge:InvalidEdge', s(ind), t(ind)));
            else
                s = findnode(g, s);
                t = findnode(g, t);
                nodeNames = g.NodeProperties.Name;
                error(message('MATLAB:graphfun:flipedge:InvalidEdge', nodeNames{s(ind)}, nodeNames{t(ind)}));
            end
        end
    end
    
    ed = g.Underlying.Edges;
    ed(edgeind, :) = flip(ed(edgeind, :), 2);
    
    h = digraph(ed(:, 1), ed(:, 2), g.EdgeProperties, g.Nodes);
end

if nargout < 1
    warning(message('MATLAB:graphfun:flipedge:NoOutput'));
end
