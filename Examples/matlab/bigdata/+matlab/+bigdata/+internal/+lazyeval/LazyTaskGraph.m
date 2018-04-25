%LazyTaskGraph
% Class that represents a graph of ExecutionTask that is equivalent to the
% graph of closures that is required to be executed.
%
% General model for tasks:
%
% Each closure will have one or more execution tasks that represents it.
%
% Every task in this graph will emit a N x NumOutputs cell array.
% * Each column corresponds with exactly one output of the operation.
% * Each cell contains one chunk of data of that output.
% Tasks are expected to extract out the correct columns from upstream tasks.
% * The input to a task will be one N x NumOutputs cell array from each
%   upstream task.
% * The task is responsible for extracting out the data that corresponds to
%   the input futures that the corresponding operation requires.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) LazyTaskGraph < matlab.bigdata.internal.executor.TaskGraph
    % Overrides of TaskGraph properties.
    properties (SetAccess = private)
        Tasks;
        OutputTasks;
    end
    
    properties (SetAccess = immutable)
        % A map of Closure ID to the corresponding ExecutionTask instance.
        ClosureToTaskMap;
        
        % A map of Task ID to the corresponding Closure instance.
        TaskToClosureMap;
    end
    
    properties (SetAccess = private)
        % A vector of all CacheEntryKey objects from the closure graph.
        CacheEntryKeys = matlab.bigdata.internal.executor.CacheEntryKey.empty(0,1);
    end
    
    methods
        % The main constructor.
        %
        % Syntax:
        %   obj = LazyTaskGraph(closures);
        %
        % Inputs:
        %  - closures is a list of Closure instances that represent the
        %  desired final results to be gathered.
        function obj = LazyTaskGraph(closures)
            import matlab.bigdata.internal.executor.ExecutionTask;
            obj.Tasks = ExecutionTask.empty();
            obj.ClosureToTaskMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.TaskToClosureMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            
            for ii = 1:numel(closures)
                closure = closures(ii);
                task = obj.doAddClosure(closure);
                if isempty(obj.OutputTasks) || ~any(obj.OutputTasks == task)
                    obj.OutputTasks = [obj.OutputTasks; task];
                end
            end
        end
    end
    
    methods (Access = private)
        % Implementation of addClosure that returns the task corresponding
        % to the given closure.
        function task = doAddClosure(obj, closure)
            import matlab.bigdata.internal.executor.OutputCommunicationType;
            import matlab.bigdata.internal.lazyeval.InputFutureMap;
            if isKey(obj.ClosureToTaskMap, closure.Id)
                task = obj.ClosureToTaskMap(closure.Id);
                return;
            end
            
            % We make the inputs to the Execution task to be exactly the list of
            % direct closure dependencies on the current Closure. The list of
            % direct dependencies is equivalent to unique on all of
            % closure.InputFutures.Promise.Closure.
            dependencies = closure.getDirectDependencies();
            
            taskDependencies = cell(numel(dependencies) + 1, 1);
            for ii = 1:numel(dependencies)
                taskDependencies{ii} = obj.doAddClosure(dependencies(ii));
            end
            
            [inputFutureMap, additionalConstants] = InputFutureMap.createFromClosures(closure.InputFutures, dependencies);
            if ~isempty(additionalConstants)
                taskDependencies{end} = obj.createConstantTask(additionalConstants);
            end
            taskDependencies = vertcat(taskDependencies{:});

            isInputReplicated = inputFutureMap.mapScalars(arrayfun(@(x)x.OutputPartitionStrategy.IsDataReplicated, taskDependencies));
            
            allTasks = closure.Operation.createExecutionTasks(taskDependencies, inputFutureMap, isInputReplicated);
            
            task = allTasks(end);
            obj.Tasks = [obj.Tasks; allTasks(:)];
            obj.ClosureToTaskMap(closure.Id) = task;
            obj.TaskToClosureMap(task.Id) = closure;
            if task.OutputPartitionStrategy.IsBroadcast
                % We do this in order to complete any closures that so
                % happen to have a small output.
                obj.OutputTasks = [obj.OutputTasks; task];
            end
            
            if task.CacheLevel ~= "None" && task.CacheEntryKey.IsValid
                obj.CacheEntryKeys = [obj.CacheEntryKeys; task.CacheEntryKey];
            end
        end
        
        % Create an ExecutionTask that effectively broadcasts the provided
        % constants.
        function task = createConstantTask(obj, constants)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.executor.BroadcastPartitionStrategy;
            import matlab.bigdata.internal.executor.ConstantProcessor;
            processorFactory = ConstantProcessor.createFactory(constants);
            task = ExecutionTask.createBroadcastTask([], processorFactory,...
                'ExecutionPartitionStrategy', BroadcastPartitionStrategy());
            obj.Tasks = [obj.Tasks; task];
        end
    end
end
