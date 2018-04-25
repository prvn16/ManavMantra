function [nodesCoord, edgesCoord, orderedLayers] = layeredLayout(gsimple, sources, sinks, asgnLay, edgeMult)
% LAYEREDLAYOUT   Compute layered layout
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.

% References:
% E. Gansner, E. Koutsofios, S. North and K.-P. Vo, "A Technique for
% Drawing Directed Graphs", IEEE Transactions on Software Engineering,
% vol.19, pp. 214-230, 1993.
% W. Barth, M. Juenger and P. Mutzel "Simple and Efficient Bilayer Cross
% Counting", Journal of Graph Algorithms and Applications, vol.8(2), pp
% 179-194, 2004.
% U. Brandes and B. Koepf, "Fast and Simple Horizontal Coordinate
% Assignment", LNCS, vol.2265, pp. 31-44, 2002.

%   Copyright 2015-2017 The MathWorks, Inc.

if numnodes(gsimple) == 0
    nodesCoord = zeros(0, 2);
    edgesCoord = cell(0, 1);
    return;
end

if nargin < 5
    edgeMult = ones(numedges(gsimple), 1);
end

% Check sources and sinks: cannot have any shared edges
isSource = false(1, numnodes(gsimple));
isSource(sources) = true;
if any(isSource(sinks))
    error(message('MATLAB:graphfun:plot:InvalidSourcesSinks'));
end

% Remove self-loops and make acyclic
gdag = makeAcyclic(gsimple, sources, sinks);

% Compute node layers
layers = assignLayers(gdag, sources, sinks, asgnLay);

% Construct helper graph h (edges over several layers are split up)
[h, hlayers, isInnerNode, edge2nodes] = constructHelper(gdag, layers, gsimple);

% Order nodes within each layer
orderedLayers = orderLayers(h, hlayers);

% Assign x coordinates
xcoord = assignXCoordinates(h, orderedLayers, isInnerNode);
ycoord = -hlayers';
ycoord = ycoord - min(ycoord) + 1;

% Extract Node and Edge coordinates of g
nodesCoord = [xcoord, ycoord];
nodesCoord = nodesCoord(~isInnerNode, :);
edgesCoord = extractEdges(gsimple, h, hlayers, xcoord, ycoord, edge2nodes, edgeMult);


function gdag = makeAcyclic(g, sources, sinks)
% Remove self-loops and revert some edges of g to create acyclic graph.

nn = numnodes(g);
M = adjacency(g, 'transp');

% Remove self-loops
M(1:nn+1:end) = 0;

if ~isempty(sources)
    % Remove all edges connecting source nodes with each other
    M(sources, sources) = 0;
    % Revert all incoming edges of source nodes
    [J, I] = find(M(sources, :));
    J = sources(J);
    M(sub2ind([nn, nn], J, I)) = 0;
    M(sub2ind([nn, nn], I, J)) = 1;
end

if ~isempty(sinks)
    % Remove all edges connecting sink nodes with each other
    M(sinks, sinks) = 0;
    % Revert all outgoing edges of sink nodes
    [J, I] = find(M(:, sinks));
    I = sinks(I);
    M(sub2ind([nn, nn], J, I)) = 0;
    M(sub2ind([nn, nn], I, J)) = 1;
end

gdag = matlab.internal.graph.MLDigraph(M, 'transp');
if dfsTopologicalSort(gdag)
    % The graph is acyclic
    return;
end

if isempty(sources) && isempty(sinks)
    % Construct new array sources or sinks, only for use in removing cycles
    if any(indegree(g) == 0)
        sources = find(indegree(g)==0);
    elseif any(outdegree(g) == 0)
        sinks = find(outdegree(g)==0);
    else
        sources = 1; % Start at node 1 (since there is no obvious starting point)
    end
end

% If no sources are set, revert all edges and use sinks instead
swapsrcsink = isempty(sources);
if swapsrcsink
    % Swap sources and sinks, revert after the following
    sources = sinks;
    M = M.';
end


% Make gdag acyclic by reverting the back-edges found by dfsearch starting
% at sources
edgeToDiscovered = false(1, 6);
edgeToDiscovered(4) = true;

Mhelper = M;
Mhelper(nn+1, nn+1) = 0;    % add a helper node
Mhelper(sources, nn+1) = 1; % with edges to all sources

h = matlab.internal.graph.MLDigraph(Mhelper, 'transp');

restart = true; % needed if there are several weak components
formattable = false;
revedges = depthFirstSearch(h, nn+1, edgeToDiscovered, restart, formattable);

% Revert all back edges
M(sub2ind([nn, nn], revedges(:, 2), revedges(:, 1))) = 0;
M(sub2ind([nn, nn], revedges(:, 1), revedges(:, 2))) = 1;

if swapsrcsink
    M = M.';
end

gdag = matlab.internal.graph.MLDigraph(M, 'transp');

%assert(dfsTopologicalSort(gdag));


function layers = assignLayersASAP(M, sources, allsources, sinks)

% othersources: all source nodes (nodes with indegree 0) that are not in
% user-supplied array sources
othersources = allsources;
othersources(sources) = false;

nn = size(M, 1);
Mhelper = M;
Mhelper(nn+2, nn+2) = 0;          % add two helper nodes
Mhelper(othersources, nn+1) = 1;  % nn+1 with edges to othersources
Mhelper(sources, nn+2) = 1;       % nn+2 with edges to sources
Mhelper(nn+1, nn+2) = 1;          %   and an edge to nn+1

h = matlab.internal.graph.MLDigraph(Mhelper, 'transp');

% Find length of longest path from sources to all other nodes
[~, layers] = acyclicShortestPaths(h, -ones(numedges(h), 1), nn+2);
layers = layers(1:nn);
layers = max(layers) + 1 - layers;

% Move user-specified sinks into last layer
if ~isempty(sinks)
    isSink = false(1, nn);
    isSink(sinks) = true;
    sinkLayer = max(layers);
    if any(layers(~isSink) == sinkLayer)
        sinkLayer = sinkLayer + 1;
    end
    layers(sinks) = sinkLayer;
end
%assert(isequal(unique(layers), 1:max(layers)));


function layers = assignLayers(g, sources, sinks, asgnLay)

%assert(all(indegree(g, sources) == 0));
%assert(all(outdegree(g, sinks) == 0));
M = adjacency(g, 'transp');

if strcmp(asgnLay, 'asap')
    
    layers = assignLayersASAP(M, sources, indegree(g) == 0, sinks);
    
elseif strcmp(asgnLay, 'alap')
    
    layers = assignLayersASAP(M.', sinks, outdegree(g) == 0, sources);
    layers = max(layers) + 1 - layers;
    
else
    
    layersASAP = assignLayersASAP(M, sources, indegree(g) == 0, sinks);
    
    layersALAP = assignLayersASAP(M.', sinks, outdegree(g) == 0, sources);
    layersALAP = max(layersALAP) + 1 - layersALAP;
    
    % Compute sum of all edge lengths, choose smaller one
    edgeSumASAP = sum(diff(layersASAP(g.Edges), [], 2));
    edgeSumALAP = sum(diff(layersALAP(g.Edges), [], 2));
    
    if edgeSumASAP <= edgeSumALAP
        layers = layersASAP;
    else
        layers = layersALAP;
    end
    
    %assert(isempty(g.Edges) || (edgeSumASAP > 0 && edgeSumALAP > 0) );
    
end

%assert(all(diff(layers(g.Edges), [], 2) > 0));


function [h, layers, isInnerNode, edge2nodes] = constructHelper(gdag, layers, g)
% For each edge connecting non-neighboring layers, split up the edge into
% several edges by inserting inner nodes (a->b becomes a->innernode->b)

%assert(numel(layers) == numnodes(gdag));

% Determine number of inner nodes needed
edges = gdag.Edges;
nrInnerNodes = diff(layers(edges), [], 2) - 1;
nn = numnodes(gdag) + sum(nrInnerNodes);

% Allocate space for new edges and nodes
if sum(nrInnerNodes) > 0
    edges(end+sum(nrInnerNodes), :) = 0;
    layers(nn) = 0;
end

% Cell array of node path for each edge, used in function extractEdges.
edge2nodesDAG = cell(1, numedges(gdag));

nodeIter = numnodes(gdag) + 1;
edgeIter = numedges(gdag) + 1;

for e=1:numedges(gdag)
    tail = edges(e, 1);
    head = edges(e, 2);
    
    if nrInnerNodes(e) == 0
        edge2nodesDAG{e} = [tail head];
    else
        len = nrInnerNodes(e);
        innernodes = nodeIter:(nodeIter+len-1);
        edges(e, :) = [tail nodeIter];
        edges(edgeIter:(edgeIter+len-1), :) = [innernodes; innernodes(2:end), head].';
        layers(nodeIter:nodeIter+len-1) = layers(tail)+1:layers(head)-1;
        edge2nodesDAG{e} = [tail innernodes head];
        
        nodeIter = nodeIter + len;
        edgeIter = edgeIter + len;
    end
end

% Construct graph h containing the new inner nodes
h = matlab.internal.graph.MLDigraph(edges(:, 1), edges(:, 2), nn);
%assert(all(diff(layers(h.Edges), [], 2) == 1))

% isInnerNode is true for all helper nodes
isInnerNode = [false(1, numnodes(gdag)), true(1, nn-numnodes(gdag))];

% Translate edge2nodesDAG (for gdag) to edge2nodes (for g)
edge2nodes = cell(1, numedges(g));
edgesFromG = findedge(gdag, g.Edges(:, 1), g.Edges(:, 2));
ind = edgesFromG~=0;
edge2nodes(ind) = edge2nodesDAG(edgesFromG(ind));

edgesFromGrev = findedge(gdag, g.Edges(:, 2), g.Edges(:, 1));
ind = edgesFromGrev~=0;
tmp = edge2nodesDAG(edgesFromGrev(ind));
edge2nodes(ind) = cellfun(@flip, tmp, 'UniformOutput', false);


function order = orderLayers(h, hlayers)

maxIterMedian = 20;
maxIterSwitch = 10;

import matlab.internal.graph.helperNumberCrossings

% assert(min(hlayers) == 1);
nrLayers = max(hlayers);
order = cell(1, nrLayers);

nn = numnodes(h);
MT = adjacency(h, 'transp');
M = MT';

% Determine initial order of nodes in each layer:
Madd = M;
Madd(nn+1, nn+1) = 0;
% If there are leaf nodes in a component, this makes sure we start at one of them
Madd(nn+1, indegree(h) + outdegree(h) == 1) = 1;
gg = matlab.internal.graph.MLGraph(Madd + Madd.');
discoverNode = false(1, 6);
discoverNode(1) = true;
discOrder = depthFirstSearch(gg, nn+1, discoverNode, true, false).';
discOrder(1) = [];

for ii=1:nrLayers
    order{ii} = discOrder(hlayers(discOrder) == ii);
end

nrCross = zeros(1, nrLayers);
for ii=1:nrLayers-1
    nrCross(ii) = helperNumberCrossings(M(order{ii}, order{ii+1}));
end

if all(nrCross == 0)
    return;
end

improved = true;
nrIter = 0;
bestNrCross = nrCross;
best = order;
while improved && nrIter < maxIterMedian
    
    improved = false;
    
    % Top-to-bottom sweep
    for ii=1:nrLayers-1
        order{ii+1} = medianLayer(order{ii+1}, order{ii}, MT);
    end
    
    order = allSwitchAdjacent(order, M, MT);
    
    for ii=1:nrLayers-1
        nrCross(ii) = helperNumberCrossings(M(order{ii}, order{ii+1}));
    end
    
    if sum(nrCross) < sum(bestNrCross)
        best = order;
        bestNrCross = nrCross;
        improved = true;
    else
        order = best;
    end
    
    % Bottom-to-top sweep
    for ii=nrLayers-1:-1:1
        order{ii} = medianLayer(order{ii}, order{ii+1}, M);
    end
    
    order = allSwitchAdjacent(order, M, MT);
    
    for ii=nrLayers-1:-1:1
        nrCross(ii) = helperNumberCrossings(M(order{ii}, order{ii+1}));
    end
    
    if sum(nrCross) < sum(bestNrCross)
        best = order;
        bestNrCross = nrCross;
        improved = true;
    else
        order = best;
    end
    
    nrIter = nrIter + 1;
end

nrIter = 0;
improved = true;
% Switch adjacent nodes while it improves the result
while improved && nrIter < maxIterSwitch
    [order, improved] = allSwitchAdjacent(order, M, MT);
    nrIter = nrIter + 1;
end


function [order, anyChanged] = allSwitchAdjacent(order, M, MT)
% The function only returns a changed order if this reduces the overall
% number of crossings.

nrLayers = numel(order);
%assert(nrLayers >= 2); % with fewer layers there are no crossings
anyChanged = false;

tmporder = [{[]}, order, {[]}];

for ii=2:nrLayers+1
    [changed, ind] = matlab.internal.graph.helperSwitchAdjacent( ...
        M(tmporder{ii-1}, tmporder{ii}), MT(tmporder{ii+1}, tmporder{ii}));
    if changed
        anyChanged = true;
        tmporder{ii} = tmporder{ii}(ind);
    end
end

if anyChanged
    order = tmporder(2:end-1);
end


function order = medianLayer(order, fixedorder, M)

neworder = matlab.internal.graph.helperMedianOrder(M(order, fixedorder)');
neworderred = neworder(~isnan(neworder));
if ~issorted(neworderred)
    % NaN value happens when a node has no edges between the two layers;
    % preserve position of that node as well as possible
    [~, indred] = sort(neworderred);
    noNaN = find(~isnan(neworder));
    ind = 1:numel(neworder);
    ind(noNaN) = noNaN(indred);
    order = order(ind);
end


function xcoord = assignXCoordinates(h, order, isInnerNode)
% Compute coordinates within the layers (see reference Brandes and Koepf)

% Sort node IDs by given order (layer-by-layer with in-layer orders)
n = numnodes(h);
p = cell2mat(order);
%assert(numel(p) == n && numel(unique(p)) == n);
layersize = cellfun(@length, order);
M = adjacency(h, 'transp');
M = M(p, p);
isInnerNode = isInnerNode(p);

% Mark all non-inner edges that cross inner edges; this means they will
% be ignored in the rest of the algorithm
M = matlab.internal.graph.helperMarkConflicts(-M, layersize, isInnerNode);

% Construct 4 versions of x coordinates, with varying bias
x = zeros(n, 4);
x(:, 1) = matlab.internal.graph.helperCompX(M.',   layersize,  true,  true);  % upper left
x(:, 2) = matlab.internal.graph.helperCompX(M, layersize,  true, false);  % lower left
x(:, 3) = matlab.internal.graph.helperCompX(M.',   layersize, false,  true);  % upper right
x(:, 4) = matlab.internal.graph.helperCompX(M, layersize, false, false);  % lower right

% Find layout with minimal width, align all with that layout:
width = max(x) - min(x);
[~, ind] = min(width);
xminwidth = x(:, ind);
x(:, 1) = x(:, 1) + min(xminwidth) - min(x(:, 1));
x(:, 2) = x(:, 2) + min(xminwidth) - min(x(:, 2));
x(:, 3) = x(:, 3) + max(xminwidth) - max(x(:, 3));
x(:, 4) = x(:, 4) + max(xminwidth) - max(x(:, 4));

% Take median of the 4 layouts
xcoord = median(x, 2);

xcoord = xcoord - min(xcoord) + 1;
xcoord(p) = xcoord;


function edgeCoords = extractEdges(g, h, hlayers, xcoord, ycoord, edge2nodes, edgemult)
% Assume that first numnodes(g) nodes of h are identical to nodes of g.

nodeCoords = [xcoord, ycoord];
edgeCoords = cell(sum(edgemult), 1);

% Constants
selfLoopRadius = 1/5; % set to fixed value since layer distance is also fixed.
nrPointsTwoCycle = 40;
alphaMax = 30;

% For two-cycles
cycDist = selfLoopRadius;

allEdges = adjacency(g, edgemult, 'transp');
nrEdgesBothDir = allEdges + allEdges' - diag(diag(allEdges));
% Count within multiple edges: iterates from nrEdgesBothDir to 1 in the loop below
countEdgesBothDir = nrEdgesBothDir;

edges = g.Edges;
edges = repelem(edges, edgemult, 1);
edge2nodes = repelem(edge2nodes, edgemult);

for ii=1:size(edges, 1)
    
    tail = edges(ii, 1);
    head = edges(ii, 2);
    
    if tail == head % self-loop
        % List of t's neighbors
        n = unique([successors(h, tail);...
            predecessors(h, tail)]);
        n(n == tail) = [];
        
        if ~isempty(n)
            % Compute angles of all edges in t, find largest angle
            % (most space for inserting a self-loop)
            diffX = nodeCoords(n, 1) - nodeCoords(tail, 1);
            diffY = nodeCoords(n, 2) - nodeCoords(tail, 2);
            
            angles = atan2d(diffY, diffX);
            
            angles = sort(angles);
            angles(end+1) = angles(1) + 360; %#ok<AGROW>
            
            % Find maximal difference between angles
            [~, ind] = max(diff(angles));
            ind = ind(1);
            angle = (angles(ind) + angles(ind+1))/2;
        else
            angle = 0;
        end
        
        circle = constructCircle(countEdgesBothDir(tail, tail), nrEdgesBothDir(tail, tail), selfLoopRadius);
        
        rotcircle = circle * [cosd(angle) sind(angle); -sind(angle) cosd(angle)];
        
        edgeC = rotcircle + nodeCoords(tail, :);
        
        countEdgesBothDir(tail, tail) = countEdgesBothDir(tail, tail) - 1;
    else
        
        edgeC = nodeCoords(edge2nodes{ii}, :);
        
        if nrEdgesBothDir(tail, head) > 1 || hlayers(tail) == hlayers(head)
            % scal lies in interval [-1 1] for a group of multiple edges
            scal = 2*(countEdgesBothDir(tail, head)-1) / (nrEdgesBothDir(tail, head)-1) - 1;
            
            if abs(hlayers(tail) - hlayers(head)) > 1
                edgeC(2:end-1, 1) = edgeC(2:end-1, 1) + scal*cycDist;
            else
                if hlayers(tail) == hlayers(head)
                    % Circle segment, such that the maximum distance from
                    % the layer is cycDist.
                    if nrEdgesBothDir(tail, head) == 1
                        scal = 1;
                    else
                        scal = (scal+2)/3;
                    end
                    startP = nodeCoords(tail,:);
                    endP   = nodeCoords(head,:);
                    len = abs(startP(1) - endP(1));
                    alpha = 4*atand(2*cycDist/len);
                    if xor(tail < head, hlayers(tail) ~= 1)
                        alpha = -alpha;
                    end
                else % abs(hlayers(tail) - hlayers(head)) == 1
                    startP = nodeCoords(tail,:);
                    endP   = nodeCoords(head,:);
                    len = norm(startP - endP);
                    % 3 upper bounds for opening angle alpha, minimum is used:
                    % 1) distance between circle segments <= cycDist:
                    alphaDist = 4*atand(cycDist/len);
                    % 2) circle segment stays between layers:
                    alphaBetween = 2*atand(1/abs(startP(1) - endP(1)));
                    % 3) angle less than alphaMax
                    % Together:
                    alpha = min([alphaDist, alphaBetween, alphaMax]);
                    if tail < head
                        alpha = -alpha;
                    end
                end
                alpha = scal*alpha;
                
                if alpha ~= 0
                    r = (len/2)/sind(alpha/2);
                    phi = linspace(-alpha/2, alpha/2, nrPointsTwoCycle).';
                    
                    d = startP - endP;
                    d = [-d(2) d(1)];
                    d = d/norm(d);
                    m = (startP + endP)/2 - d*r*cosd(alpha/2);
                    
                    pts = r*[cosd(phi) sind(phi)]*[d(1) d(2); -d(2) d(1)];
                    pts = pts + m;
                    edgeC = pts;
                else
                    edgeC = [startP; endP];
                end
            end
        end
        
        if abs(hlayers(tail) - hlayers(head)) > 1
            
            if edgeC(1, 2) < edgeC(end, 2)
                newEdgeC2 = (edgeC(1, 2):0.1:edgeC(end, 2))';
            else
                newEdgeC2 = (edgeC(1, 2):-0.1:edgeC(end, 2))';
            end
            
            newEdgeC1 = pchip(edgeC(:, 2), edgeC(:, 1), newEdgeC2);
            
            edgeC = [newEdgeC1 newEdgeC2];
        end
        
        countEdgesBothDir(head, tail) = countEdgesBothDir(head, tail) - 1;
        countEdgesBothDir(tail, head) = countEdgesBothDir(tail, head) - 1;
    end
    edgeCoords{ii} = edgeC;
end

% For debugging: conditions the output must satisfy:
%isInNeighborLayer = abs(hlayers(edges(:, 1)) - hlayers(edges(:, 2))) <= 1;
%assert(all(cellfun(@(a) all(diff(a(2, :))>0) || all(diff(a(2, :))<0), edgeCoords) | isInNeighborLayer(:)))
%assert(~any(cellfun(@isempty, edgeCoords)));


function circle = constructCircle(ind, n, selfLoopRadius)
% Teardrop-shape for self-loop

aWithMargin = 45;
a = aWithMargin / n * 0.9;
rotang = ((2*ind-1)/n-1) * aWithMargin;

% Many self-loops change size based on rotang, to fill out the circular
% self-loop we used to have before introducing multigraph:
r = 2*sind(a) * (cosd(rotang) - sind(a)) / cosd(a)^2;

ang = linspace(90-a, 270+a, 35).';
circle = selfLoopRadius*[0 0; (r/sind(a)-r*cosd(ang)) r*sind(ang); 0 0];

circle = circle * [cosd(rotang) sind(rotang); -sind(rotang) cosd(rotang)];
