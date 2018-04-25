function out = extractTail(partitionedArray, n)
%EXTRACTTAIL Extract the tail (last rows) of the provided tall array.
%
%   H = extractTail(partitionedArray, n) extracts the tail (last rows)
%   of the provided partition array of size up-to n in the tall dimension.
%

%   Copyright 2016-2017 The MathWorks, Inc.

% TODO (g1337016): This could be more efficient if there was a way to do
% execution in reverse order.
wasPartitionIndependent = isPartitionIndependent(partitionedArray);
[partitionedArray, partitionedSliceIds] = partitionfun(@(info, v) iLastNWithIdGeneration(n, v, info), partitionedArray);
[out, ~] = reducefun(@(v, s) iLastN(n, v, s), partitionedArray, partitionedSliceIds);
% The framework will assume out is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
if wasPartitionIndependent
    out = markPartitionIndependent(out);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, sliceId] = iLastN(n, v, sliceId)
% We sort on absolute index of the original array as during a reduction,
% v is not guaranteed to be in order. For example, partition 2 might be
% processed before partition 1.
[sliceId, idx] = sortrows(sliceId);
idx = idx(max(end - n + 1, 1) : end);
sliceId = sliceId(max(end - n + 1, 1) : end, 1);
out = matlab.bigdata.internal.util.indexSlices(v, idx);
end

function [hasFinished, out, sliceId] = iLastNWithIdGeneration(n, v, info)
h = size(v, 1);
% This pair of indices is equivalent to the absolute index of the slice
% with respect to the ordering given by sortrows.
sliceId = [info.PartitionId * ones(h, 1), info.RelativeIndexInPartition - 1 + (1:h)'];
hasFinished = info.IsLastChunk;
[out, sliceId] = iLastN(n, v, sliceId);
end
