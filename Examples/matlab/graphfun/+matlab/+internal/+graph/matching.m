function [e, s, t] = matching(G, objStr)
%MATCHING Compute a matching on the graph
%
%   E = MATCHING(G) returns a set of edges such that each node is
%   connected to one and only one edge. The output e is a vector
%   of indices into the Edges table of G.
%
%   E = MATCHING(G, OBJFLAG) specifies what priorities the algorithm sets
%   in the matching returned.
%   OBJFLAG can be:
%
%      'perfectMin' - Finds a perfect matching that minimizes the sum of
%                     all edge weights. This is the default.
%
%      'optimumMin' - Finds a maximum cardinality minimum weight matching.
%
%      'perfectMax' - Finds a perfect matching that maximizes the sum of
%                     all edge weights.
%
%             'max' - First priority is to maximize the sum of all edge
%                     weights, even if some nodes end up being unmatched.
%
%   When there are no edge weights, this value does not affect the
%   output.
%
%   [E, S, T] = MATCHING(...) additionally returns the source and
%   target nodes of each edge in the matching.

%   Copyright 2017 The MathWorks, Inc.

if nargin < 2
    objStr = 'perfectMin';
end
if graph_isvalidoption(objStr)
    methodNames = ["perfectMin", "optimumMin", "perfectMax", "max"];
    match = graph_partialMatch(objStr, methodNames);
else
    error('MATLAB:graphfun:matching:ParseObjective',...
        'The objective must be a string.');
end

if nnz(match) == 1
    objStr = methodNames(match);
else
    error('MATLAB:graphfun:matching:ParseObjective',...
        'Objective can be either ''perfectMin'', ''perfectMax'', or ''max''.');
end

% Check if G is bipartite and get partitions.
[is_bipart, partitions] = bipartition(MLGraph(G));

if ~is_bipart
    error('MATLAB:graphfun:matching:OnlyBipartiteSupported',...
        'Only bipartite graph are supported.');
end
size_p1 = nnz(partitions == 0);
size_p2 = numnodes(G) - size_p1;
if size_p1 ~= size_p2 &&...
        (strcmp(objStr, "perfectMin") || strcmp(objStr, "perfectMax"))
    error('MATLAB:graphfun:matching:PerfectMatchingNotFound',...
        'The graph has no perfect matching.')
end

% Get weights.
if any(strcmp('Weight', G.Edges.Properties.VariableNames))
    w = G.Edges.Weight;
else
    w = ones(numedges(G), 1);
end
if isempty(w)
    e = zeros(0,1); % weird but to be consistent with findedge
    s = zeros(1,0);
    t = zeros(1,0);
    return
end

if (strcmp(objStr, 'optimumMin') ||...
        strcmp(objStr, 'max') || strcmp(objStr, 'perfectMax'))...
        && any(w == Inf)
    error('MATLAB:graphfun:matching:InfWeights',...
        'Infinite weights are not allowed for this objective.');
end

% Build larger graph for 'max' or 'perfectMin' with unbalanced partitions.
if strcmp(objStr, 'max') || strcmp(objStr, 'optimumMin')
    n = numnodes(G);
    [s,t] = findedge(G);
    
    if strcmp(objStr, 'max')
        new_edge_weight = 0;
    else % optimumMin
        new_edge_weight = 2 * min(size_p1, size_p2) * max(w);
        if ~isfinite(new_edge_weight)
            % Divide by next-largest power of 2
            w = w ./ (0.5 * max(w));
            new_edge_weight = 2 * min(size_p1, size_p2) * max(w);
        end
    end
    
    sLarge = [s; s+n; (1:n)'];
    tLarge = [t; t+n; (n+1:2*n)'];
    wLarge = [w; w; new_edge_weight*ones(n, 1)];
    Glocal = graph(sLarge, tLarge, wLarge);
    w = Glocal.Edges.Weight;
else
    Glocal = G;
end

if strcmp(objStr, 'perfectMax') || strcmp(objStr, 'max')
    w = max(w) - w;
end

% Call algorithm on underlying MLGraph object:
m = minimumMatching(MLGraph(Glocal), w);
if strcmp(objStr, 'max') || strcmp(objStr, 'optimumMin')
    m = m(1:n);
    assert(all(m ~= 0));
    m(m>n) = 0;
    partitions = partitions(1:n);
else % Looking for perfect matchings
    if any(m == 0)
        error('MATLAB:graphfun:matching:PerfectMatchingNotFound',...
            'The graph has no perfect matching.')
    end
end
s = find(partitions == 0 & m > 0);
t = m(s);
e = findedge(G, s, t);

function tf = graph_isvalidoption(name)
% Check for options and Name-Value pairs used in graph methods
tf = (ischar(name) && isrow(name)) || (isstring(name) && isscalar(name));

function ind = graph_partialMatch(name, candidates)
len = max(strlength(name), 1);
ind = strncmpi(name, candidates, len);
