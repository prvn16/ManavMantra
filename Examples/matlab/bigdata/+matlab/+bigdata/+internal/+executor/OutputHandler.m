%OutputHandler
% Abstract base class for anything that can handle the outputs of a
% PartitionedArrayExecutor evaluation.

%   Copyright 2017 The MathWorks, Inc.

classdef (Abstract) OutputHandler < handle & matlab.mixin.Heterogeneous
    properties (SetAccess = immutable, Abstract)
        % A logical scalar that is true if and only if this output handler
        % benefits from streaming.
        IsStreamingHandler;
    end
    
    methods (Sealed)
        function handleOutput(objs, taskId, partitionIndex, numPartitions, isLastChunk, outputs)
            % Handle one set of chunks of output for a given task, running through
            % the list of output handlers until one consumes each of the tasks outputs.
            
            info = struct(...
                'PartitionIndex', partitionIndex, ...
                'NumPartitions', numPartitions, ...
                'IsLastChunk', isLastChunk);
            cancel = false;
            for ii = 1:size(outputs, 2)
                % Try all of the output handlers until we find the one
                % that can deal with this output.
                
                for kk = 1:numel(objs)
                    [isHandled, cancelRequested] = doHandle(objs(kk), ...
                        taskId, ii, info, outputs (:, ii));
                    cancel = cancel || cancelRequested;
                    if isHandled
                        break;
                    end
                end
            end
            
            if cancel
                % This will be bubbled up out of the back-end layers.
                % This is caught in the lazy evaluation layer, for example
                % LazyPartitionedArray/clientforeach.
                matlab.bigdata.internal.throw(message('MATLAB:bigdata:executor:ExecutionCancelled'));
            end
        end
        
        function handleBroadcastOutput(objs, taskId, outputs)
            % Handle the set of broadcast outputs for a given task, running through
            % the list of output handlers until one consumes each of the tasks outputs.
            
            isLastChunk = true;
            partitionIndex = 1;
            numPartitions = 1;
            
            objs.handleOutput(...
                taskId, ...
                partitionIndex, ...
                numPartitions, ...
                isLastChunk, ...
                outputs);
        end
    end
    
    methods (Abstract, Access = protected)
        % Handle one set of chunks for the output of index outputIndex
        % of task corresponding to taskId.
        %
        % Info will contain the fields:
        %  - PartitionIndex: The partition index corresponding to these
        %  chunks.
        %  - NumPartitions: The total number of partitions of this task.
        %  - IsLastChunk: A logical scalar that is true if and only if this
        %  is the last chunk of partition corresponding to PartitionIndex.
        doHandle(obj, taskId, outputIndex, info, output);
    end
end
