function varargout = shufflefixedchunkfun(opts, numSlicesPerChunk, fcn, varargin)
%SHUFFLEFIXEDCHUNKFUN A version of fixedchunkfun that performs communication
% between workers to ensure that all chunks except 1 is of size numSlicesPerChunk.
%
%   SHUFFLEFIXEDCHUNKFUN(numSlicesPerChunk, fcn, arg1, arg2, ...)
%   SHUFFLEFIXEDCHUNKFUN(opts, numSlicesPerChunk, fcn, arg1, arg2, ...)

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.bigdata.internal.broadcast;

% Strip out opts and fcn
[opts, numSlicesPerChunk, fcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, numSlicesPerChunk, fcn, varargin{:});
wasPartitionIndependent = isPartitionIndependent(varargin{:});

% NB: Only use specified options for the actual chunkfun call. The setup
% code that gets sizes etc. should use default options.

% We only need communication if the data spans more than one partition.
if iIsPartitioned(varargin{:})
    partitionSizes = partitionfun(@iGetPartitionSizes, varargin{:});
    
    [targetPartitionIndices, numSlicesToSend] = clientfun(@iCalculateCommunicationInfo, partitionSizes, numSlicesPerChunk);
    targetPartitionIndices = broadcast(targetPartitionIndices);
    numSlicesToSend = broadcast(numSlicesToSend);
    
    [varargin{:}] = iHeadBasedRepartition(targetPartitionIndices, numSlicesToSend, varargin{:});
end

[varargout{1 : nargout}] = fixedchunkfun(opts, numSlicesPerChunk, fcn, varargin{:});
if wasPartitionIndependent
    [varargout{:}] = markPartitionIndependent(varargout{:});
end

% Return true if and only if the inputs collectively span more than one
% partition.
function tf = iIsPartitioned(varargin)
tf = any(cellfun(@(t) numpartitions(hGetValueImpl(t)) ~= 1, varargin));

% TODO(g1473104): Partition sizes should be cached. We also need to
% determine what happens to this array when saved and loaded from a mat
% file.
function [hasFinished, sz] = iGetPartitionSizes(info, varargin)
% Calculate the partition sizes.
hasFinished = info.IsLastChunk;
if hasFinished
    localHeight = matlab.bigdata.internal.lazyeval.determineNumSlices(varargin{:});
    sz = info.RelativeIndexInPartition + localHeight - 1;
else
    sz = zeros(0, 1);
end

function [targetPartitionIndices, numSlicesToSend] = iCalculateCommunicationInfo(partitionSizes, numSlicesPerChunk)
% Calculate the target partition index and number of slices to send so that
% every partition has a multiple of numSlicesPerChunk or zero.
lastSliceIndices = cumsum(partitionSizes);
firstSliceIndices = [1; lastSliceIndices(1 : end-1) + 1];

nextChunkIndices = firstSliceIndices + mod(1 - firstSliceIndices, numSlicesPerChunk);
hasAtLeastOneChunk = nextChunkIndices <= lastSliceIndices;

targetPartitionIndices = ones(size(partitionSizes));
for ii = 2:numel(targetPartitionIndices)
    if hasAtLeastOneChunk(ii - 1)
        targetPartitionIndices(ii) = ii - 1;
    else
        targetPartitionIndices(ii) = targetPartitionIndices(ii - 1);
    end
end

numSlicesToSend = min(nextChunkIndices - firstSliceIndices, partitionSizes);

function varargout = iHeadBasedRepartition(targetPartitionIndices, numSlicesToSend, varargin)
% Given a single target partition index and number of slices value per
% partition, for each partition send the corresponding number of slices
% and append to the end of the corresponding target partition index.
[varargout{1 : numel(varargin)}] = wrapUnderlyingMethod(@iHeadBasedRepartitionImpl, {}, ...
    targetPartitionIndices, numSlicesToSend, varargin{:});
for ii = 1:numel(varargin)
    varargout{ii}.Adaptor = varargin{ii}.Adaptor;
end


function varargout = iHeadBasedRepartitionImpl(targetPartitionIndices, numSlicesToSend, varargin)
% Given a single target partition index and number of slices value per
% partition, for each partition send the corresponding number of slices
% and append to the end of the corresponding target partition index.

slicesToMove = cell(size(varargin));
[movedPartitionIndices, slicesToMove{:}] = partitionfun(@iGetHeadSlices, targetPartitionIndices, numSlicesToSend, varargin{:});
[slicesToMove{:}] = repartition(movedPartitionIndices.PartitionMetadata, movedPartitionIndices, slicesToMove{:});

varargout = cell(size(varargin));
[varargout{:}] = generalpartitionfun(@iRepartitionHead, numSlicesToSend, varargin{:}, slicesToMove{:});

function [hasFinished, partitionIndices, varargout] = iGetHeadSlices(info, targetPartitionIndex, totalNumSlicesToSend, varargin)
% Return the required number of slices from the head of each partition as
% well as the partition index where the slice must be sent.

targetPartitionIndex = targetPartitionIndex(info.PartitionId);
totalNumSlicesToSend = totalNumSlicesToSend(info.PartitionId);

localHeight = matlab.bigdata.internal.lazyeval.determineNumSlices(varargin{:});
numSlicesLeft = max(totalNumSlicesToSend - (info.RelativeIndexInPartition - 1), 0);
numSlicesToSend = min(localHeight, numSlicesLeft);

hasFinished = info.IsLastChunk || (localHeight == numSlicesLeft);
partitionIndices = targetPartitionIndex * ones(numSlicesToSend, 1);
varargout = cell(size(varargin));
for ii = 1:numel(varargin)
    varargout{ii} = matlab.bigdata.internal.util.indexSlices(varargin{ii}, 1:numSlicesToSend);
end

function [hasFinished, unusedInputs, varargout] = iRepartitionHead(info, varargin)
% Merge each partition with data sent from its successors, while removing
% data that has been sent to a predecessor.

% The totalNumSlicesToRemove input is part of varargin in order that varargin
% aligns with info.IsLastChunk, info.RelativeIndexInPartition and unusedInputs.
totalNumSlicesToRemove = varargin{1};
totalNumSlicesToRemove = totalNumSlicesToRemove(info.PartitionId);

% For each input, varargin will contain one chunk from the local partition
% and potentially one chunk from a successor partition. It will also
% contain totalNumSlicesToRemove that we need to ignore here.
numLocalInputs = (numel(varargin) - 1) / 2;
isLocalInput = false(1, numel(varargin));
isLocalInput(1 + (1 : numLocalInputs)) = true;
isSuccessorInput = false(1, numel(varargin));
isSuccessorInput(1 + numLocalInputs + (1 : numLocalInputs)) = true;

% All of these slices have been sent to the predecessor partition.
numSlicesLeftToRemove = max(totalNumSlicesToRemove - (info.RelativeIndexInPartition(isLocalInput) - 1), 0);
if any(numSlicesLeftToRemove > 0)
    varargin(isLocalInput) = cellfun(@iRemoveFirstSlices, varargin(isLocalInput), ...
        num2cell(numSlicesLeftToRemove), 'UniformOutput', false);
end

hasFinished = all(info.IsLastChunk);
unusedInputs = cell(size(varargin));
isLocalDataFinished = all(info.IsLastChunk(isLocalInput));
if isLocalDataFinished
    varargout = cellfun(@vertcat, varargin(isLocalInput), varargin(isSuccessorInput), 'UniformOutput', false);
else
    varargout = varargin(isLocalInput);
    unusedInputs(isSuccessorInput) = varargin(isSuccessorInput);
end

function data = iRemoveFirstSlices(data, numSlices)
% Remove the first numSlices slices from input data.
data(1 : min(numSlices, end), :) = [];
