%StreamingOutputHandler
% An output handler that simply passes all chunks of one output to an
% underlying function handle.

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) DebugOutputHandler < handle
    properties (SetAccess = immutable)
        % Underlying OutputHandler objects that will handle the actual
        % work.
        OutputHandlers;
        
        % An ID string attached to all processor and processor factories
        % within the same execute invocation.
        ExecutionId;
        
        % A logical scalar that is true if and only if this output handler
        % benefits from streaming.
        IsStreamingHandler;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The execution task graph. This is used to convert Task ID to Task
        % object.
        TaskGraph;
        
        % An instance of DebugSession that will manage all listeners of
        % debug events.
        Session;
    end
    
    methods
        function obj = DebugOutputHandler(outputHandlers, taskGraph, executionId, session)
            % Construct a DebugProcessor that wraps the given output handlers.
            obj.OutputHandlers = outputHandlers;
            obj.TaskGraph = taskGraph;
            obj.ExecutionId = executionId;
            obj.Session = session;
            obj.IsStreamingHandler = any([outputHandlers.IsStreamingHandler]);
        end
    end
    
    % Methods overridden in the OutputHandler interface.
    methods
        function handleOutput(obj, taskId, partitionIndex, numPartitions, isLastChunk, output)
            % Handle one set of outputs being streamed to the client. This
            % notifies all debug listeners of the event then passes all
            % details to the actual OutputHandler objects.
            
            import matlab.bigdata.internal.debug.OutputData;
            
            outputData = OutputData;
            outputData.Task = iFindTask(taskId, obj.TaskGraph.OutputTasks);
            outputData.PartitionIndex = partitionIndex;
            outputData.NumPartitions = numPartitions;
            outputData.IsLastChunk = isLastChunk;
            outputData.Output = output;
            obj.Session.notifyDebugEvent('Output', obj, outputData);

            obj.OutputHandlers.handleOutput(taskId, partitionIndex, numPartitions, isLastChunk, output)
        end
        
        function handleBroadcastOutput(objs, taskId, outputs)
            % Handle one set of broadcast outputs returned to the client.
            % This notifies all debug listeners of the event then passes
            % all details to the actual OutputHandler objects.
            
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
end

function task = iFindTask(taskId, tasks)
% Find the given task in the list of all tasks.
for task = tasks(:)'
    if task.Id == string(taskId)
        return;
    end
end
assert(false, 'Failed to locate task of ID %s.', taskId);
end
