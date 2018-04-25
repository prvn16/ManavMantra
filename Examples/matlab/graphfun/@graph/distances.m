function D = distances(G, varargin)
% DISTANCES Compute shortest path distances between node pairs in a graph
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
%   defined by S and T.  D(i,j) is the distance from node S(i) to node
%   T(j). S and T can be vectors of numeric node IDs, cell arrays of
%   strings, or the string 'all' to represent the set of all nodes,
%   1:numnodes(G).  By default S and T are both 'all'.
%
%   D = DISTANCES(...,'Method',METHODFLAG) optionally specifies the method
%   to use in computing the shortest paths. 
%   METHODFLAG can be:
%
%         'auto'  -  Uses 'unweighted' if no weights are set, and 'positive'
%                    otherwise. This method is the default.
%
%   'unweighted'  -  Treats all edge weights as 1. 
%
%     'positive'  -  Requires all edge weights to be positive.
%
%   Example:
%       % Create and plot a graph. Compute the matrix of shortest path
%       % distances between all node pairs in the graph.
%       s = [1 1 1 1 2 6 3 4 4 5 6];
%       t = [2 3 4 5 3 2 6 5 7 7 7];
%       G = graph(s,t);
%       plot(G)
%       D = distances(G)
%
%   See also SHORTESTPATH, SHORTESTPATHTREE, DIGRAPH/DISTANCES

%   Copyright 2014-2016 The MathWorks, Inc.

% Process Name-Value pair options
[method, source, target] = parseFlags(G, varargin{:});

if hasEdgeWeights(G)
    w = G.EdgeProperties.Weight;
end

if method == "auto"
    if ~hasEdgeWeights(G) || all(w == 1)
        method = "unweighted";
    else
        method = "positive";
    end
end

if method ~= "unweighted" && ~hasEdgeWeights(G)
    w = ones(numedges(G), 1);
end

% Swap source and target to avoid transposing D
tmp = source;
source = target;
target = tmp;

% To compute many-to-few case, swap source and target to use few-to-many code
transp = ~ischar(target) && (ischar(source) || numel(target) < numel(source));
if transp
    tmp = source;
    source = target;
    target = tmp;
end

if method == "unweighted"
    D = bfsAllShortestPaths(G.Underlying, source, target);
    
else % method == "positive"
    if any(w < 0)
        error(message('MATLAB:graphfun:distances:NegativeWeights'));
    end
    D = dijkstraAllShortestPaths(G.Underlying, w, source, target);
    
end

if transp
    D = D';
end


function [methodStr, source, target] = parseFlags(G, varargin)

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
    varargin(1) = [];
end

if setSRC && numel(varargin) > 0
    [setTARG, t] = parseSubset(G, varargin{1}, 'DuplicateTARG');
    if setTARG
        target = t;
        varargin(1) = [];
    end
end

if numel(varargin) == 0
    return;
end

for ii=1:2:numel(varargin)
    name = varargin{ii};
    if ~graph.isvalidoption(name)
        error(message('MATLAB:graphfun:distances:ParseFlags'));
    end

    if ~graph.partialMatch(name, "Method")
        error(message('MATLAB:graphfun:distances:ParseFlags'));
    end
    
    if ii+1 > numel(varargin)
        error(message('MATLAB:graphfun:distances:KeyWithoutValue'));
    end
    value = varargin{ii+1};
    if ~graph.isvalidoption(value)
        error(message('MATLAB:graphfun:distances:ParseMethodUndir'));
    end
    
    methodNames = ["positive", "unweighted", "auto"];
    match = graph.partialMatch(value, methodNames);
    
    if nnz(match) == 1
        methodStr = methodNames(match);
    else
        error(message('MATLAB:graphfun:distances:ParseMethodUndir'));
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
