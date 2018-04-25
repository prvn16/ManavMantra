function ids = acyclicCutConnComp(graph, isCutPoint)
% Divide a graph into a collection of weakly connected components after
% cutting a selection of nodes, enforcing the condition that each cut
% point is not allowed to be both predecessor and successor to any one
% component.
%
% This is used by slicewise fusion. We want to find connected sub-graphs
% that:
%  1. Contain only slicewise closures.
%  2. Can be fused into a single closure without introducing cycles to the
%  closure graph.
% Point (2) requires that no paths exist from a point in the sub-graph to
% another point in the sub-graph that goes outside of the sub-graph. Examples
% include mean(x - mean(x)).
%
% The implementation actually calculates three sets of ids and returns the
% unique tuples. These are:
%
%  1. Connected Component ID from conncomp:
%     There is no general guarantee that two futures from the same closure
%     have the same height. To avoid the complications of determining which
%     non-slicewise closure futures are of the same size/partitioning, we 
%     instead require that all slicewise sub-graphs to fuse must be directly
%     connected.
%
%  2. Forward propagated ID:
%     Two slicewise closures have the same forward propagated ID if and
%     only if they have the same cut points as indirect predecessors.
%
%     This guards against introducing cycles. It also prevents slicewise
%     operations that are acting on scalars being fused with slicewise
%     operations acting on partitioned data. This is important for cases
%     such as x - (sum(x) / numel(x)), we want the '/' operation to remain
%     separate from the '-' operation so that the corresponding promise is
%     completed correctly.
%
%  3. Backward propagated ID:
%     Two slicewise closures have the same backward propagated ID if and
%     only if they have the same cut points as indirect successors.
%
%     This also guards against introducing cycles. We do backwards in
%     additional to forwards because it prevents closures only required for
%     pass N to be fused with closures required by prior passes. For
%     example, this will stop the '2*' operation in sum(2*x - sum(x))
%     being fused into an combined operation that is used for both pass 1
%     and pass 2.

%   Copyright 2017 The MathWorks, Inc.

numNodes = numnodes(graph);
compIds = zeros(numNodes, 1);
compIds(~isCutPoint) = conncomp(subgraph(graph, ~isCutPoint), 'Type', 'weak');

adj = adjacency(graph);
order = toposort(graph);

forwardPropagatedIds = iPropagateIds(adj, order, isCutPoint);

% This reverses the direction of edges and then scans the graph in reverse.
% We do not need to reverse isCutPoint as this is indexed via order.
backwardPropagatedIds = iPropagateIds(adj', order(end:-1:1), isCutPoint);

[~, ~, ids] = unique([compIds, forwardPropagatedIds, backwardPropagatedIds], 'rows');

function [inIds, outIds] = iPropagateIds(adj, order, isCutPoint)
% Mark each node with an ID such a node has the same ID as it's
% predecessors if and only if all predecessors both have the same ID and
% are not cut points.
%
% This has the property that an indirect successor of a cut point cannot
% have the same ID as an indirect predecessor of a cut point.

numNodes = numel(order);

mergeMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
nextId = 1;

inIds = zeros(numNodes, 1);
outIds = zeros(numNodes, 1);
for ii = 1 : numel(order)
    nodeIdx = order(ii);
    
    pred = find(adj(:, nodeIdx));
    [inIds(nodeIdx), nextId] = iMerge(outIds(pred), mergeMap, nextId); %#ok<FNDSB>
    
    if isCutPoint(nodeIdx)
        outIds(nodeIdx) = nextId;
        nextId = nextId + 1;
    else
        outIds(nodeIdx) = inIds(nodeIdx);
    end
end

function [id, nextId] = iMerge(ids, mergeMap, nextId)

uniqueIds = unique(ids(ids ~= 0));
if isempty(uniqueIds)
    id = 0;
    return;
elseif numel(uniqueIds) == 1
    id = uniqueIds;
    return;
end

mergeKey = char(join(string(uniqueIds), ','));
if mergeMap.isKey(mergeKey)
    id = mergeMap(mergeKey);
else
    id = nextId;
    nextId = nextId + 1;
    mergeMap(mergeKey) = id; %#ok<NASGU> handle
end
