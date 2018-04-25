%DebugExecutorDecorator
% An implementation of the PartitionedArrayExecutor interface that
% annotates execution with a collection of function calls.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) DebugExecutorDecorator < matlab.bigdata.internal.executor.PartitionedArrayExecutor
    properties (GetAccess = private,SetAccess = immutable)
        % An instance of DebugSession that will manage all listeners of
        % debug events.
        Session;
    end
    
    properties (GetAccess = private, SetAccess = immutable, Transient)
        % The internal executor that performs the actual evaluation.
        Executor;
    end
    
    properties (Access = private, Constant)
        % The means by which this class receives unique IDs.
        IdFactory = matlab.bigdata.internal.util.UniqueIdFactory('DebugExecution');
    end
    
    methods
        function obj = DebugExecutorDecorator(executor, session)
            % Construct a DebugSerialExecutor.
            obj.Session = session;
            obj.Executor = executor;
        end
    end
    
    % Methods overridden in the PartitionedArrayExecutor interface.
    methods
        %EXECUTE Execute the provided graph of tasks.
        function varargout = execute(obj, taskGraph)
            executionId = obj.IdFactory.nextId();
            obj.Session.notifyDebugEvent('ExecuteBegin', obj, executionId, taskGraph);
            try
                [varargout{1 : nargout}] = obj.Executor.execute(obj.decorateGraph(executionId, taskGraph));
            catch err
                obj.Session.notifyDebugEvent('ExecuteEnd', obj, executionId, taskGraph);
                rethrow(err);
            end
            obj.Session.notifyDebugEvent('ExecuteEnd', obj, executionId, taskGraph);
        end

        function executeWithHandler(obj, taskGraph, outputHandlers)
            import matlab.bigdata.internal.debug.DebugOutputHandler;
            executionId = obj.IdFactory.nextId();
            obj.Session.notifyDebugEvent('ExecuteBegin', executionId, taskGraph);
            
            try
                outputHandlers = DebugOutputHandler(outputHandlers, taskGraph, executionId, obj.Session);
                obj.Executor.executeWithHandler(obj.decorateGraph(executionId, taskGraph), outputHandlers);
            catch err
                obj.Session.notifyDebugEvent('ExecuteEnd', executionId, taskGraph);
                rethrow(err);
            end
            obj.Session.notifyDebugEvent('ExecuteEnd', executionId, taskGraph);
        end
        
        %COUNTNUMPASSES Count the number of passes required to execute the provided graph of tasks.
        function numPasses = countNumPasses(obj, taskGraph)
            numPasses = obj.Executor.countNumPasses(taskGraph);
        end
        
        %NUMPARTITIONS Retrieve the number of partitions for the given
        %  partition strategy.
        function n = numPartitions(obj, partitionStrategy)
            n = obj.Executor.numPartitions(partitionStrategy);
        end
        
        % Check whether this executor is valid.
        function tf = checkIsValid(obj)
            tf = obj.Executor.checkIsValid();
        end
        
        % Check whether this executor is valid right now.
        function tf = checkIsValidNow(obj)
            tf = obj.Executor.checkIsValidNow();
        end
        
        %CHECKDATASTORESUPPORT Check whether the provided datastore is supported.
        % The default is to do nothing. Implementations will are allowed to
        % issue errors from here if the datastore is not supported.
        function checkDatastoreSupport(obj, ds)
            obj.Executor.checkDatastoreSupport(ds);
        end
        
        %CHECKSAMEEXECUTOR Check whether the two executor objects represent
        % the same underlying execution environment.
        function tf = checkSameExecutor(obj1, obj2)
            tf = obj1 == obj2;
        end
        
        %KEEPALIVE Notify to the executor that operations have just been
        %performed and it should reset any idle timeouts.
        function keepAlive(obj)
            obj.Executor.keepAlive();
        end
        
        %REQUIRESSEQUENCEFILEFORMAT A flag that specifies if tall/write
        %should always generate sequence files.
        function tf = requiresSequenceFileFormat(obj)
            tf = obj.Executor.requiresSequenceFileFormat();
        end
        
        %SUPPORTSSINGLEPARTITION A flag that specifies if the executor
        %supports the single partition optimization.
        function tf = supportsSinglePartition(obj)
            tf = obj.Executor.supportsSinglePartition();
        end
    end
    
    methods (Access = private)
        function decoratedTaskGraph = decorateGraph(obj, executionId, taskGraph)
            % Decorate all data processor factories in a task graph such
            % that they all construct DebugDataProcessor instances.
            import matlab.bigdata.internal.executor.SimpleTaskGraph;
            import matlab.bigdata.internal.debug.DebugProcessorFactory;
            
            oldTasks = taskGraph.Tasks;
            
            newTasks = cell(size(oldTasks));
            taskMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for ii = 1:numel(oldTasks)
                oldTask = oldTasks(ii);
                
                newFactory = DebugProcessorFactory(oldTask.DataProcessorFactory, oldTask, executionId, obj.Session);
                
                inputTasks = cell(oldTask.InputIds);
                for jj = 1:numel(oldTask.InputIds)
                    inputTasks{jj} = taskMap(oldTask.InputIds{jj});
                end
                inputTasks = vertcat(inputTasks{:});
                
                newTask = oldTask.copyWithReplacedInputs(inputTasks, newFactory);
                newTasks{ii} = newTask;
                taskMap(newTask.Id) = newTask;
            end
            newTasks = vertcat(newTasks{:});
            
            [~, outputTaskIndices] = ismember(taskGraph.OutputTasks, oldTasks);
            decoratedTaskGraph = SimpleTaskGraph(newTasks, newTasks(outputTaskIndices));
        end
    end
end

