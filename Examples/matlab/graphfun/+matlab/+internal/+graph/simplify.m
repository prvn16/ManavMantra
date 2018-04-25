function [gsimple, edgeind] = simplify(g, omitSelfLoops)
%SIMPLIFY   Compute simple version of the graph
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2017 The MathWorks, Inc.

if nargin < 2
    omitSelfLoops = false;
end

% Check if graph needs to be modified at all
if ~ismultigraph(g) && (~omitSelfLoops || (isa(g, 'matlab.internal.graph.MLGraph') && ~hasSelfLoops(g)))
    gsimple = g;
    if nargout > 1
        edgeind = (1:numedges(g))';
    end
    return;
end

ed = g.Edges;

if ismultigraph(g)
    ind = any(diff(ed, [], 1), 2);
    ind = [true; ind];
else
    ind = true(numedges(g), 1);
end

if omitSelfLoops
    isSelfLoop = ed(:, 1) == ed(:, 2);
    ind = ind & ~isSelfLoop;
end

if isa(g, 'matlab.internal.graph.MLGraph')
    gsimple = matlab.internal.graph.MLGraph(ed(ind, 1), ed(ind, 2), numnodes(g));
else
    gsimple = matlab.internal.graph.MLDigraph(ed(ind, 1), ed(ind, 2), numnodes(g));
end

if nargout > 1
    edgeind = cumsum(ind);
    if omitSelfLoops
        edgeind(isSelfLoop) = 0;
    end
end
