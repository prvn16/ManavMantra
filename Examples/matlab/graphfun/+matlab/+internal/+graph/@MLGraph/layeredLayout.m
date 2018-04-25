function [nodesCoord, edgesCoord] = layeredLayout(gsimple, sources, sinks, asgnLay, edgeMult)
% LAYEREDLAYOUT   Compute layered layout
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2015-2017 The MathWorks, Inc.

% Construct a directed acyclic graph from undirected graph g
% and feed that into MLDigraph/layeredLayout

% Make acyclic (replace every edge by an edge in one direction,
% such that the resulting graph is acyclic)

[gdag, edgeMultdag, p] = makeAcyclic(gsimple, sources, sinks, edgeMult);

[nodesCoord, edgesCoord] = layeredLayout(gdag, sources, sinks, asgnLay, edgeMultdag);

edgesCoord(p) = edgesCoord;

function [gdag, edgeMultPerm, p] = makeAcyclic(g, sources, sinks, edgeMult)
% Orient edges of g to create acyclic graph gdag.

if numnodes(g) == 0
    gdag = matlab.internal.graph.MLDigraph;
    edgeMultPerm = zeros(0, 1);
    p = zeros(0, 1);
    return;
end

% Remove self-loops and revert some edges of g to create acyclic graph
% gdag. isreverted has length numedges(g) and is true if the edge is
% reverted in gdag.

nn = numnodes(g);
M = adjacency(g, 1:numedges(g));
Mnew = M;

% Remove self-loops
Mnew(1:nn+1:end) = 0;

if ~isempty(sources)
    % Remove all incoming edges of source nodes
    Mnew(:, sources) = 0;
end

if ~isempty(sinks)
    % Remove all outgoing edges of sink nodes
    Mnew(sinks, :) = 0;
end

if isempty(sources) && isempty(sinks)
    % Construct a sinks or sources array (only for the purpose of removing cycles):
    sources = 1;
end

% If no sources are set, revert all edges and use sinks instead
swapsrcsink = isempty(sources);
if swapsrcsink
    % Swap sources and sinks, revert after the following
    sources = sinks;
    Mnew = Mnew.';
end

% Make gdag acyclic by reverting the back-edges found by dfsearch starting
% at nodes sources
edgeToDiscovered = false(1, 6);
edgeToDiscovered(4) = true;

Mhelper = Mnew;
Mhelper(nn+1, nn+1) = 0;    % add a helper node
Mhelper(nn+1, sources) = 1; % with edges to all sources

h = matlab.internal.graph.MLDigraph(Mhelper);

restart = true; % needed if there are several weak components
formattable = false;
revedges = depthFirstSearch(h, nn+1, edgeToDiscovered, restart, formattable);


Mnew(sub2ind([nn, nn], revedges(:, 2), revedges(:, 1))) = ...
    Mnew(sub2ind([nn, nn], revedges(:, 1), revedges(:, 2)));
Mnew(sub2ind([nn, nn], revedges(:, 1), revedges(:, 2))) = 0;

if swapsrcsink
    Mnew = Mnew.';
end

Mnew(1:nn+1:end) = diag(M);
Mnew(sources, sources) = triu(M(sources, sources));
Mnew(sinks, sinks) = triu(M(sinks, sinks));

gdag = matlab.internal.graph.MLDigraph(Mnew);

pSimple = nonzeros(Mnew');
edgeMultPerm = edgeMult(pSimple);

blockStarts = [0; cumsum(edgeMultPerm)]+1;
firstIndexMultEdge = [0; cumsum(edgeMult(1:end-1))]+1;

% For each edge e of the multigraph defined by gdag and edgeMultPerm, p(e)
% describes the matching edge in the original graph (defined by g and
% edgeMult).
p = zeros(1, sum(edgeMult));
for ii=1:length(pSimple)
    ind = blockStarts(ii):blockStarts(ii+1)-1;
    n = length(ind);
    p(ind) = firstIndexMultEdge(pSimple(ii)) + (0:n-1);
end
