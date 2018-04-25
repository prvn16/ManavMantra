function [inPartIds, outPartIds] = determinePartitioning(graph, order)
% Determine the partitioning of execution at each node of a graph of closures.
%
% This will generate a pair of id for each node, the partitioning ID
% entering the node and the partitioning ID leaving the node.
%
% Each partitioning ID is an integer that will be:
%  * 0 for non-partitioned
%  * negative for partition by datastore, where each id
%    corresponds to one unique datastore)
%  * positive for partition by N partitions.
%  * Inf for partition as per back-end choice.

%   Copyright 2017 The MathWorks, Inc.

adj = adjacency(graph);
nodes = graph.Nodes;
nodeObjs = nodes.NodeObj;
isClosure = nodes.IsClosure;
opTypes = nodes.OpType;
numNodes = numnodes(graph);

if nargin < 2
    order = toposort(graph);
end

inPartIds = zeros(numNodes, 1);

outPartIds = zeros(numNodes, 1);

uniqueDatastores = {};
for ii = 1 : numel(order)
    nodeIdx = order(ii);
    node = nodeObjs{nodeIdx};
    opType = opTypes(nodeIdx);
    pred = find(adj(:, nodeIdx));
    
    inPartId = outPartIds(pred); %#ok<FNDSB>
    inPartId = unique(inPartId(inPartId ~= 0));
    if isempty(inPartId)
        inPartId = 0;
    elseif numel(inPartId) > 1
        inPartId = NaN;
    end
    inPartIds(nodeIdx) = inPartId;
    
    if ~isClosure(nodeIdx)
        outPartId = inPartIds(nodeIdx);
    elseif isa(node.Operation, 'matlab.bigdata.internal.lazyeval.AggregateFusibleOperation')
            outPartId = 0;
    elseif opType == 'AggregateByKeyOperation'
        outPartId = inf;
    elseif opType == 'ReadOperation'
        ds = node.Operation.Datastore;
        [outPartId, uniqueDatastores] = iGetIdForDatastore(ds, uniqueDatastores);
    elseif opType == 'RepartitionOperation'
        strategy = node.Operation.OutputPartitionStrategy;
        if strategy.IsBroadcast
            outPartId = 0;
        elseif strategy.IsDatastorePartitioning
            ds = strategy.Datastore;
            [outPartId, uniqueDatastores] = iGetIdForDatastore(ds, uniqueDatastores);
        else
            outPartId = strategy.DesiredNumPartitions;
            if isempty(outPartId)
                outPartId = 1;
            end
        end
    else
        outPartId = inPartId;
    end
    outPartIds(nodeIdx) = outPartId;
end

function [id, uniqueDatastores] = iGetIdForDatastore(ds, uniqueDatastores)
% Get the ID for the given datastore. This will match all other instances
% of the same datastore.
isMatch = cellfun(@(x) x == ds, uniqueDatastores);
if any(isMatch)
    id = -find(isMatch, 1, 'first');
else
    uniqueDatastores{end + 1} = ds;
    id = -numel(uniqueDatastores);
end
