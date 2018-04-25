function paIndex = getAbsoluteSliceIndices(paIn)
% Get the absolute index of each slice relative to the start of the entire
% partitioned array.

%   Copyright 2017 The MathWorks, Inc.

partitionSizes = matlab.bigdata.internal.broadcast(...
    matlab.bigdata.internal.lazyeval.getPartitionSizes(paIn));
paIndex = partitionfun(@iCalculateAbsoluteSliceIndices, paIn, partitionSizes);
% The framework will assume out is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
if isPartitionIndependent(paIn)
    paIndex = markPartitionIndependent(paIndex);
end

function [isFinished, indices] = iCalculateAbsoluteSliceIndices(info, in, partitionSizes)
% For a given partition return the absolute index of each slice relative to
% the start of the entire partitioned array.
isFinished = info.IsLastChunk;
indices = (1:size(in,1))' - 1 ...
    + sum(partitionSizes(1 : info.PartitionId - 1)) ...
    + info.RelativeIndexInPartition;
