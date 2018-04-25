%TernaryOperation
% An operation that selects between two inputs based on a deferred scalar
% logical input.

% Copyright 2016-2017 The MathWorks, Inc.

classdef TernaryOperation < matlab.bigdata.internal.lazyeval.Operation
    methods
        % The main constructor.
        function obj = TernaryOperation()
            numInputs = 3;
            numOutputs = 1;
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(numInputs, numOutputs, supportsPreview);
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function tasks = createExecutionTasks(~, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            import matlab.bigdata.internal.FunctionHandle;

            fh = TaggedArrayFunction.wrap(FunctionHandle(@iTernary));
            numOutputs = 1;
            processorFactory = ChunkwiseProcessor.createFactory(...
                fh, numOutputs, inputFutureMap, isInputReplicated);
            
            tasks = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
        end
    end
end

function out = iTernary(condition, ifTrue, ifFalse)
if ~islogical(condition) || ~isscalar(condition)
    sizeStr = join(string(size(condition)), 'x');
    error(message('MATLAB:bigdata:array:InvalidTernaryLogical', class(condition), char(sizeStr)));
elseif condition
    out = ifTrue;
else
    out = ifFalse;
end
end