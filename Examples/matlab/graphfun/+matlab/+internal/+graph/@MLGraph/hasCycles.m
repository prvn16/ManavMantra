function cyc = hasCycles(G)
%HASCYCLES   Determine whether MLGraph has cycles
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2015-2017 The MathWorks, Inc.

if hasSelfLoops(G) || ismultigraph(G) || numedges(G) >= numnodes(G)
    cyc = true;
    return;
end

[bins, nrBins] = connectedComponents(G);
bins = bins.';

if numedges(G) >= numnodes(G) - nrBins + 1
    cyc = true;
    return;
end

% Vector containing the component containing each edge.
edgeToComponent = bins(G.Edges(:, 1));

nrNodesPerComponent = accumarray(bins, 1);
nrNodesPerComponent(end+1:nrBins) = 0;
nrEdgesPerComponent = accumarray(edgeToComponent, 1);
nrEdgesPerComponent(end+1:nrBins) = 0;

% If and only if there are as many or more edges than nodes in a connected
% component, that component contains a cycle.
cyc = any(nrEdgesPerComponent(:) >= nrNodesPerComponent(:));
