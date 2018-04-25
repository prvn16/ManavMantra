%FusedAggregateOperation
% An operation that is the fusion of two or more operations that aggregate
% a partitioned array into a non-partitioned array.
% This includes:
%   * AggregateOperation
%   * NonPartitionedOperation
%   * GatherOperation

% Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) FusedAggregateOperation < matlab.bigdata.internal.lazyeval.AggregateFusibleOperation
    properties (SetAccess = immutable)
        % A collection of aggregate fusible tasks.
        Operations;
    end
    
    methods (Static)
        % Fuse a collection of AggregateFusibleOperation objects into a
        % single FusedAggregateOperation.
        %
        % The inputs of this operation is the concatenation of the inputs
        % of varargin. Similarly, the outputs of this operation is the
        % concatenation of the outputs of varargout.
        function obj = fuse(varargin)
            import matlab.bigdata.internal.lazyeval.FusedAggregateOperation;
            
            operations = cell(size(varargin));
            for ii = 1:numel(varargin)
                input = varargin{ii};
                
                if isa(input, 'matlab.bigdata.internal.lazyeval.FusedAggregateOperation')
                    operations{ii} = {input.Operations};
                elseif isa(input, 'matlab.bigdata.internal.lazyeval.AggregateFusibleOperation')
                    operations{ii} = {input};
                else
                    assert(false, 'Attempted to aggregate fuse a ''%s''.', class(input));
                end
            end
            operations = vertcat(operations{:});
            obj = FusedAggregateOperation(operations);
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        % Create a collection of ExecutionTask objects that represent this
        % operation given the provided inputs.
        function tasks = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.InputFutureMap;
            
            isDataReplicated = all(arrayfun(@(x)x.OutputPartitionStrategy.IsDataReplicated, taskDependencies));
            numInputsPerOperation = cellfun(@(op) op.NumInputs, obj.Operations);
            numOutputsPerOperation = cellfun(@(op) op.NumOutputs, obj.Operations);
            
            if isDataReplicated
                extractFactoryFcn = @createPerChunkProcessorFactory;
                reduceFactoryFcn = @createReduceProcessorFactory;
                outTaskFcn = @ExecutionTask.createBroadcastTask;
                
                tasks = iCreateFusedFragment(obj.Operations, ...
                    numInputsPerOperation, numOutputsPerOperation, ...
                    extractFactoryFcn, reduceFactoryFcn, outTaskFcn, ...
                    taskDependencies, inputFutureMap, isInputReplicated);
            else
                % All reduction within each individual remote partition.
                numIntermediatesPerOperation = cellfun(@(op) op.NumIntermediates, obj.Operations);
                
                extractFactoryFcn = @createPerChunkProcessorFactory;
                reduceFactoryFcn = @createCombineProcessorFactory;
                outTaskFcn = @ExecutionTask.createAllToOneTask;
                
                preCommTasks = iCreateFusedFragment(obj.Operations, ...
                    numInputsPerOperation, numIntermediatesPerOperation, ...
                    extractFactoryFcn, reduceFactoryFcn, outTaskFcn, ...
                    taskDependencies, inputFutureMap, isInputReplicated);
                
                % All aggregation across the gathered intermediate data.
                extractFactoryFcn = @iCreatePassthroughProcessorFactory;
                reduceFactoryFcn = @createReduceProcessorFactory;
                outTaskFcn = @ExecutionTask.createBroadcastTask;
                
                taskDependencies = preCommTasks(end);
                inputFutureMap = InputFutureMap.createPassthrough(obj.NumIntermediates);
                isInputReplicated = true(1, sum(numIntermediatesPerOperation));
                
                postCommTasks = iCreateFusedFragment(obj.Operations, ...
                    numIntermediatesPerOperation, numOutputsPerOperation, ...
                    extractFactoryFcn, reduceFactoryFcn, outTaskFcn, ...
                    taskDependencies, inputFutureMap, isInputReplicated);
                
                tasks = [preCommTasks; postCommTasks];
            end
        end
    end
    
    % Not implemented because FusedAggregateOperation/fuse will flatten
    % nested FusedAggregateOperation.
    methods
        function factory = createPerChunkProcessorFactory(~, ~, ~) %#ok<STOUT>
            assert(false, 'FusedAggregateOperation/createPerChunkProcessorFactory should never be called');
        end
        
        function factory = createCombineProcessorFactory(~) %#ok<STOUT>
            assert(false, 'FusedAggregateOperation/createCombineProcessorFactory should never be called');
        end
        
        function factory = createReduceProcessorFactory(~) %#ok<STOUT>
            assert(false, 'FusedAggregateOperation/createReduceProcessorFactory should never be called');
        end
    end
    
    methods (Access = private)
        % Private constructor for the fuse method.
        function obj = FusedAggregateOperation(operations)
            numIntermediatesPerOperation = cellfun(@(x) x.NumIntermediates, operations);
            numInputsPerOperation = cellfun(@(x) x.NumInputs, operations);
            numOutputsPerOperation = cellfun(@(x) x.NumOutputs, operations);
            obj = obj@matlab.bigdata.internal.lazyeval.AggregateFusibleOperation(...
                sum(numIntermediatesPerOperation), sum(numInputsPerOperation), sum(numOutputsPerOperation));
            obj.Operations = operations;
        end
    end
end

function tasks = iCreateFusedFragment (...
    operations, numInputsPerOperation, numOutputsPerOperation, ...
    createExtractFactoryFcn, createReduceFactoryFcn, createOutTaskFcn, ...
    taskDependencies, inputFutureMap, isInputReplicated)
% Create an array of ExecutionTask objects that represents one step
% (either pre-communication or post-communication) of the fused reduction.
% The last task is the one that emits the output of this step, all other
% tasks are upstream dependencies of the output task as well as downstream
% dependents of the give input task dependencies.

import matlab.bigdata.internal.executor.ExecutionTask;
import matlab.bigdata.internal.lazyeval.PassthroughProcessor;

numOperations = numel(operations);
extractTasks = cell(numOperations, 1);
reduceTasks = cell(numOperations, 1);
inputsUsed = 0;
for ii = 1 : numOperations
    inputIndices = inputsUsed + (1 : numInputsPerOperation(ii));
    
    % We ensure that each operation receives only the dependencies
    % corresponding to its inputs. This avoids introducing unnecessary
    % dependencies, which adds to the overheads of the back-end.
    [opInputFutureMap, opDependencies] = submap(inputFutureMap, inputIndices, taskDependencies);
    
    factory = createExtractFactoryFcn(operations{ii}, ...
        opInputFutureMap, isInputReplicated(inputIndices));
    extractTasks{ii} = ExecutionTask.createSimpleTask(opDependencies, factory);
    
    factory = createReduceFactoryFcn(operations{ii});
    reduceTasks{ii} = ExecutionTask.createSimpleTask(extractTasks{ii}, factory);
    
    inputsUsed = inputsUsed + numInputsPerOperation(ii);
end
extractTasks = vertcat(extractTasks{:});
reduceTasks = vertcat(reduceTasks{:});

passthroughProcessor = PassthroughProcessor.createFactory(numOperations, sum(numOutputsPerOperation));
outTask = createOutTaskFcn(reduceTasks, passthroughProcessor, 'IsPassBoundary', true);
tasks = [extractTasks; reduceTasks; outTask];
end

function factory = iCreatePassthroughProcessorFactory(~, inputFutureMap, ~)
% Construct a data processor factory that will extract the provided inputs
% from the upstream dependencies.

import matlab.bigdata.internal.lazyeval.PassthroughProcessor;
import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;

factory = PassthroughProcessor.createFactory(inputFutureMap.NumOperationInputs);
factory = InputMapProcessorDecorator.wrapFactory(factory, inputFutureMap);
end
