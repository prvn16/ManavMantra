%FusedSlicewiseOperation
% A composite of several slicewise or elementwise operations.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) FusedSlicewiseOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (SetAccess = immutable)
        % The function handle for the operation.
        FunctionHandle;
        
        % An error handler that will be invoked on each incompatible size
        % error during evaluation.
        IncompatibleErrorHandler;
        
        % A logical scalar that specifies if this slicewise operation is
        % allowed to use singleton expansion in the tall dimension.
        AllowTallDimExpansion = true;
    end
    
    methods
        % The main constructor.
        function obj = FusedSlicewiseOperation(options, functionHandle, incompatibleErrorHandler, numInputs, numOutputs)
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            obj.Options = options;
            obj.FunctionHandle = functionHandle;
            obj.IncompatibleErrorHandler = incompatibleErrorHandler;
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            
            isBroadcast = arrayfun(@(x)x.OutputPartitionStrategy.IsBroadcast, taskDependencies);
            if ~obj.AllowTallDimExpansion && any(isBroadcast) && ~all(isBroadcast)
                obj.FunctionHandle.throwAsFunction(MException(message('MATLAB:bigdata:array:IncompatibleTallStrictSize')));
            end
            
            processorFactory = ChunkwiseProcessor.createFactory(...
                obj.FunctionHandle, obj.NumOutputs, ...
                inputFutureMap, isInputReplicated, obj.AllowTallDimExpansion, ...
                'IncompatibleErrorHandler', obj.IncompatibleErrorHandler);
            processorFactory = obj.addGlobalState(processorFactory);

            task = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
        end
    end
end
