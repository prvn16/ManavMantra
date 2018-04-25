function [nodeids, d] = nearest(G, s, d, varargin)
% NEAREST Compute nearest neighbors of a node
%
%   NODEIDS = NEAREST(G, S, D) returns all nodes within a distance D
%   of node S, sorted from nearest to furthest.  If the graph is
%   weighted (that is G.Edges contains a Weight variable) those
%   weights are used as the distances along the edges in the graph.
%   Otherwise, all distances are implicitly taken to be 1.
%
%   [NODEIDS, DIST] = NEAREST(G, S, D) additionally returns a
%   vector DIST, where DIST(j) is the distance from node SOURCE to node
%   NODEIDS(j).
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
%   See also SHORTESTPATHTREE, DISTANCES, DIGRAPH/NEAREST

%   Copyright 2016 The MathWorks, Inc.

% Parse inputs
src = validateNodeID(G, s);  
if ~isscalar(src)
    error(message('MATLAB:graphfun:nearest:NonScalarSource'));
end

if ~isnumeric(d) || ~isscalar(d) || ~(d >= 0) || ~isreal(d)
    error(message('MATLAB:graphfun:nearest:InvalidDistanceUndir'));
end

method = parseInput(varargin{:});

% Get the weights
if hasEdgeWeights(G) && method ~= "unweighted"
    w = G.EdgeProperties.Weight;
    if any(w < 0)
       error(message('MATLAB:graphfun:nearest:NegativeWeights'));
    end
else
    w = [];
end

% apply the method
[nodeids, d] = applyOneToAll(G.Underlying, w, src, d, method);

nodeids = nodeids(:);
d = d(:);

if ~isnumeric(s)
   nodeids = G.Nodes.Name(nodeids);
end


function [nodeids, d] = applyOneToAll(H, w, src, dist, methodStr)

if methodStr == "auto"
    if isempty(w) || all(w == 1)
        methodStr = "unweighted";
    else
        methodStr = "positive";
    end
end

if methodStr == "unweighted"
    [d, pred] = bfsShortestPaths(H, src, 'all', dist);
else %  methodStr == "positive"
    if isempty(w)
        w = ones(H.EdgeCount, 1);
    end
    [d, pred] = dijkstraShortestPaths(H, w, src, 'all', dist);
end

% Extract nearest nodes:
reachableNodes = find(pred > 0);
[d, nodeids] = sort(d(reachableNodes));

ind = (d <= dist);

d = d(ind);
nodeids = reachableNodes(nodeids(ind));


function method = parseInput(varargin)

method = "auto";

% Parse trailing arguments (name-value pairs)
for ii=1:2:numel(varargin)
    name = varargin{ii};
    if ~graph.isvalidoption(name)
        error(message('MATLAB:graphfun:nearest:ParseFlagsUndir'));
    end
    
    if graph.partialMatch(name, "Method")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:nearest:KeyWithoutValue', 'Method'));
        end
        value = varargin{ii+1};
        if ~graph.isvalidoption(value)
            error(message('MATLAB:graphfun:nearest:ParseMethodUndir'));
        end
        
        methodNames = ["positive", "unweighted", "auto"];
        match = graph.partialMatch(value, methodNames);
        
        if nnz(match) == 1
            method = methodNames(match);
        else
            error(message('MATLAB:graphfun:nearest:ParseMethodUndir'));
        end
    else
        error(message('MATLAB:graphfun:nearest:ParseFlagsUndir'));
    end
end
