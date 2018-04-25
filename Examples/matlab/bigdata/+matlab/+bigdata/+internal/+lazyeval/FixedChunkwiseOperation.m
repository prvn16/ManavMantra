%FixedChunkwiseOperation
% An operation that acts on each chunk of data such that the chunking is
% fixed.

% Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) FixedChunkwiseOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (SetAccess = immutable)
        % The function handle for the operation.
        FunctionHandle;
        
        % The number of slices to be required for each chunk.
        NumSlices;
    end
    
    methods
        % The main constructor.
        function obj = FixedChunkwiseOperation(options, numSlices, functionHandle, numInputs, numOutputs)
            assert(isnumeric(numSlices) && isscalar(numSlices) && numSlices > 0 && mod(numSlices, 1) == 0);
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            obj.NumSlices = numSlices;
            obj.FunctionHandle = functionHandle;
            obj.Options = options;
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.BufferedZipProcessDecorator;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            
            fh = TaggedArrayFunction.wrap(obj.FunctionHandle, obj.Options);
            processorFactory = ChunkwiseProcessor.createSimpleFactory(...
                fh, numel(isInputReplicated), obj.NumOutputs);
            processorFactory = BufferedZipProcessDecorator.wrapFactory(processorFactory, ...
                obj.NumOutputs, isInputReplicated, obj.FunctionHandle.ErrorStack, ...
                'MinNumSlices', obj.NumSlices, ...
                'MaxNumSlices', obj.NumSlices, ...
                'AllowTallDimExpansion', false);
            processorFactory = InputMapProcessorDecorator.wrapFactory(processorFactory, ...
                inputFutureMap);

            processorFactory = obj.addGlobalState(processorFactory);

            task = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
        end
    end
end
