function [x,y,z] = subspaceLayout(G,dim,outdim)
% SUBSPACELAYOUT   Subspace embedding node layout
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

% Reference:
% Y. Koren, "Drawing Graphs by Eigenvectors: Theory and Practice",
% Computers and Mathematics with Applications 49 (2005) 1867-1888.

%   Copyright 2015-2017 The MathWorks, Inc.

[L,deg] = laplacianIgnoreSelfLoops(G);
comp  = connectedComponents(G);
ncomp = max(comp);
if ncomp > 1
    xyz = zeros(numnodes(G),3);
    [compsort, ind] = sort(comp);
    startBin = [1 find(diff(compsort))+1];
    endBin = [find(diff(compsort)) length(compsort)];
    
    for k = 1:ncomp
        % If component has more than one node
        if startBin(k) ~= endBin(k)
            nodesk = ind(startBin(k):endBin(k));
            Lk     = L(nodesk,nodesk);
            degk   = deg(nodesk);
            xyz(nodesk,:) = layoutOneConnComp(G,dim,nodesk,Lk,degk,outdim);
        end
    end
    xyz(:, [1 2]) = matlab.internal.graph.packLayouts(xyz(:, [1 2]),comp);
else
    xyz = layoutOneConnComp(G,dim,1:numnodes(G),L,deg,outdim);
end
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

%--------------------------------------------------------------------------
function xyz = layoutOneConnComp(G,dim,compNodes,compL,compDeg,outdim)
% Subspace layout for one connected component.
nnodes = length(compNodes);
if nnodes <= 1
    xyz = zeros(nnodes,3);
elseif nnodes == 2
    xyz = [0 0 0; 0 1 0];
elseif nnodes == 3 && outdim == 3
    if all(compDeg == 2)
        % Cycle with three nodes
        xyz = [0 -1 0; -0.75 0.5 0; 0.75 0.5 0];
    else
        % Three nodes in a line
        xyz = [0 -1 0; -0.75 0.5 0; 0.75 0.5 0];
        [~, ind] = sort(compDeg, 'descend');
        xyz(ind, :) = xyz;
    end
else
    % Compute distance matrix.
    dim  = min(dim,nnodes);
    M    = zeros(nnodes,dim);
    dist = Inf(nnodes,1);
    [~,startNode] = max(compDeg);
    startNode = compNodes(startNode);
    for i = 1:dim
        M(:,i) = bfsAllShortestPaths(G,startNode,compNodes);
        dist = min([dist, M(:,i)],[],2);
        [~,startNode] = max(dist);
        startNode = compNodes(startNode);
    end
    % Similar computation to M = orth(M), but make sure this does not make
    % dim < outdim+1 (using orth, this happens (e.g.) for a 4-cycle using 'subspace3')
    [M, S] = svd(M, 'econ');
    s = diag(S);
    r = sum(s > nnodes * eps(max(s))); % numerical rank
    if max(r, outdim+1) < dim
        dim = max(r, outdim+1);
        M(:, dim+1:end) = [];
    end
    
    Mhat = M'*compL*M;
    Mhat = (Mhat+Mhat')./2;
    Dhat = M'*(compDeg.*M);
    Dhat = (Dhat+Dhat')./2;
    [V,~] = eig(Mhat,Dhat);
    if outdim == 2
        evind = min(2,dim-1);
        xyz = [M * V(:,[evind evind+1]) zeros(nnodes, 1)];
    elseif outdim == 3
        evind = min(2,dim-2);
        xyz = M * V(:,evind:evind+2);
    end
    % Normalize coordinates.
    r = sqrt(max(sum(xyz.^2,2))); % ~= 0
    xyz = xyz*(log(nnodes)/r);
end
%--------------------------------------------------------------------------
function [L,deg] = laplacianIgnoreSelfLoops(G)
% Compute graph Laplacian by ignoring self-loops and edge multiplicities.
nnodes = numnodes(G);
A = adjacency(G);
A(1:nnodes+1:end) = 0;
deg = full(sum(A, 1))';
L = spdiags(deg,0,nnodes,nnodes) - A;
