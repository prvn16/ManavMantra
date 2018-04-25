%FusedAggregateByKeyOperation
% An operation that reduces some transformation of the input data to a
% single chunk per key. This version allows multiple key variables to be
% passed in. Each key variable will have a number of value variables that
% must match slicewise similar to AggregateByKeyOperation. However,
% variables with different Key variables do not need to match, for input or
% for output.

% Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) FusedAggregateByKeyOperation < matlab.bigdata.internal.lazyeval.Operation
    properties (SetAccess = immutable)
        % A cell array of function handles to be applied per input chunk of the data.
        PerChunkFunctionHandles;
        
        % A cell array of function handles to be applied to perform the reduction.
        ReduceFunctionHandles;
        
        % A numeric vector of the NumInputs per aggregate by key operation.
        NumInputsPerOperation;
        
        % A numeric vector of the NumOutputs per aggregate by key operation.
        NumOutputsPerOperation;
    end
    
    methods (Static)
        % Fuse a collection of AggregateByKeyOperation and
        % FusedAggregateByKeyOperation objects into a single
        % FusedAggregateByKeyOperation.
        %
        % The inputs of this operation is the concatenation of the inputs
        % of varargin. Similarly, the outputs of this operation is the
        % concatenation of the outputs of varargin.
        function obj = fuse(varargin)
            import matlab.bigdata.internal.lazyeval.FusedAggregateByKeyOperation;
            
            perChunkFunctionHandles = cell(1, numel(varargin));
            reduceFunctionHandles = cell(1, numel(varargin));
            numInputsPerOperation = cell(1, numel(varargin));
            numOutputsPerOperation = cell(1, numel(varargin));
            for ii = 1:numel(varargin)
                input = varargin{ii};
                
                if isa(input, 'matlab.bigdata.internal.lazyeval.AggregateByKeyOperation')
                    perChunkFunctionHandles{ii} = {input.PerChunkFunctionHandle};
                    reduceFunctionHandles{ii} = {input.ReduceFunctionHandle};
                    numInputsPerOperation{ii} = input.NumInputs;
                    numOutputsPerOperation{ii} = input.NumOutputs;
                elseif isa(input, 'matlab.bigdata.internal.lazyeval.FusedAggregateByKeyOperation')
                    perChunkFunctionHandles{ii} = input.PerChunkFunctionHandles;
                    reduceFunctionHandles{ii} = input.ReduceFunctionHandles;
                    numInputsPerOperation{ii} = input.NumInputsPerOperation;
                    numOutputsPerOperation{ii} = input.NumOutputsPerOperation;
                else
                    assert(false, 'FusedAggregateByKeyOperation passed unsupported type ''%s''.', class(input));
                end
            end
            obj = FusedAggregateByKeyOperation(...
                [perChunkFunctionHandles{:}], [reduceFunctionHandles{:}], ...
                [numInputsPerOperation{:}], [numOutputsPerOperation{:}]);
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        % Create a collection of ExecutionTask objects that represent this
        % operation given the provided inputs.
        function tasks = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.FusedReduceByKeyProcessor;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            
            isBroadcast = arrayfun(@(x)x.OutputPartitionStrategy.IsBroadcast, taskDependencies);
            if any(isBroadcast) && ~all(isBroadcast)
                obj.PerChunkFunctionHandle.throwAsFunction(MException(message('MATLAB:bigdata:array:IncompatibleTallStrictSize')));
            end
            isBroadcast = all(isBroadcast);
            
            % First, do the per chunk behaviour as a collection of
            % independent chunkfun.
            allowTallDimExpansion = false;
            inputsUsed = 0;
            tasks = cell(numel(obj.PerChunkFunctionHandles) + 2, 1);
            for ii = 1:numel(obj.PerChunkFunctionHandles)
                functionHandle = obj.createWrappedKeyedFunctionHandle(obj.PerChunkFunctionHandles{ii});
                inputIndices = inputsUsed + (1 : obj.NumInputsPerOperation(ii));
                perChunkProcessorFactory = ChunkwiseProcessor.createFactory(...
                    functionHandle, obj.NumOutputsPerOperation(ii), ...
                    submap(inputFutureMap, inputIndices), isInputReplicated(inputIndices), allowTallDimExpansion);
                
                tasks{ii} = ExecutionTask.createSimpleTask(taskDependencies, perChunkProcessorFactory);
                inputsUsed = inputsUsed + obj.NumInputsPerOperation(ii);
            end
            tasks = vertcat(tasks{:});
            
            % The inter-chunk part of the operation is done as a single
            % task so that this only schedules a single reduction.
            reduceFunctions = cellfun(@obj.createWrappedKeyedFunctionHandle, obj.ReduceFunctionHandles, 'UniformOutput', false);
            
            reduceProcessorFactory = FusedReduceByKeyProcessor.createFactory(...
                reduceFunctions, obj.NumOutputsPerOperation);
            
            if isBroadcast
                % If in broadcast state, no communication is necessary, so
                % just do the final reduction.
                finalTask = ExecutionTask.createSimpleTask(tasks, reduceProcessorFactory, 'IsPassBoundary', true);
                tasks = [tasks; finalTask];
            else
                % Otherwise, do communication.
                communicationTask = ExecutionTask.createAnyToAnyTask(tasks, reduceProcessorFactory, 'IsPassBoundary', true);
                % There is only one dependency at this point because the
                % output of the previous FusedReduceByKeyProcessor is fused.
                numDependencies = 1;
                finalProcessorFactory = FusedReduceByKeyProcessor.createFactory(...
                    reduceFunctions, obj.NumOutputsPerOperation, numDependencies);
                finalTask = ExecutionTask.createSimpleTask(communicationTask, finalProcessorFactory, 'IsPassBoundary', true);
                tasks = [tasks; communicationTask; finalTask];
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for the fuse method.
        function obj = FusedAggregateByKeyOperation(...
                perChunkFunctionHandles, reduceFunctionHandles, ...
                numInputsPerOperation, numOutputsPerOperation)
            
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(sum(numInputsPerOperation), sum(numOutputsPerOperation));
            obj.PerChunkFunctionHandles = perChunkFunctionHandles;
            obj.ReduceFunctionHandles = reduceFunctionHandles;
            obj.NumInputsPerOperation = numInputsPerOperation;
            obj.NumOutputsPerOperation = numOutputsPerOperation;
        end
        
        function fh = createWrappedKeyedFunctionHandle(obj, fh)
            % Wrap a function handle to both group by key and handle tagged
            % input types.
            import matlab.bigdata.internal.lazyeval.GroupedByKeyFunction;
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            fh = TaggedArrayFunction.wrap(fh, obj.Options);
            fh = GroupedByKeyFunction.wrap(fh);
        end
    end
end
