function [tf, isGatherCheap] = isPreviewCheap(partitionedArray)
%isPreviewCheap Can a preview of the partitioned array be computed "cheaply".
%   TF = isPreviewCheap(PA) returns TRUE if a preview of PartitionedArray PA can
%   be computed without an entire pass through the underlying data.

% Copyright 2016 The MathWorks, Inc.

closureGraph = matlab.bigdata.internal.optimizer.ClosureGraph(partitionedArray);
g = closureGraph.Graph;
g = reordernodes(g, toposort(g));

% A flag per node that will store whether the entire output of that node
% is itself a preview.
isPreviewVector = false(numnodes(g), 1);

% A flag per node that will store whether the output of that node can be
% previewed cheaply.
supportsPreviewVector = false(numnodes(g), 1);

nodes = g.Nodes.NodeObj;
isClosureVector = g.Nodes.IsClosure;

% Calculate distances matrix up-front to make calculating predecessor nodes more
% efficient.
dist = distances(g);

for ii = 1:numnodes(g)
    % Equivalent to 'predecessors(g, ii)' - but faster.
    previousNodes = find(dist(:, ii) == 1);
    
    if isempty(previousNodes)
        % This is for ReadOperation and for gathered arrays.
        isInputPreview = ~isClosureVector(ii);
        inputSupportsPreview = true;
    else
        isInputPreview = all(isPreviewVector(previousNodes));
        inputSupportsPreview = all(supportsPreviewVector(previousNodes));
    end
    
    if isClosureVector(ii)
        isPreviewVector(ii) = isInputPreview ...
            || (inputSupportsPreview && nodes{ii}.Operation.DependsOnOnlyHead);
        
        supportsPreviewVector(ii) = isInputPreview ...
            || (inputSupportsPreview && nodes{ii}.Operation.SupportsPreview);
    else
        isPreviewVector(ii) = isInputPreview;
        supportsPreviewVector(ii) = inputSupportsPreview;
    end
end

% Due to the topological sort, the last node should correspond to the
% input partitioned array.
tf = supportsPreviewVector(end);
isGatherCheap = isPreviewVector(end);
end
