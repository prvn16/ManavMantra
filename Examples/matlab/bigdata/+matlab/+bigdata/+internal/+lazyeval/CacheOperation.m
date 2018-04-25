%CacheOperation
% An operation that represents caching.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) CacheOperation < matlab.bigdata.internal.lazyeval.Operation
    
    properties (SetAccess = immutable)
        % A key to the cache entries that correspond to the output of this
        % operation.
        CacheEntryKey;
    end
    
    methods
        % The main constructor.
        function obj = CacheOperation()
            import matlab.bigdata.internal.executor.CacheEntryKey;
            numInputs = 1;
            numOutputs = 1;
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
            obj.CacheEntryKey = CacheEntryKey();
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function tasks = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            import matlab.bigdata.internal.FunctionHandle;
            
            fh = FunctionHandle(@(varargin) deal(varargin{:}));
            processorFactory = ChunkwiseProcessor.createFactory(...
                fh, obj.NumOutputs, inputFutureMap, isInputReplicated);
            
            if obj.CacheEntryKey.IsValid
                tasks = ExecutionTask.createSimpleTask(taskDependencies, processorFactory, ...
                    'CacheLevel', 'All', 'CacheEntryKey', obj.CacheEntryKey);
            else
                tasks = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
            end
        end
    end
end
