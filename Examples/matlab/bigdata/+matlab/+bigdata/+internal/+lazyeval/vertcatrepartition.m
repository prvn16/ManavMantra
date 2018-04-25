function varargout = vertcatrepartition(varargin)
%vertcatrepartition
% Implementation of the vertcatrepartition primitive for LazyPartitionedArray.

%   Copyright 2017 The MathWorks, Inc.

import matlab.bigdata.internal.broadcast;
import matlab.bigdata.internal.PartitionMetadata;

numPartitions = cellfun(@(x) x.numpartitions, varargin);
partitionMetadata = PartitionMetadata(sum(numPartitions));
partitionOffsets = cumsum(numPartitions) - numPartitions;

varargout=cell(size(varargin));
for ii = 1:numel(varargin)
    paIn = varargin{ii};
    paIndex = partitionfun(@iGetPartitionIndices, paIn, partitionOffsets(ii));
    varargout{ii} = repartition(partitionMetadata, paIndex, paIn);
end
end

function [isFinished, paIndex] = iGetPartitionIndices(info, x, partitionOffset)
% Get the partition index mapping array that map each slice to the correct partition
isFinished = info.IsLastChunk;
paIndex = info.PartitionId*ones(size(x,1),1) + partitionOffset;
end
