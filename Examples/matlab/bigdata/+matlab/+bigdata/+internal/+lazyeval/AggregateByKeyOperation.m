%AggregateByKeyOperation
% An operation that reduces some transformation of the input data to a
% single chunk per key.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) AggregateByKeyOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (SetAccess = immutable)
        % The function handle to be applied per input chunk of the data.
        PerChunkFunctionHandle;
        
        % The function handle to be applied to perform the reduction.
        ReduceFunctionHandle;
    end
    
    methods
        % The main constructor.
        function obj = AggregateByKeyOperation(options, perChunkFunctionHandle, reduceFunctionHandle, numInputs, numOutputs)
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs);
            obj.PerChunkFunctionHandle = perChunkFunctionHandle;
            obj.ReduceFunctionHandle = reduceFunctionHandle;
            obj.Options = options;
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function tasks = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.ReduceProcessor;
            import matlab.bigdata.internal.lazyeval.ReduceByKeyProcessor;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            import matlab.bigdata.internal.lazyeval.GroupedByKeyFunction;
            
            isBroadcast = arrayfun(@(x)x.OutputPartitionStrategy.IsBroadcast, taskDependencies);
            if any(isBroadcast) && ~all(isBroadcast)
                obj.PerChunkFunctionHandle.throwAsFunction(MException(message('MATLAB:bigdata:array:IncompatibleTallStrictSize')));
            end
            
            perChunkFunction = obj.PerChunkFunctionHandle;
            perChunkFunction = TaggedArrayFunction.wrap(perChunkFunction, obj.Options);
            perChunkFunction = GroupedByKeyFunction.wrap(perChunkFunction);
            
            reduceFunction = obj.ReduceFunctionHandle;
            reduceFunction = TaggedArrayFunction.wrap(reduceFunction, obj.Options);
            reduceFunction = GroupedByKeyFunction.wrap(reduceFunction);
            
            allowTallDimExpansion = false;
            perChunkProcessorFactory = ChunkwiseProcessor.createFactory(...
                perChunkFunction, obj.NumOutputs, ...
                inputFutureMap, isInputReplicated, allowTallDimExpansion);
            
            perChunkProcessorFactory = obj.addGlobalState(perChunkProcessorFactory);
            
            reduceProcessorFactory = ReduceByKeyProcessor.createFactory(...
                reduceFunction, obj.NumOutputs);

            reduceProcessorFactory = obj.addGlobalState(reduceProcessorFactory );
            
            % Per-Partition, Per-Chunk
            tasks(1) = ExecutionTask.createSimpleTask(taskDependencies, perChunkProcessorFactory);
            
            % Per-Partition, Across all chunks
            if ~tasks(1).OutputPartitionStrategy.IsBroadcast
                tasks(2) = ExecutionTask.createAnyToAnyTask(tasks(1), reduceProcessorFactory, 'IsPassBoundary', true);
            end
            
            % Across all remaining boundaries
            tasks(end + 1) = ExecutionTask.createSimpleTask(tasks(end), reduceProcessorFactory, 'IsPassBoundary', true);
        end
    end
end
