function [path, d, edgepath] = shortestpath(G, s, t, varargin)
% SHORTESTPATH Compute shortest path between two nodes
%
%   PATH = SHORTESTPATH(G,S,T) computes the shortest path starting at node
%   S and ending at node T.  If the graph is weighted (that is, G.Edges
%   contains a Weight variable), then those weights are used as the
%   distances along the edges in the graph.  Otherwise, all edge distances
%   are taken to be 1.  PATH contains all nodes on the shortest path.  PATH
%   is a cell array of string node IDs if S and T are strings, and a vector
%   of numeric node IDs if S and T are node indices.  If node T is
%   unreachable from node S, then PATH is empty.
%
%   [PATH,D] = SHORTESTPATH(G,S,T) also returns the length of the shortest
%   path, D.  If node T is unreachable from node S, then D is Inf.
%
%   [PATH,D,EDGEPATH] = SHORTESTPATH(G,S,T) also returns the edges on the
%   path from node S to node T.
%
%   [PATH,D] = SHORTESTPATH(...,'Method',METHODFLAG) optionally specifies
%   the method to use in computing the shortest path.
%   METHODFLAG can be:
%
%         'auto'  -  Uses 'unweighted' if no weights are set, and
%                    'positive' otherwise. This method is the default.
%
%   'unweighted'  -  Treats all edge weights as 1.
%
%     'positive'  -  Requires all edge weights to be positive.
%
%   Example:
%       % Create and plot a graph. Compute the shortest path from node 7
%       % to node 8.
%       s = [1 1 2 3 3 4 4 6 6 7 8 7 5];
%       t = [2 3 4 4 5 5 6 1 8 1 3 2 8];
%       G = graph(s,t);
%       plot(G)
%       path = shortestpath(G,7,8)
%
%   Example:
%       % Create and plot a weighted graph. Compute and highlight
%       % the shortest path from node 3 to node 8.
%       s = [1 3 1 2 2 6 6 7 7 3  3 9  9  4 12 11 11  8];
%       t = [2 1 4 5 6 7 8 5 8 9 10 5 10 11  4 10 12 12];
%       weights = [10 10 10 10 10 1 1 1 1 1 1 1 1 1 1 1 1 1];
%       G = graph(s,t,weights);
%       p = plot(G,'EdgeLabel',G.Edges.Weight);
%       path = shortestpath(G,3,8)
%       highlight(p, path,'EdgeColor','red')
%
%   See also SHORTESTPATHTREE, DISTANCES, DIGRAPH/SHORTESTPATH

%   Copyright 2014-2017 The MathWorks, Inc.

src = validateNodeID(G, s);
if numel(src) ~= 1
    error(message('MATLAB:graphfun:shortestpath:NonScalarSource'));
end

targ = validateNodeID(G, t);
if numel(targ) ~= 1
    error(message('MATLAB:graphfun:shortestpath:NonScalarTarg'));
end

% Process Name-Value pair options
method = parseFlags(varargin{:});

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

if method == "unweighted"
    if nargout > 2
        [d, pred, edgepred] = bfsShortestPaths(G.Underlying, src, targ, Inf);
    else
        [d, pred] = bfsShortestPaths(G.Underlying, src, targ, Inf);
    end
else % method == "positive"
    if any(w < 0)
        error(message('MATLAB:graphfun:shortestpath:NegativeWeights'));
    end
    if nargout > 2
        [d, pred, edgepred] = dijkstraShortestPaths(G.Underlying, w, src, targ, Inf);
    else
        [d, pred] = dijkstraShortestPaths(G.Underlying, w, src, targ, Inf);
    end
end

d = d(targ);

path = constructPath(pred, targ);

if nargout > 2
    edgepath = constructEdgePath(pred, edgepred, targ);
end

if ~isnumeric(s) && ~isnumeric(t)
    path = G.NodeProperties.Name(path).';
end


function p = constructPath(pred, t)
p = [];
tnext = pred(t);
if ~isnan(tnext)
    while tnext ~= 0
        p(end+1) = t; %#ok<AGROW>
        t = tnext;
        tnext = pred(t);
    end
    p(end+1) = t;
    p = flip(p);
end

function ep = constructEdgePath(pred, edgepred, t)
ep = [];
tnext = pred(t);
if ~isnan(tnext)
    while tnext ~= 0
        ep(end+1) = edgepred(t); %#ok<AGROW>
        t = tnext;
        tnext = pred(t);
    end
    ep = reshape(ep, 1, []); % For path of length 1, ep = zeros(1, 0), not [].
    ep = flip(ep);
end


function methodStr = parseFlags(varargin)

methodStr = "auto";

if numel(varargin) == 0
    return;
end

for ii=1:2:numel(varargin)
    name = varargin{ii};
    if ~graph.isvalidoption(name)
        error(message('MATLAB:graphfun:shortestpath:ParseFlags'));
    end
    
    if ~graph.partialMatch(name, "Method")
        error(message('MATLAB:graphfun:shortestpath:ParseFlags'));
    end
    
    if ii+1 > numel(varargin)
        error(message('MATLAB:graphfun:shortestpath:KeyWithoutValue'));
    end
    value = varargin{ii+1};
    if ~graph.isvalidoption(value)
        error(message('MATLAB:graphfun:shortestpath:ParseMethodUndir'));
    end
    
    methodNames = ["positive", "unweighted", "auto"];
    match = graph.partialMatch(value, methodNames);
    
    if nnz(match) == 1
        methodStr = methodNames(match);
    else
        error(message('MATLAB:graphfun:shortestpath:ParseMethodUndir'));
    end
end
