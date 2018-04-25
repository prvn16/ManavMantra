function edgeind = simplifyEdgeIndex(g)
%SIMPLIFYEDGEINDEX   Compute index to simplified version of the graph
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2017 The MathWorks, Inc.

if numedges(g) > 0
    ind = any(diff(g.Edges, [], 1), 2);
    ind = [true; ind];
else
    ind = false(0, 1);
end

edgeind = cumsum(ind);

