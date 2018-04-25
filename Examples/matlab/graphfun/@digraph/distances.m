function D = distances(G, varargin)
% DISTANCES Compute shortest path distances between node pairs in a digraph
%
%   D = DISTANCES(G) returns matrix D, where D(i,j) is the length of the
%   shortest path from node i to node j.  If the graph is weighted (that
%   is, G.Edges contains a Weight variable), then those weights are used as
%   the distances along the edges in the graph.  Otherwise, all edge
%   distances are taken to be 1.
%
%   D = DISTANCES(G,S) restricts the sources to the nodes defined by S.
%   D(i,j) is the distance from node S(i) to node j. S can be a vector of
%   numeric node IDs, a cell array of strings, or the string 'all' to
%   represent the set of all nodes, 1:numnodes(G).  By default S is 'all'.
%
%   D = DISTANCES(G,S,T) additionally restricts the targets to the nodes
%   defined by T.  D(i,j) is the distance from node S(i) to node
%   T(j). S and T can be vectors of numeric node IDs, cell arrays of
%   strings, or the string 'all' to represent the set of all nodes,
%   1:numnodes(G).  By default S and T are both 'all'.
%
%   D = DISTANCES(...,'Method',METHODFLAG) optionally specifies the method
%   to use in computing the shortest paths.
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
%   Example:
%       % Create and plot a digraph. Compute the matrix of shortest path
%       % distances between all node pairs in the digraph.
%       s = [1 1 1 1 2 6 3 4 4 5 6];
%       t = [2 3 4 5 3 2 6 5 7 7 7];
%       G = digraph(s,t);
%       plot(G)
%       D = distances(G)
%
%   See also SHORTESTPATH, SHORTESTPATHTREE, GRAPH/DISTANCES

%   Copyright 2014-2017 The MathWorks, Inc.

% Process Name-Value pair options
[method, source, target, nodeNames] = parseFlags(G, varargin{:});

if hasEdgeWeights(G)
    w = G.EdgeProperties.Weight;
end

if method == "auto"
    if ~hasEdgeWeights(G) || all(w == 1)
        method = "unweighted";
    elseif all(w >= 0)
        method = "positive";
    else
        method = "mixed";
    end
end

if method ~= "unweighted" && ~hasEdgeWeights(G)
    w = ones(numedges(G), 1);
end

if method == "unweighted"
    D = bfsAllShortestPaths(G.Underlying, source, target)';
elseif method == "positive"
    if any(w < 0)
        error(message('MATLAB:graphfun:distances:DijkstraNonNegative'));
    end
    D = dijkstraAllShortestPaths(G.Underlying, w, source, target)';
else % method == "mixed"
    D = johnsonAllShortestPaths(G.Underlying, w, source, target, nodeNames);
end


function D = johnsonAllShortestPaths(mlg, w, source, target, nodeNames)

n = numnodes(mlg);
M = adjacency(mlg, 'transp');
M(n+1, n+1) = 0;
M(1:n, n+1) = 1;

H = matlab.internal.graph.MLDigraph(M, 'transp');

if ismultigraph(mlg)
    edgeind = matlab.internal.graph.simplifyEdgeIndex(mlg);
    w = accumarray(edgeind, w, [], @(x) min(x, [], 'includenan'));
    mlg = matlab.internal.graph.MLDigraph(M(1:end-1, 1:end-1), 'transp');
end

hw = w;
hw(end+1:H.EdgeCount) = 0;

[noNegCycles, minweight, pred] = bellmanFordShortestPaths(H, hw, n+1);
if ~noNegCycles
    error(message('MATLAB:graphfun:distances:NegCycle', num2str(minweight), negCycleString(pred, nodeNames)));
end

minweight = minweight(1:n).';
ed = mlg.Edges;
wmod = w + minweight(ed(:, 1)) - minweight(ed(:, 2));

if ~all(wmod >= 0)
    error(message('MATLAB:graphfun:distances:JohnsonOverflow'));
end

D = dijkstraAllShortestPaths(mlg, wmod, source, target)';

if ischar(target)
    D = D + minweight.';
else
    D = D + minweight(target).';
end
if ischar(source)
    D = D - minweight;
else
    D = D - minweight(source);
end

function [methodStr, source, target, nodeNames] = parseFlags(G, varargin)

if hasNodeNames(G)
    nodeNames = G.NodeProperties.Name;
else
    nodeNames = [];
end

methodStr = "auto";
source = 'all';
target = 'all';

if numel(varargin) == 0
    return;
end

% Special handling of second input
[setSRC, s] = parseSubset(G, varargin{1}, 'DuplicateSRC');
if setSRC
    source = s;
    if isnumeric(varargin{1})
        nodeNames = [];
    end
    varargin(1) = [];
end

if setSRC && numel(varargin) > 0
    [setTARG, t] = parseSubset(G, varargin{1}, 'DuplicateTARG');
    if setTARG
        target = t;
        if isnumeric(varargin{1})
            nodeNames = [];
        end
        varargin(1) = [];
    end
end

if numel(varargin) == 0
    return;
end

for ii=1:2:numel(varargin)
    name = varargin{ii};
    if ~digraph.isvalidoption(name)
        error(message('MATLAB:graphfun:distances:ParseFlags'));
    end
    
    if ~digraph.partialMatch(name, "Method")
        error(message('MATLAB:graphfun:distances:ParseFlags'));
    end
    
    if ii+1 > numel(varargin)
        error(message('MATLAB:graphfun:distances:KeyWithoutValue'));
    end
    value = varargin{ii+1};
    if ~digraph.isvalidoption(value)
        error(message('MATLAB:graphfun:distances:ParseMethodDir'));
    end
    
    methodNames = ["positive", "mixed", "unweighted", "acyclic", "auto"];
    match = digraph.partialMatch(value, methodNames);
    
    if nnz(match) == 1
        methodStr = methodNames(match);
    else
        error(message('MATLAB:graphfun:distances:ParseMethodDir'));
    end
    
end

function [isSet, subset] = parseSubset(G, param, errFlag)
% Helper function for parseFlags

isSet = false;
subset = []; % never used
if iscell(param) || isnumeric(param) || (ischar(param) && strcmpi(param, 'all'))
    isSet = true;
    if ischar(param)
        subset = 'all';
    else
        subset = validateNodeID(G, param);
        if numel(subset) ~= numel(unique(subset))
            error(message(['MATLAB:graphfun:distances:' errFlag]));
        end
    end
elseif ischar(param) && ~strncmpi(param, 'Method', max(1, length(param)))
    error(message('MATLAB:graphfun:distances:UnrecognizedParameter', param));
end
