function out = extractHead(partitionedArray, n)
%EXTRACTHEAD Extract the head (first rows) of the provided tall array.
%
%   H = extractHead(partitionedArray, n) extracts the head (first rows)
%   of the provided partition array of size up-to n in the tall dimension.
%

%   Copyright 2015-2017 The MathWorks, Inc.

BIG_N = 1e5;
wasPartitionIndependent = isPartitionIndependent(partitionedArray);
if isprop(partitionedArray,'HasPreviewData') && partitionedArray.HasPreviewData ...
        && n<=size(partitionedArray.PreviewData,1)
    % Shortcut when we already have the data locally
    localOut = matlab.bigdata.internal.util.indexSlices(partitionedArray.PreviewData, 1:n);
    out = matlab.bigdata.internal.lazyeval.LazyPartitionedArray.createFromConstant(localOut);
    return;
    
elseif numpartitions(partitionedArray) * n > BIG_N
    % For Large N, minimize communication by using a mapping of partitions
    % to number of slices to include in the head so that we only get the rows we need 
    [numSlices, partitionId] = partitionheadfun(@(info, v) iGetChunkSize(info, v, n), partitionedArray);
    [numSlices, partitionId] = clientfun(@(ns, p) iComputePartitionSlices(ns, p, n), numSlices, partitionId);
    partitionId = matlab.bigdata.internal.broadcast(partitionId);
    numSlices = matlab.bigdata.internal.broadcast(numSlices);
    [partitionedArray, partitionedSliceIds] = partitionheadfun(@iSelectN, partitionedArray, partitionId, numSlices);
else
    [partitionedArray, partitionedSliceIds] = partitionheadfun(@(info, v) iFirstNWithEarlyExit(n, v, info), partitionedArray);
end

[out, ~] = reducefun(@(v, s) iFirstN(n, v, s), partitionedArray, partitionedSliceIds);
% The framework will assume out is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
if wasPartitionIndependent
    out = markPartitionIndependent(out);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, sliceId] = iFirstN(n, v, sliceId)
% We sort on absolute index of the original array as during a reduction,
% v is not guaranteed to be in order. For example, partition 2 might be
% processed before partition 1.

[sliceId, idx] = sortrows(sliceId);
sliceId = sliceId(1:min(n, end), :);
idx = idx(1:min(n, end));

out = matlab.bigdata.internal.util.indexSlices(v, idx);
end


function [hasFinished, out, sliceId] = iFirstNWithEarlyExit(n, v, info)
[hasFinished, numSlicesToEmit] = iGetChunkSize(info, v, n);
% This pair of indices is equivalent to the absolute index of the slice
% with respect to the ordering given by sortrows.
sliceId = [info.PartitionId * ones(numSlicesToEmit, 1), info.RelativeIndexInPartition - 1 + (1:numSlicesToEmit)'];
[out, sliceId] = iFirstN(numSlicesToEmit, v, sliceId);
end

function [hasFinished, numSlicesToEmit, partitionId] = iGetChunkSize(info, v, N)
numSlices = size(v, 1);
numRemainingSlices = max(N - info.RelativeIndexInPartition + 1, 0);
numSlicesToEmit = min(numRemainingSlices, numSlices);

if numRemainingSlices == 0
   hasFinished = true;
   numSlicesToEmit = zeros(0,1);
   partitionId = zeros(0,1);
else
    partitionId = info.PartitionId;
    hasFinished = info.IsLastChunk || (numRemainingSlices == numSlicesToEmit);
end
end

function [numSlicesFromPartition, partitionsToSelectFrom] = iComputePartitionSlices(numSlices, partitionIds, N)
pIds = unique(partitionIds);
numSlicesFromPartition = zeros(size(pIds));
for ii=1:numel(pIds)
    numSlicesFromPartition(ii) = sum(numSlices(partitionIds == pIds(ii)));
end

numSlicesFromPartition(cumsum(numSlicesFromPartition) > N) = [];
partitionsToSelectFrom = pIds(cumsum(numSlicesFromPartition) <= N);
end

function [hasFinished, out, sliceId] = iSelectN(info, v, p, n)
N = n(p==info.PartitionId);
if isempty(N)
    hasFinished = true;
    out = matlab.bigdata.internal.util.indexSlices(v, []);
    sliceId = zeros(0, 2);
else
    [hasFinished, out, sliceId] = iFirstNWithEarlyExit(N, v, info);
end
end