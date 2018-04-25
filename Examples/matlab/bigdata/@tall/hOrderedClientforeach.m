function hOrderedClientforeach(workerFcn, clientFcn, varargin)
% Perform a clientforeach operation with the constraint that all input
% will be in order of partition index. All data for partition N will be
% passed to the client function before any data from partition N + 1 does.

%   Copyright 2017 The MathWorks, Inc.

hClientforeach(workerFcn, iCreateBufferedFcn(clientFcn), varargin{:});
end

function bufferedClientFcn = iCreateBufferedFcn(clientFcn)
import matlab.bigdata.internal.FunctionHandle
import matlab.bigdata.internal.util.StatefulFunction
bufferedClientFcn = FunctionHandle(StatefulFunction(@nFcn));

    function [obj, hasFinished] = nFcn(obj, unorderedInfo, value)
        if isempty(obj)
            % The partition index of the next chunk to be passed to
            % clientFcn. This is held as an optimization, so we don't loop
            % through all partitions on all invocations of this function.
            obj.NextOrderedPartitionIndex = 1;
            % A buffer for holding chunks that have arrived before the
            % current input partition has finished processing. This is a
            % cell array of one ExternalInputBuffer per partition. A cell
            % can be empty if no data for a given partition has arrived.
            obj.Buffers = cell(1, unorderedInfo.NumPartitions);
        end
        
        % Create an info struct to pass to the underlying function handle.
        % This has to make it look like the data arrived in order.
        orderedInfo = struct(...
            'PartitionId', obj.NextOrderedPartitionIndex, ...
            'PartitionIndex', obj.NextOrderedPartitionIndex, ...
            'CompletedPartitions', unorderedInfo.CompletedPartitions, ...
            'NumPartitions', unorderedInfo.NumPartitions, ...
            'IsLastChunk', false);
        orderedInfo.CompletedPartitions(obj.NextOrderedPartitionIndex : end) = false;
        
        partitionIndex = obj.NextOrderedPartitionIndex;
        if unorderedInfo.PartitionIndex == partitionIndex
            % If this chunk is for the current partition, just add it.
            orderedInfo.IsLastChunk = unorderedInfo.IsLastChunk;
            orderedInfo.CompletedPartitions(partitionIndex) = unorderedInfo.IsLastChunk;
            hasFinished = feval(clientFcn, orderedInfo, value);
            if hasFinished
                return;
            end
        else
            % Otherwise, buffer it.
            obj.Buffers{unorderedInfo.PartitionIndex} = iAddToBuffer(obj.Buffers{unorderedInfo.PartitionIndex}, {value});
            hasFinished = false;
        end
        
        % Now drain all existing buffers until we reach an incomplete
        % partition.
        startPartition = obj.NextOrderedPartitionIndex;
        endPartition = unorderedInfo.NumPartitions;
        for partitionIndex = startPartition : endPartition
            orderedInfo.PartitionId = partitionIndex;
            orderedInfo.PartitionIndex = partitionIndex;
            
            buffer = obj.Buffers{partitionIndex};
            if ~isempty(buffer)
                isPartitionComplete = unorderedInfo.CompletedPartitions(partitionIndex);
                isLastBufferedChunk = false;
                while ~isLastBufferedChunk
                    [isLastBufferedChunk, value] = buffer.getnext();
                    % These are set to false in case value consists of more
                    % than one cell from the same partition. We must pass
                    % these one by one to the function handle.
                    orderedInfo.CompletedPartitions(partitionIndex) = false;
                    orderedInfo.IsLastChunk = false;
                    numValues = numel(value);
                    isLastChunk = isPartitionComplete && isLastBufferedChunk;
                    for ii = 1 : numValues
                        if ii == numValues && isLastChunk
                            orderedInfo.CompletedPartitions(partitionIndex) = true;
                            orderedInfo.IsLastChunk = true;
                        end
                        hasFinished = feval(clientFcn, orderedInfo, value{ii});
                        if hasFinished
                            return;
                        end
                    end
                    orderedInfo.CompletedPartitions(partitionIndex) = isLastChunk;
                end
                obj.Buffers{partitionIndex} = [];
            end
            
            if ~unorderedInfo.CompletedPartitions(partitionIndex)
                break;
            end
        end
        obj.NextOrderedPartitionIndex = partitionIndex;
    end
end

function buffer = iAddToBuffer(buffer, value)
% Add a chunk to the given buffer. This will create a buffer object if one
% does not exist.
if isempty(buffer)
    buffer = matlab.bigdata.internal.io.ExternalInputBuffer();
end
buffer.add(value);
end
