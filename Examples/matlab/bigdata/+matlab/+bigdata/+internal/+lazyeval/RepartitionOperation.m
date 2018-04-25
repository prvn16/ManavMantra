%RepartitionOperation
% An operation that does communication between workers to move elements of
% one or more partitioned arrays into a chosen partitioning strategy.
%

% Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) RepartitionOperation < matlab.bigdata.internal.lazyeval.Operation
    
    properties (SetAccess = immutable)
        % The desired partition strategy after the communication has occurred.
        %
        % This can either be:
        %   - A datastore, Where the partition strategy is exactly matching
        %   that datastore.
        %   - The desired number of partitions itself.
        %   - Empty, which represents letting the executor decide.
        OutputPartitionStrategy;
    end
    
    methods
        function obj = RepartitionOperation(partitionStrategy, numVariables)
            % The main constructor.
            numInputs = numVariables + 1;
            numOutputs = numVariables;
            supportsPreview = false;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            obj.OutputPartitionStrategy = partitionStrategy;
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.executor.PartitionStrategy;
            import matlab.bigdata.internal.lazyeval.BufferedZipProcessDecorator;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            import matlab.bigdata.internal.lazyeval.RepartitionProcessor;
            
            submissionStack = matlab.bigdata.BigDataException.getClientStack();
            processorFactory = RepartitionProcessor.createFactory(obj.NumOutputs);
            processorFactory = BufferedZipProcessDecorator.wrapFactory(processorFactory, ...
                obj.NumOutputs, isInputReplicated, submissionStack, ...
                'AllowTallDimExpansion', false);
            processorFactory = InputMapProcessorDecorator.wrapFactory(processorFactory, ...
                inputFutureMap);
            
            if obj.OutputPartitionStrategy.IsBroadcast
                % We have to do this because Any-to-Any communication to
                % broadcast partition strategy is not allowed.
                task = ExecutionTask.createBroadcastTask(taskDependencies, processorFactory);
            else
                task = ExecutionTask.createAnyToAnyTask(taskDependencies, processorFactory, ...
                    'OutputPartitionStrategy', obj.OutputPartitionStrategy);
            end
        end
    end
end
