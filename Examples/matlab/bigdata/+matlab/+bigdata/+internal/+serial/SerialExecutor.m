%SerialExecutor
% Serial implementation of the PartitionArrayExecutor interface.
%
% This currently operates by building a CompositeDataProcessor per
% partition per "stage", where stage is defined to be a collection of
% tasks that can be run simultaneously. A pass is necessarily a stage, but
% a stage is not necessarily a pass as the client side of operations denote
% a stage that isn't over any particular datastore. Each CompositeDataProcessor
% includes processors that perform pieces of the communication, such as
% reading/writing to intermediate store as well as reading/writing to
% cache.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef SerialExecutor < matlab.bigdata.internal.executor.PartitionedArrayExecutor
    
    properties (SetAccess = immutable)
        % The object that manages the cache on disk.
        CacheManager;
        
        % A flag that specifies whether this executor will use a single
        % partition whenever it is possible to do so.
        UseSinglePartition;
        
        % The maximum number of partitions to use for execution of any one
        % closure. This is respected unless the underlying operation
        % explicitly requests for a larger number of partitions.
        MaxNumPartitions = Inf;
    end
    
    methods
        % The main constructor.
        function obj = SerialExecutor(varargin)
            import matlab.bigdata.internal.serial.CacheManager;
            import matlab.bigdata.internal.util.TempFolder;
            obj.CacheManager = CacheManager();
            
            p = inputParser;
            p.addParameter('UseSinglePartition', false);
            p.addParameter('MaxNumPartitions', inf);
            p.parse(varargin{:});
            validateattributes(p.Results.UseSinglePartition, {'logical'}, {'scalar'});
            obj.UseSinglePartition = p.Results.UseSinglePartition;
            validateattributes(p.Results.MaxNumPartitions, {'double'}, {'scalar', 'positive'});
            obj.MaxNumPartitions = p.Results.MaxNumPartitions;
        end
    end
    
    % Methods overridden in the PartitionedArrayExecutor interface.
    methods
        function varargout = execute(obj, taskGraph) %#ok<INUSD,STOUT>
            assert(false, 'Deprecated API');
        end
        
        function executeWithHandler(obj, taskGraph, outputHandlers)
            import matlab.bigdata.internal.util.TempFolder;
            import matlab.bigdata.internal.executor.ProgressReporter;
            
            pr = ProgressReporter.getCurrent();
            
            allowEdtCallbacks = any([outputHandlers.IsStreamingHandler]);
            
            intermediateStoreFolder = TempFolder();
            [stageTasks, broadcastMap] = obj.buildStageTasks(taskGraph, outputHandlers, intermediateStoreFolder.Path);
            
            % We want to ensure that all memory cache entries are cleaned
            % up at the end of execution to avoid conflicting with memory
            % usage of non-tall MATLAB arrays.
            cacheCleanup = onCleanup(@()obj.CacheManager.dumpMemoryToDisk());
            
            executorName = getString(message('MATLAB:bigdata:executor:SerialExecutorName'));
            numTasks = numel(stageTasks) - obj.countNumBroadcastStages(stageTasks);
            numPasses = obj.countNumDatastoreStages(stageTasks);
            
            pr.startOfExecution(executorName, numTasks, numPasses);
            for ii = 1:numel(stageTasks)
                isBroadcastStage = stageTasks(ii).ExecutionPartitionStrategy.IsBroadcast;
                if isBroadcastStage
                    obj.executeTask(stageTasks(ii), stageTasks(ii).CacheEntryKeys, allowEdtCallbacks);
                else
                    isFullPass = stageTasks(ii).ExecutionPartitionStrategy.IsDatastorePartitioning;
                    pr.startOfNextTask(isFullPass);
                    obj.executeTask(stageTasks(ii), stageTasks(ii).CacheEntryKeys, allowEdtCallbacks, pr);
                    pr.endOfTask();
                    if isFullPass
                        obj.incrementTotalNumPasses();
                    end
                end
                
                % If this stage task generated broadcast output to be sent
                % to the client, we can perform that action now.
                outputBroadcasts = stageTasks(ii).OutputBroadcasts;
                outputBroadcasts = outputBroadcasts(ismember(outputBroadcasts, taskGraph.OutputTasks));
                for outputBroadcast = outputBroadcasts(:)'
                    outputHandlers.handleBroadcastOutput(...
                        outputBroadcast.Id, broadcastMap.get(outputBroadcast.Id));
                end
            end
            pr.endOfExecution();
        end
        
        function numPasses = countNumPasses(obj, taskGraph)
            import matlab.bigdata.internal.util.TempFolder;
            import matlab.bigdata.internal.executor.OutputHandler;
            
            intermediateStoreFolder = TempFolder();
            stageTasks = obj.buildStageTasks(taskGraph, ...
                OutputHandler.empty(), intermediateStoreFolder.Path);
            
            numPasses = obj.countNumDatastoreStages(stageTasks);
        end
        
        %NUMPARTITIONS Retrieve the number of partitions for the given
        %  partition strategy.
        function n = numPartitions(~, partitionStrategy)
            n = partitionStrategy.DesiredNumPartitions;
            if isempty(n)
                n = 1;
            end
        end
        
        %SUPPORTSSINGLEPARTITION A flag that specifies if the executor
        %supports the single partition optimization.
        function tf = supportsSinglePartition(obj)
            tf = true && ~obj.UseSinglePartition;
        end
    end
    
    methods (Access = private)
        % Count the number of stages that have execution across a
        % datastore.
        function numStages = countNumDatastoreStages(obj, stageTasks) %#ok<INUSL>
            numStages = 0;
            for ii = 1:numel(stageTasks)
                numStages = numStages + stageTasks(ii).ExecutionPartitionStrategy.IsDatastorePartitioning;
            end
        end
        
        % Count the number of stages that have execution in broadcast mode.
        function numStages = countNumBroadcastStages(obj, stageTasks) %#ok<INUSL>
            numStages = 0;
            for ii = 1:numel(stageTasks)
                numStages = numStages + stageTasks(ii).ExecutionPartitionStrategy.IsBroadcast;
            end
        end
        
        % Execute the provided independent stage task
        function executeTask(obj, task, cacheEntryKeys, allowEdtCallbacks, progressReporter)
            partitionStrategy = task.ExecutionPartitionStrategy;
            numExecutorPartitions = partitionStrategy.DesiredNumPartitions;
            if ~partitionStrategy.IsNumPartitionsFixed
                % We use a single partition where possible because this is
                % more optimal. Early exit is faster and less intermediate
                % data is written to disk.
                if isempty(numExecutorPartitions) ...
                        || obj.UseSinglePartition ...
                        && isempty(task.CacheEntryKeys) 
                    numExecutorPartitions = 1;
                end
                numExecutorPartitions = min(numExecutorPartitions, obj.MaxNumPartitions);
            end
            
            % This must be called once per execution task so that cache
            % entries generated from this execution task can override
            % previous cache entries.
            obj.CacheManager.setupForExecution(cacheEntryKeys);
            
            for partitionIndex = 1:numExecutorPartitions
                partition = partitionStrategy.createPartition(partitionIndex, numExecutorPartitions);
                
                dataProcessor = feval(task.DataProcessorFactory, partition);
                
                while ~dataProcessor.IsFinished
                    process(dataProcessor, false(0));
                    if allowEdtCallbacks
                        drawnow;
                    end
                end
                
                if nargin >= 5
                    progressReporter.progress(partitionIndex / numExecutorPartitions);
                end
            end
        end
        
        % Convert the input task graph into an array of independent tasks
        % that can be executed one by one.
        %
        function [stageTasks, broadcastMap] = buildStageTasks(obj, taskGraph, outputHandlers, intermediateFolderPath)
            import matlab.bigdata.internal.executor.BroadcastMap;
            broadcastMap = BroadcastMap();
            stageTasks = matlab.bigdata.internal.executor.convertToIndependentTasks(taskGraph, ...
                'CreateShuffleStorageFunction', @(task)obj.createShuffleStorage(task, intermediateFolderPath), ...
                'CreateBroadcastStorageFunction', @(task)obj.createBroadcastStorage(task, broadcastMap), ...
                'CreateStreamFactoryFunction', @(task)obj.createStreamFactory(task, outputHandlers), ...
                'GetCacheStoreFunction', @obj.getCacheStore, ...
                'GetNumPartitionsFunction', @obj.numPartitions);
        end
        
        % Create a shuffle point where data is stored to an intermediate
        % storage, then read in a "shuffled" order by the next task.
        function [writerFactory, readerFactory] = createShuffleStorage(obj, task, intermediateFolderPath) %#ok<INUSL>
            import matlab.bigdata.internal.executor.OutputCommunicationType;
            import matlab.bigdata.internal.serial.KeyValueStoreReader;
            import matlab.bigdata.internal.serial.KeyValueStoreWriter;
            import matlab.bigdata.internal.serial.SerialExecutor;
            
            intermediateStoreFilename = iGetShuffleStoreName(task, intermediateFolderPath);
            
            outputCommunicationType = task.OutputCommunicationType;
            writerFactory = ...
                @(partition) KeyValueStoreWriter(intermediateStoreFilename, iGetDefaultKey(partition, outputCommunicationType));
            
            if task.OutputPartitionStrategy.IsBroadcast
                % When a given piece of intermediate data is in broadcast
                % state, it has only 1 partition. Every data processor that
                % requires this data must read from partition 1.
                broadcastPartitionIndex = 1;
                readerFactory = @(partition) KeyValueStoreReader(intermediateStoreFilename, broadcastPartitionIndex);
            else
                readerFactory = @(partition) KeyValueStoreReader(intermediateStoreFilename, partition.PartitionIndex);
            end
        end
        
        % Create a broadcast variable that will receive the output of a
        % broadcast execution task.
        function [setterFunction, getterFunction] = createBroadcastStorage(obj, task, broadcastMap) %#ok<INUSL>
            taskId = task.Id;
            
            setterFunction = @(partition, value) iSetBroadcast(broadcastMap, taskId, partition, value);
            getterFunction = @() broadcastMap.get(taskId);
        end
        
        % Create a factory of Writer objects that redirect the output of
        % the given task to the output handlers.
        function streamWriterFactory = createStreamFactory(obj, task, outputHandlers) %#ok<INUSL>
            import matlab.bigdata.internal.serial.OutputHandlerAdaptorWriter;
            taskId = task.Id;
            
            streamWriterFactory = @(partition) OutputHandlerAdaptorWriter(taskId, ...
                partition.PartitionIndex, partition.NumPartitions, outputHandlers);
        end
        
        % Get the CacheManager instance.
        %
        % This exists for the purposes of convertToIndependentTasks.
        function cacheStore = getCacheStore(obj, task) %#ok<INUSD>
            cacheStore = obj.CacheManager.CacheStore;
        end
    end
end

% Helper function that sets either the broadcast value or partitions of the
% broadcast value depending on the partition strategy.
function iSetBroadcast(map, key, partition, value)
if partition.NumPartitions == 1
    map.set(key, value);
else
    map.setPartitions(key, partition.PartitionIndex, {value});
end
end

% For the provided partition and output communication type, get the default
% key that should be written to the intermediate data store.
function defaultKey = iGetDefaultKey(partition, outputCommunicationType)
import matlab.bigdata.internal.executor.OutputCommunicationType;
import matlab.bigdata.internal.serial.SerialExecutor;
switch outputCommunicationType
    case OutputCommunicationType.Simple
        defaultKey = partition.PartitionIndex;
    case OutputCommunicationType.Broadcast
        defaultKey = 1;
    case OutputCommunicationType.AllToOne
        defaultKey = 1;
    case OutputCommunicationType.AnyToAny
        % In AnyToAny communication, the partition indices should be
        % specified by the data processor implementation underlying the
        % task.
        defaultKey = [];
end
end

% Get the filename for the intermediate data associated with the provided
% task.
function path = iGetShuffleStoreName(task, intermediateStoreFolder)
path = fullfile(intermediateStoreFolder, [task.Id, '.db']);
end
