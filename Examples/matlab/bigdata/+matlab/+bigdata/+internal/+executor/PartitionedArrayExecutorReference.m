%PartitionedArrayExecutorReference
% An implementation of PartitionedArrayExecutor that wraps around a soft
% reference to another PartitionedArrayExecutor.
%
% This exists so that PartitionedArrays objects can hold a reference to an
% instance of PartitionedArrayExecutor without preventing the execution
% environment being destroyed if the mapreducer is explicitly changed. It
% contains the means to recreate an executor if it is safe to do this.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) PartitionedArrayExecutorReference < matlab.bigdata.internal.executor.PartitionedArrayExecutor
    properties (SetAccess = private)
        % The underlying soft reference to the executor.
        ExecutorRef;
    end
        
    properties (SetAccess = immutable)
        % A memento struct that can recreate the underlying mapreducer
        % object when this object requires to recreate an execution
        % environment
        MapReducerMemento;
    end
    
    methods
        function obj = PartitionedArrayExecutorReference(executor, memento)
            if nargin >= 1
                obj.ExecutorRef = hGetSoftReference(executor);
            else
                obj.ExecutorRef = matlab.mapreduce.internal.SoftReference.hBuild();
            end
            
            if nargin >= 2
                obj.MapReducerMemento = memento;
            end
        end
        
        %EXECUTEWITHHANDLER Execute the provided graph of tasks redirecting
        %  all output to the given output handler.
        function executeWithHandler(obj, taskGraph, outputHandler)
            executor = obj.getOrCreate();
            executor.executeWithHandler(taskGraph, outputHandler);
        end
        
        %EXECUTE Execute the provided graph of tasks.
        function varargout = execute(obj, taskGraph)
            executor = obj.getOrCreate();
            [varargout{1 : nargout}] = executor.execute(taskGraph);
        end
        
        %COUNTNUMPASSES Count the number of passes required to execute the provided graph of tasks.
        function numPasses = countNumPasses(obj, taskGraph)
            executor = obj.getOrCreate();
            numPasses = executor.countNumPasses(taskGraph);
        end
        
        %NUMPARTITIONS Retrieve the number of partitions for the given
        %  partition strategy.
        function n = numPartitions(obj, partitionStrategy)
            executor = obj.getOrCreate();
            n = executor.numPartitions(partitionStrategy);
        end
    end
    
    methods
        % Check whether this executor is valid.
        function tf = checkIsValid(obj)
            tf = obj.checkIsValidNow();
            
            if ~tf && ~isempty(obj.MapReducerMemento)
                mr = gcmr('nocreate');
                tf =  isempty(mr) ...
                    || isequal(obj.MapReducerMemento, mr.getMemento());
            end
        end
        
        % Check whether this executor is valid right now.
        function tf = checkIsValidNow(obj)
            executor = obj.ExecutorRef.get();
            tf = ~isempty(executor) && executor.checkIsValid();
        end
        
        %CHECKDATASTORESUPPORT Check whether the provided datastore is supported.
        % The default is to do nothing. Implementations will are allowed to
        % issue errors from here if the datastore is not supported.
        function checkDatastoreSupport(obj, ds)
            executor = obj.getOrCreate();
            executor.checkDatastoreSupport(ds);
        end
        
        %CHECKSAMEEXECUTOR Check whether the two executor objects represent
        % the same underlying execution environment.
        function tf = checkSameExecutor(obj1, obj2)
            tf = (obj1.ExecutorRef == obj2.ExecutorRef);
            if ~tf && strcmp(class(obj1), class(obj2))
                try
                    tf = obj1.getOrCreate() == obj2.getOrCreate();
                catch
                    tf = false;
                end
            end
        end
        
        %KEEPALIVE Notify to the executor that operations have just been
        %performed and it should reset any idle timeouts.
        function keepAlive(obj)
            executor = obj.getOrCreate();
            executor.keepAlive();
        end
        
        %REQUIRESSEQUENCEFILEFORMAT A flag that specifies if tall/write
        %should always generate sequence files.
        function tf = requiresSequenceFileFormat(obj)
            executor = obj.getOrCreate();
            tf = executor.requiresSequenceFileFormat();
        end
        
        %SUPPORTSSINGLEPARTITION A flag that specifies if the executor
        %supports the single partition optimization.
        function tf = supportsSinglePartition(obj)
            executor = obj.getOrCreate();
            tf = executor.supportsSinglePartition();
        end
    end
    
    methods (Access = private)
        % Get or create the underlying executor.
        function executor = getOrCreate(obj)
            executor = obj.ExecutorRef.get();
            if ~isempty(executor) && executor.checkIsValid()
                return;
            end
            
            if isempty(obj.MapReducerMemento)
                matlab.bigdata.internal.throw(message('MATLAB:bigdata:array:InvalidTall'));
            end
            
            mapReducerManager = matlab.mapreduce.internal.MapReducerManager.getCurrentManager();
            mr = mapReducerManager.getDefault();
            if isempty(mr)
                mr = matlab.mapreduce.MapReducer.createFromMemento(obj.MapReducerMemento);
                result = false;
                if ~isempty(mr)
                    result = mapReducerManager.setDefault(mr);
                end
                if ~result
                    matlab.bigdata.internal.throw(message('MATLAB:bigdata:array:InvalidTall'));
                end
            else
                if ~isequal(obj.MapReducerMemento, mr.getMemento())
                    matlab.bigdata.internal.throw(message('MATLAB:bigdata:array:InvalidTall'));
                end
            end
            executor = mr.getPartitionedArrayExecutor();
            if isa(executor, 'matlab.bigdata.internal.executor.PartitionedArrayExecutorReference')
                executor = executor.getOrCreate();
            end
            obj.ExecutorRef = hGetSoftReference(executor);
        end
    end
end
