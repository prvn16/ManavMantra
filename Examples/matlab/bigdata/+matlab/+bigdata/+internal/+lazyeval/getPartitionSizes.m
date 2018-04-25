function paPartitionSizes = getPartitionSizes(paIn)
% Get an array where each element is the height of the partition of
% corresponding index.

%   Copyright 2017 The MathWorks, Inc.

% TODO(g1473104): Partition sizes should be cached. We also need to
% determine what happens to this array when saved and loaded from a mat
% file.
paPartitionSizes = partitionfun(@iGetPartitionSize, paIn);

function [isFinished, sz] = iGetPartitionSize(info, x)
% Get the partition size for a single partition
isFinished = info.IsLastChunk;
if isFinished
    sz = info.RelativeIndexInPartition + size(x, 1) - 1;
else
    sz = zeros(0, 1);
end
