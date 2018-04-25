%AggregateOperation
% An operation that reduces some transformation of the input data to a
% single chunk.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) AggregateOperation < matlab.bigdata.internal.lazyeval.AggregateFusibleOperation
    properties (SetAccess = immutable)
        % The function handle to be applied per input chunk of the data.
        PerChunkFunctionHandle;
        
        % The function handle to be applied to perform the reduction.
        ReduceFunctionHandle;
    end
    
    methods
        % The main constructor.
        function obj = AggregateOperation(options, perChunkFunctionHandle, reduceFunctionHandle, numInputs, numOutputs)
            numIntermediates = numOutputs;
            obj = obj@matlab.bigdata.internal.lazyeval.AggregateFusibleOperation(numIntermediates, numInputs, numOutputs);
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
            
            perChunkProcessorFactory = obj.createPerChunkProcessorFactory(inputFutureMap, isInputReplicated);
            perChunkProcessorFactory = obj.addGlobalState(perChunkProcessorFactory);
            
            reduceProcessorFactory = obj.createReduceProcessorFactory();

            % Per-Partition, Per-Chunk
            tasks(1) = ExecutionTask.createSimpleTask(taskDependencies, perChunkProcessorFactory);
            
            % Per-Partition, Across chunk boundary, with output going to a
            % single partition.
            if ~tasks(1).OutputPartitionStrategy.IsDataReplicated
                tasks(2) = ExecutionTask.createAllToOneTask(tasks(1), reduceProcessorFactory, 'IsPassBoundary', true);
            end
            
            % Across chunk and partition boundary. This is broadcast in
            % to allow the result to be used by any partition in following
            % tasks.
            tasks(end + 1) = ExecutionTask.createBroadcastTask(tasks(end), reduceProcessorFactory, 'IsPassBoundary', true);
        end
    end
    
    % Methods overridden from the AggregateFusibleOperation interface.
    methods
        % Create the DataProcessor that will be applied to every chunk of
        % input before reduction.
        function factory = createPerChunkProcessorFactory(obj, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            fh = TaggedArrayFunction.wrap(obj.PerChunkFunctionHandle, obj.Options);
            factory = ChunkwiseProcessor.createFactory(...
                fh, obj.NumOutputs, ...
                inputFutureMap, isInputReplicated);
            factory = obj.addGlobalState(factory);
        end
        
        % Create the DataProcessor that will be applied to reduce
        % consecutive chunks before communication.
        function factory = createCombineProcessorFactory(obj)
            factory = obj.createReduceProcessorFactory();
        end
        
        % Create the DataProcessor that will be applied to reduce
        % consecutive chunks after communication.
        function factory = createReduceProcessorFactory(obj)
            import matlab.bigdata.internal.lazyeval.ReduceProcessor;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            fh = TaggedArrayFunction.wrap(obj.ReduceFunctionHandle, obj.Options);
            factory = ReduceProcessor.createFactory(...
                fh, obj.NumOutputs);
            factory = obj.addGlobalState(factory);
        end
    end
end

