%ReadOperation
% An operation that reads from a datastore.

% Copyright 2015-2016 The MathWorks, Inc.

classdef (Sealed) ReadOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (SetAccess = immutable)
        % The datastore object that underpins this read operation.
        Datastore;
    end
    
    methods
        % The main constructor.
        function obj = ReadOperation(datastore, numOutputs)
            numInputs = 0;
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            obj.Datastore = datastore;
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, ~, ~, ~)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.executor.PartitionStrategy;
            import matlab.bigdata.internal.lazyeval.ReadProcessor;
            
            task = ExecutionTask.createSimpleTask([], ReadProcessor.createFactory(obj.Datastore),...
                'ExecutionPartitionStrategy', PartitionStrategy.create(obj.Datastore));
        end
    end
end
