%GeneralizedPartitionwiseOperation
% An operation that acts on each partition of data. This generalized
% version supports multiple inputs of different sizes.

% Copyright 2017 The MathWorks, Inc.

classdef (Sealed) GeneralizedPartitionwiseOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (SetAccess = immutable)
        % The function handle for the operation.
        FunctionHandle;
    end
    
    methods
        % The main constructor.
        function obj = GeneralizedPartitionwiseOperation(options, functionHandle, numInputs, numOutputs)
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            obj.FunctionHandle = functionHandle;
            obj.Options = options;
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.GeneralizedPartitionwiseProcessor;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            
            fh = TaggedArrayFunction.wrap(obj.FunctionHandle, obj.Options);
            processorFactory = GeneralizedPartitionwiseProcessor.createFactory(...
                fh, obj.NumOutputs, inputFutureMap, isInputReplicated);
            processorFactory = obj.addGlobalState(processorFactory);
            
            task = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
        end
    end
end
