function [nodeids, d] = nearest(G, s, d, varargin)
% NEAREST Compute nearest neighbors of a node
%
%   NODEIDS = NEAREST(G, S, D) returns all nodes within a distance D
%   from node S, sorted from nearest to furthest.  If the graph is
%   weighted (that is G.Edges contains a Weight variable) those
%   weights are used as the distances along the edges in the graph.
%   Otherwise, all distances are implicitly taken to be 1.
%
%   [NODEIDS, DIST] = NEAREST(G, S, D) additionally returns a
%   vector DIST, where DIST(j) is the distance from node SOURCE to node
%   NODEIDS(j).
%
%   NEAREST(..., 'Direction', DIR) specifies the search direction. DIR can
%   be:
%       'outgoing' - Distances are computed from node S to nodes NODEIDS
%                    (this is the default).
%       'incoming' - Distances are computed from nodes NODEIDS to node S.
%
%   NEAREST(...,'Method',METHODFLAG) optionally specifies the method to
%   compute the distances.
%   METHODFLAG can be:
%
%         'auto'  -  Uses 'unweighted' if no weights are set, 'positive'
%                    if all weights are nonnegative, and 'mixed' otherwise.
%                    This method is the default.
%
%   'unweighted'  -  Treats all edge weights as 1.
%
%     'positive'  -  Requires all edge weights to be positive.
%
%        'mixed'  -  Allows negative edge weights, but requires that the
%                    graph has no negative cycles.
%
%   See also SHORTESTPATHTREE, DISTANCES, GRAPH/NEAREST

%   Copyright 2015-2017 The MathWorks, Inc.

% Parse inputs
src = validateNodeID(G, s);
if ~isscalar(src)
    error(message('MATLAB:graphfun:nearest:NonScalarSource'));
end

if ~isnumeric(d) || ~isscalar(d) || isnan(d) || ~isreal(d)
    error(message('MATLAB:graphfun:nearest:InvalidDistanceDir'));
end

[method, direction] = parseInput(varargin{:});

% Get the weights
if hasEdgeWeights(G) && ~strcmp(method, 'unweighted')
    w = G.EdgeProperties.Weight;
else
    w = [];
end

if isnumeric(s)
    nodeNames = [];
else
    nodeNames = G.NodeProperties.Name;
end

% Apply the method
if strcmp(direction, 'outgoing')
    [nodeids, d] = applyOneToAll(G.Underlying, w, src, d, method, nodeNames);
else % direction is 'incoming'
    if isempty(w)
        Greverse = flipedge(G.Underlying);
    else
        [Greverse, eind] = flipedge(G.Underlying);
        w = w(eind);
    end
    [nodeids, d] = applyOneToAll(Greverse, w, src, d, method, nodeNames);
end

nodeids = nodeids(:);
d = d(:);

if ~isnumeric(s)
    nodeids = G.NodeProperties.Name(nodeids);
end


function [nodeids, d] = applyOneToAll(H, w, src, dist, methodStr, nodeNames)

if strcmp(methodStr, 'auto')
    if isempty(w) || all(w == 1)
        methodStr = 'unweighted';
    elseif all(w >= 0)
        methodStr = 'positive';
    else
        methodStr = 'mixed';
    end
end

if strcmp(methodStr, 'unweighted')
    [d, pred] = bfsShortestPaths(H, src, 'all', dist);
else
    if isempty(w)
        w = ones(H.EdgeCount, 1);
    end
    if strcmp(methodStr, 'positive')
        if any(w < 0)
            error(message('MATLAB:graphfun:nearest:DijkstraNonNegative'));
        end
        [d, pred] = dijkstraShortestPaths(H, w, src, 'all', dist);
    else % methodStr == 'mixed'
        [noNegCycles, d, pred] = bellmanFordShortestPaths(H, w, src);
        if ~noNegCycles
            error(message('MATLAB:graphfun:nearest:NegCycle', num2str(d), negCycleString(pred, nodeNames)));
        end
    end
    
end

% Extract nearest nodes:
reachableNodes = find(pred > 0);
[d, nodeids] = sort(d(reachableNodes));

ind = (d <= dist);

d = d(ind);
nodeids = reachableNodes(nodeids(ind));


function [method, direction] = parseInput(varargin)

method = 'auto';
direction = 'outgoing';

% Parse trailing arguments (name-value pairs)
for ii=1:2:numel(varargin)
    name = varargin{ii};
    if ~digraph.isvalidoption(name)
        error(message('MATLAB:graphfun:nearest:ParseFlagsDir'));
    end
    
    if digraph.partialMatch(name, "Method")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:nearest:KeyWithoutValue', 'Method'));
        end
        value = varargin{ii+1};
        if ~digraph.isvalidoption(value)
            error(message('MATLAB:graphfun:nearest:ParseMethodDir'));
        end
        methodNames = ["positive", "unweighted", "mixed", "auto"];
        match = digraph.partialMatch(value, methodNames);
        
        if nnz(match) == 1
            method = methodNames(match);
        else
            error(message('MATLAB:graphfun:nearest:ParseMethodDir'));
        end
    elseif digraph.partialMatch(name, "Direction")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:nearest:KeyWithoutValue', 'Direction'));
        end
        value = varargin{ii+1};
        if ~digraph.isvalidoption(value)
            error(message('MATLAB:graphfun:nearest:ParseDirection'));
        end
        if digraph.partialMatch(value, "outgoing")
            direction = "outgoing";
        elseif digraph.partialMatch(value, "incoming")
            direction = "incoming";
        else
            error(message('MATLAB:graphfun:nearest:ParseDirection'));
        end
    else
        error(message('MATLAB:graphfun:nearest:ParseFlagsDir'));
    end
end
