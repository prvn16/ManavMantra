function [tree, ind] = bctree(g)
%BCTREE Block-cut tree
%   TREE = BCTREE(G) returns the block-cut tree of graph G such that each
%   node of TREE represents either a biconnected component or a cut vertex
%   of G. A node representing a cut vertex is connected to all nodes
%   representing biconnected components which contain that cut vertex.
%
%   TREE has additional node properties:
%
%       TREE.Nodes.IsComponent(i) - Logical 1 (true) if node i represents
%                                   a biconnected component, and logical 0
%                                   (false) otherwise.
%    TREE.Nodes.ComponentIndex(i) - An index indicating the component
%                                   represented by node i. The value is
%                                   zero if i is a cut vertex.
%    TREE.Nodes.CutVertexIndex(i) - An index indicating the cut vertex
%                                   represented by node i. The value is
%                                   zero if i is a component.
%
%   [TREE, IND] = BCTREE(G) additionally returns vector IND, which maps
%   nodes in G into nodes of TREE. If node i is a cut vertex in G, then
%   IND(i) is the associated node in TREE. Otherwise, i is the node in G
%   representing the biconnected component that contains node i. If i is an
%   isolated node, then IND(i) is zero.
%
%   See also: BICONNCOMP

%   Copyright 2016 The MathWorks, Inc.

% call to biconnected components C++ code
[edgebins, cutvert] = biconnectedComponents(g.Underlying);

% returning logical vector for cut vertices, where 1 signifies a cut
% vertex
isArtPt = cutvert;
cutvert = find(cutvert);

nrBins = max([0 edgebins]);
nrCutVerts = numel(cutvert);

% Extract all edges, remove self-loops
[s, t] = findedge(g);
isSelfLoop = edgebins == 0;
s(isSelfLoop) = [];
t(isSelfLoop) = [];
edgebins(isSelfLoop) = [];

% Construct vector ind
ind = zeros(1, numnodes(g));
ind(s) = edgebins;
ind(t) = edgebins;
ind(cutvert) = nrBins + (1:nrCutVerts);

% Construct reduced tree-shaped graph:
oneArtPt = xor(isArtPt(s), isArtPt(t));
bothArtPt = isArtPt(s) & isArtPt(t);

ss = [ind(s(oneArtPt)) ind(s(bothArtPt)) ind(t(bothArtPt))];
tt = [ind(t(oneArtPt)) edgebins(bothArtPt) edgebins(bothArtPt)];

nn = nrBins + nrCutVerts;
M = sparse(ss, tt, 1, nn, nn) ~= 0;
tree = graph(M | M', 'omitSelfLoops');

tree.Nodes.IsComponent = [true(max(edgebins), 1); false(numel(cutvert), 1)];
tree.Nodes.ComponentIndex = [(1:max(edgebins))'; zeros(numel(cutvert), 1)];
tree.Nodes.CutVertexIndex = [zeros(max(edgebins), 1); cutvert(:)];
