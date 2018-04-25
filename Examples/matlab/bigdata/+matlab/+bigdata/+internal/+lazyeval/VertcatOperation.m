%VertcatOperation
% An operation for vertical concatenation.

% Copyright 2017 The MathWorks, Inc.

classdef (Sealed) VertcatOperation < matlab.bigdata.internal.lazyeval.Operation
    
    properties (SetAccess = immutable)
        % The function handle for error handling
        FunctionHandle;
    end
        
    methods
        % The main constructor.
        function obj = VertcatOperation(functionHandle, numInputs, numOutputs)
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            obj.FunctionHandle = functionHandle;
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.VertcatProcessor;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            
            numVariables = numel(isInputReplicated);
            processorFactory = VertcatProcessor.createFactory(obj.FunctionHandle, numVariables);
            processorFactory = InputMapProcessorDecorator.wrapFactory(processorFactory, inputFutureMap);
            
            task = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
            
            % TODO (g1538008): Update progress reporting to correctly report the
            % number of passes over the entire data
        end
    end
end