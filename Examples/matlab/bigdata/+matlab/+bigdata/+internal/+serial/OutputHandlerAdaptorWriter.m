%OutputHandlerAdaptorWriter
% An adaptor around the OutputHandler interface to the Writer interface.

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) OutputHandlerAdaptorWriter < matlab.bigdata.internal.io.Writer
    properties (GetAccess = private, SetAccess = immutable)
        % The ID of the ExecutionTask associated with this output.
        TaskId;
        
        % The partition index associated with this output.
        PartitionIndex;
        
        % Total number of partitions for this task.
        NumPartitions;
        
        % An array of output handlers that will consume the output chunk.
        OutputHandlers;
    end
    
    properties (Access = private)
        % The number of outputs of the corresponding task.
        NumOutputs;
    end
    
    methods
        function obj = OutputHandlerAdaptorWriter(taskId, partitionIndex, numPartitions, outputHandlers)
            obj.TaskId = taskId;
            obj.PartitionIndex = partitionIndex;
            obj.NumPartitions = numPartitions;
            obj.OutputHandlers = outputHandlers;
        end
        
        %ADD Handle a given chunk of output.
        function add(obj, ~, outputs)
            if isempty(obj.NumOutputs)
                obj.NumOutputs = size(outputs, 2);
            end
            
            isLastChunk = false;
            obj.OutputHandlers.handleOutput(...
                obj.TaskId, ...
                obj.PartitionIndex, ...
                obj.NumPartitions, ...
                isLastChunk, ...
                outputs);
        end
        
        %COMMIT Commit all output.
        function commit(obj)
            assert(~isempty(obj.NumOutputs), ...
                'A partition completed without emitting any output');
            
            isLastChunk = true;
            obj.OutputHandlers.handleOutput(...
                obj.TaskId, ...
                obj.PartitionIndex, ...
                obj.NumPartitions, ...
                isLastChunk, ...
                cell(0, obj.NumOutputs));
        end
    end
end
