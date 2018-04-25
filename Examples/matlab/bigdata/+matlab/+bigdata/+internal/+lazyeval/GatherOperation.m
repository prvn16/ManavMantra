%GatherOperation
% An operation that brings one or more inputs to a single partition.

% Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) GatherOperation < matlab.bigdata.internal.lazyeval.AggregateFusibleOperation
    methods
        % The main constructor.
        function obj = GatherOperation(numVariables)
            numIntermediates = numVariables;
            numInputs = numVariables;
            numOutputs = numVariables;
            supportsPreview = true;
            dependsOnlyOnHead = true;
            obj = obj@matlab.bigdata.internal.lazyeval.AggregateFusibleOperation(...
                numIntermediates, numInputs, numOutputs, supportsPreview, dependsOnlyOnHead);
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function tasks = createExecutionTasks(obj, taskDependencies, inputFutureMap, ~)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            import matlab.bigdata.internal.lazyeval.PassthroughProcessor;
            import matlab.bigdata.internal.lazyeval.OutputBufferProcessDecorator;

            % If some of the inputs are not guaranteed a single
            % partition, we inject an all-to-one task to ensure only a
            % single partition. We do this per group of dependencies that
            % have the same partition strategy so that Spark does not
            % generate multiple reads per input from the same partition
            % strategy.
            tasks = ExecutionTask.empty();
            partitioningIds = iFindUniquePartitionings({taskDependencies.OutputPartitionStrategy});
            uniquePartIds = unique(partitioningIds(partitioningIds ~= 0));
            
            for partId = uniquePartIds(:)'
                isInPartitioning = (partitioningIds == partId);
                groupTaskDependencies = taskDependencies(isInPartitioning);
                if groupTaskDependencies(1).OutputPartitionStrategy.IsBroadcast
                    continue;
                end
                
                [inputFutureMap, preMap] = inputFutureMap.factorOutDependencies(find(isInPartitioning)); %#ok<FNDSB>
                
                factory = PassthroughProcessor.createFactory(preMap.NumOperationInputs);
                factory = InputMapProcessorDecorator.wrapFactory(factory, preMap);
                factory = OutputBufferProcessDecorator.wrapFactory(factory);
                newTask = ExecutionTask.createAllToOneTask(groupTaskDependencies, factory);
                
                taskDependencies = [taskDependencies(~isInPartitioning); newTask];
                partitioningIds(isInPartitioning) = [];
                tasks(end + 1) = newTask;%#ok<AGROW>
            end
            
            processorFactory = PassthroughProcessor.createFactory(obj.NumInputs);
            processorFactory = InputMapProcessorDecorator.wrapFactory(processorFactory, ...
                inputFutureMap);
            
            tasks(end + 1) = ExecutionTask.createBroadcastTask(taskDependencies, processorFactory, 'IsPassBoundary', true);
        end
    end
    
    % Methods overridden from the AggregateFusibleOperation interface.
    methods
        % Create the DataProcessor that will be applied to every chunk of
        % input before reduction.
        function factory = createPerChunkProcessorFactory(obj, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.lazyeval.DebroadcastProcessorDecorator;
            import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
            import matlab.bigdata.internal.lazyeval.OutputBufferProcessDecorator;
            import matlab.bigdata.internal.lazyeval.PassthroughProcessor;
            factory = PassthroughProcessor.createFactory(obj.NumInputs);
            factory = DebroadcastProcessorDecorator.wrapFactory(factory, isInputReplicated);
            factory = InputMapProcessorDecorator.wrapFactory(factory, inputFutureMap);
            factory = OutputBufferProcessDecorator.wrapFactory(factory);
        end
        
        % Create the DataProcessor that will be applied to reduce
        % consecutive chunks before communication.
        function factory = createCombineProcessorFactory(obj)
            factory = obj.createReduceProcessorFactory();
        end
        
        % Create the DataProcessor that will be applied to reduce
        % consecutive chunks after communication.
        function factory = createReduceProcessorFactory(obj)
            import matlab.bigdata.internal.lazyeval.PassthroughProcessor;
            factory = PassthroughProcessor.createFactory(1, obj.NumInputs);
        end
    end
end

function partitionIds = iFindUniquePartitionings(partitionStrategies)
% Generate a numeric ID for each partition strategy in the given cell array
% such that two partition strategies share the same ID if and only if they
% are the same.
uniquePartitionStrategies = {};

partitionIds = zeros(size(partitionStrategies));
for ii = 1:numel(partitionStrategies)
    if partitionStrategies{ii}.IsBroadcast
        continue;
    end
    
    for jj = 1:numel(uniquePartitionStrategies)
        if isequal(partitionStrategies{ii}, uniquePartitionStrategies{jj})
            partitionIds(ii) = jj;
            break;
        end
    end
    if partitionIds(ii) == 0
        uniquePartitionStrategies(end + 1) = partitionStrategies(ii); %#ok<AGROW>
        partitionIds(ii) = numel(uniquePartitionStrategies);
    end
end
end
