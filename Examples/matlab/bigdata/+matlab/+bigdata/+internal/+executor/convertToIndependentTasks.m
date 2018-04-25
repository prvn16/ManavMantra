function stageTasks = convertToIndependentTasks(taskGraph, varargin)
%CONVERTTOINDEPENDENTTASKS Convert the provided task graph into a
%collection of stage tasks that can be evaluated sequentially.
%
% Syntaxes:
%  stageTasks = convertToIndependentTasks(taskGraph,...
%       'CreateShuffleStorageFunction',@myCreateShuffleStorageFunction,...
%       'CreateBroadcastStorageFunction',@myCreateBroadcastStorageFunction);
%
%  [..] = convertToIndependentTasks(..,'GetCacheStoreFunction',@myCreateBroadcastStorageFunction,..)
%
%  [..] = convertToIndependentTasks(..,'GetNumPartitionsFunction',@myGetNumPartitionsFunction,..)
%
%  [..] = convertToIndependentTasks(..,'CreateStreamFactoryFunction',@myCreateStreamFactoryFunction,..)
%
% The output, stageTasks, will be an array of StageTask objects that is
% equivalent to taskGraph. Evaluating the stage tasks sequentially in order
% is equivalent to evaluating the task graph optimally. Specifically, each
% stage task will perform one or more side-effects, writing data either to
% a shuffle-sort storage or to a broadcast variable. Once complete, the
% output associated with each of taskGraph.OutputTasks is stored as a
% broadcast variable.
%
% CreateShuffleStorageFunction:
%
% The syntax for the createShuffle function is:
%   [writerFactory, readerFactory] = createShuffle(task)
%
% Where each factory must be serializable, and generate an instance of
% matlab.bigdata.internal.io.Writer and matlab.bigdata.internal.io.Reader
% respectively. This will be called by the MATLAB client during scheduling.
%
% CreateBroadcastStorageFunction:
%
% The syntax for the createBroadcast function is:
%   [setterFactory, getterFactory] = createBroadcast(task)
%
% Where the getter is an inputless function handle that emits the broadcast
% value output of the given task and the setter is a function handle of the
% form setFcn(partition, value) that adds the given partition value to
% the broadcast value.
%
% GetCacheStoreFunction:
%
% The syntax for the getCacheStore function is:
%   cacheStore = getCacheStore()
%
% Where cacheStore is an instance of matlab.bigdata.internal.io.CacheStore.
% This will be called by a MATLAB worker during execution.
%
% GetNumPartitionsFunction:
%
% The function handle GetNumPartitionsFunction returns the number of partitions
% for a given partition strategy. The signature of this function handle must be:
%   numPartitions = getNumPartitions(partitionStrategy)
%
% CreateStreamFactoryFunction:
%  Create a factory for Writer objects that sends data back to the client
%  MATLAB context. This is only used for output of execution, none of the
%  streamed data will be used by downstream tasks.
%
%  This is optional and if left empty, convertToIndependentTasks will
%  broadcast all output instead.
%
%  The CreateStreamFactoryFunction function handle will be invoked once for
%  each non-broadcast output from within the client MATLAB process. It has
%  syntax:
%
%    streamWriterFactory = createStreamFactory(taskId);
%
%  Where:
%    - taskId is the string contained in task.Id that corresponds to the
%    task whose output must be streamed back to the client.
%
%  The returned factory will be bound into the underlying data processors.
%  It will be called once per partition from the worker MATLAB contexts. It
%  has syntax:
%
%   streamWriter = streamWriterFactory(partition)
%
%  Where:
%    - partition is a matlab.bigdata.internal.executor.Partition object
%    containing information about the source of the stream.
%
% Architecture:
%
% The implementation of this is the following graph transformations:
%  1. Replace all edges of the graph that require communication with a pair
%  of read/write to an intermediate storage task (either shuffle-sort storage
%  or a broadcast).
%  2. Inject a cache task into all edges of the graph that represent
%  intermediate state that is marked for caching.
%  3. Wrap each still-connected subgraph into a single task that has no
%  task inputs or outputs.
%  4. Combine tasks that can be scheduled to run simultaneously.
%

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.bigdata.internal.executor.BroadcastPartitionStrategy;
import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
import matlab.bigdata.internal.executor.ExecutionTask;
import matlab.bigdata.internal.executor.StageTask;

p = inputParser;
p.addParameter('CreateShuffleStorageFunction', []);
p.addParameter('CreateBroadcastStorageFunction', []);
p.addParameter('CreateStreamFactoryFunction', []);
p.addParameter('GetCacheStoreFunction', []);
p.addParameter('GetNumPartitionsFunction', @(~) 1);
p.parse(varargin{:});
factories = p.Results;

% A map of task ID to the execution to be fused forward into successors of
% the task of given ID. Each piece of execution passed forward is exactly
% what is needed to access the output of the task of given ID. Each will be
% a CompositeDataProcessorBuilder object.
passforwardExecutionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% A map of task ID to the minimum index into the output execution graph
% that the output of the task is available for consumption.
minScheduleIndexMap = containers.Map('KeyType', 'char', 'ValueType', 'double');

% A map of task ID to an array of the communication dependencies of the
% task. Dependencies include shuffle, broadcast and cache.
commDependenciesMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% A cell array of StageTask object arrays that will form the output of this
% function.
%
% Each cell is allowed to be an array of 0 or more StageTask objects that
% are scheduled to run simultaneously. At the end of this function, each
% non-empty cell is combined into a single output StageTask object. Empty
% cells are ignored.
%
% Stage task 1 is reserved for any broadcasted constants from the input
% graph. This is initialized to an empty array as a placeholder.
%
stageTasks = {StageTask.empty(0, 1)};

% A cell array of partition strategies corresponding to stageTasks.
%
% Each cell is the partition strategy that corresponds to all StageTask
% objects in the corresponding cell of stageTasks.
%
% Stage task 1 is reserved for any broadcasted constants from the input
% graph. This reservation is enforced by having the partition strategy for
% stage task 1 initialized to BroadcastPartitionStrategy before parsing the
% input graph.
independentPartitionStrategies = {BroadcastPartitionStrategy()};

executionTasks = taskGraph.Tasks;
outputTasks = taskGraph.OutputTasks;
for ii = 1:numel(executionTasks)
    task = taskGraph.Tasks(ii);
    isOutput = ismember(task, outputTasks);
    
    % The pieces of execution to be fused into this task so that it may
    % access the output of predecessor tasks.
    inputExecutions = iGetFromMap(passforwardExecutionMap, task.InputIds, CompositeDataProcessorBuilder.empty());
    % The communication predecessors of this task after fusion with
    % inputExecutions.
    inputCommDependencies = unique(iGetFromMap(commDependenciesMap, task.InputIds, StageTask.empty()));
    % The minimum scheduling index of this task.
    minScheduleIndex = max(iGetFromMap(minScheduleIndexMap, task.InputIds, 1));
    
    [actionableStageTask, isBlocking, passforwardExecutionMap(task.Id), commDependenciesMap(task.Id)] = ...
        iWrapTask(task, inputExecutions, inputCommDependencies, isOutput, factories);
    
    % No actionable work to schedule.
    if isempty(actionableStageTask)
        %Successors can be scheduled at the same time as this task or later.
        minScheduleIndexMap(task.Id) = minScheduleIndex;
        continue;
    end
    
    % This task generates work that requires to be scheduled.
    scheduleIndex = numel(independentPartitionStrategies) + 1;
    for jj = minScheduleIndex : numel(independentPartitionStrategies)
        if isequal(task.ExecutionPartitionStrategy, independentPartitionStrategies{jj})
            scheduleIndex = jj;
            break;
        end
    end
    
    if scheduleIndex > numel(independentPartitionStrategies)
        stageTasks{scheduleIndex} = actionableStageTask;
        independentPartitionStrategies{scheduleIndex} = task.ExecutionPartitionStrategy;
    else
        stageTasks{scheduleIndex} = [stageTasks{scheduleIndex}; actionableStageTask];
    end
    
    % Successors must be scheduled at the same time as this task or
    % later. If this task is blocking, successors must be scheduled later.
    minScheduleIndexMap(task.Id) = scheduleIndex + isBlocking;
end

for ii = 1:numel(stageTasks)
    % If there are multiple data processors that can run simultaneously, we
    % combine them into one task.
    if numel(stageTasks{ii}) > 1
        stageTasks{ii} = combine(stageTasks{ii}, independentPartitionStrategies{ii});
    end
end
stageTasks = vertcat(stageTasks{:}, StageTask.empty());

function [stageTask, isBlocking, passforwardExecution, passforwardCommDependencies] ...
    = iWrapTask(task, inputExecutions, inputCommDependencies, isOutput, factories)
% Parse a task into its communication pieces and the pieces required to be
% fused into successors.
%
% Inputs:
%  - task: The ExecutionTask being processed.
%  - inputExecutions: An array of passforward executions generated by the
%  predecessors of this task. Each will be a CompositeDataProcessorBuilder
%  instance that knows how to access the data generated by the predecessor.
%  These will be fused into the execution of this task.
%  - inputCommDependencies: The communication dependencies of this task.
%  This must be an array of StageTask dependencies, each representing one
%  piece of communication that this task will be on receiving end of.
%  - isOutput: A scalar logical that is true if and only if this task is
%  required to be sent to the client for gather.
%  - factories: The factories passed to convertToIndependentTasks.
%
% Outputs:
%  - stageTask: A StageTask object representing all the work of this task
%  that must be scheduled. This will contain exactly everything that cannot
%  be fused forward without communication into the task successors. This is
%  allowed to be empty.
%  - isBlocking: A logical scalar that specifies if stageTask must be
%  completed before any successor can access the output of this task.
%  - passforwardExecution: A CompositeDataProcessorBuilder to be fused into
%  successors. This represents how to access the output of this task.
%  - passforwardCommDependencies: An array of StageTask dependencies that
%  represent the communication dependencies of any task that requires the
%  output of this task.
import matlab.bigdata.internal.executor.OutputCommunicationType;
import matlab.bigdata.internal.executor.StageTask;

% Deal with execution.
execution = iCreateExecution(task, inputExecutions, factories);
if ~isempty(factories.GetCacheStoreFunction) ...
        && ~task.ExecutionPartitionStrategy.IsBroadcast ...
        && ~strcmp(task.CacheLevel, 'None')
    execution = iCreateCacheExecution(execution, task, factories);
    inputCommDependencies(end + 1, :) = StageTask.createCacheDependency(task);
end

communicationType = iDetermineCommunicationType(task);

% If the task does not require any communication at all, we can simply fuse
% everything forward into the task's successors.
if ~isOutput && communicationType == OutputCommunicationType.Simple
    stageTask = StageTask.empty();
    passforwardExecution = execution;
    passforwardCommDependencies = inputCommDependencies;
    isBlocking = false;
    return;
end

stageTask = StageTask(task.ExecutionPartitionStrategy);
stageTask = stageTask.addDependencies(inputCommDependencies);

% Deal with communication to successors.
switch communicationType
    case OutputCommunicationType.Simple
        % No communication to successors.
        passforwardExecution = execution;
        passforwardCommDependencies = inputCommDependencies;
        isBlocking = false;
    case OutputCommunicationType.Broadcast
        % Broadcast communication to successors. The output of this task is
        % made available via the broadcast mechanisms.
        [actionableExecution, passforwardExecution] = iCreateBroadcastExecution(execution, task, factories);
        stageTask = stageTask.addExecution(actionableExecution);
        stageTask = stageTask.addBroadcastOutput(task);
        passforwardCommDependencies = StageTask.createBroadcastDependency(task);
        isBlocking = true;
    otherwise
        % Shuffle communication to successors. The output of this task is
        % made available via the shuffle communication mechanisms.
        [actionableExecution, passforwardExecution] = iCreateShuffleExecution(execution, task, factories);
        stageTask = stageTask.addExecution(actionableExecution);
        stageTask = stageTask.addShuffleOutput(task);
        passforwardCommDependencies = StageTask.createShuffleDependency(task);
        isBlocking = true;
end

% Deal with communication to client.
if isOutput
    if communicationType == OutputCommunicationType.Broadcast
        % This value is already broadcasted as required by successors, so
        % the client can simply grab this value.
    elseif task.OutputPartitionStrategy.IsBroadcast || isempty(factories.CreateStreamFactoryFunction)
        % This value is some calculation based on a broadcast value.
        % Broadcast this so it is available directly to the client.
        [outputExecution, ~] = iCreateBroadcastExecution(execution, task, factories);
        stageTask = stageTask.addExecution(outputExecution);
        stageTask = stageTask.addBroadcastOutput(task);
    else
        % Otherwise, communication to client via stream to client
        % mechanisms.
        outputExecution = iCreateStreamExecution(execution, task, factories);
        stageTask = stageTask.addExecution(outputExecution);
        stageTask = stageTask.addStreamOutput(task);
    end
end

function communicationType = iDetermineCommunicationType(task)
% Determine the output communication type of a given task.
%
% The non-Spark back-ends treat IsPassBoundary as an extra communication
% type to simplify the logic of how to schedule the task.
import matlab.bigdata.internal.executor.OutputCommunicationType;
communicationType = task.OutputCommunicationType;
if task.IsPassBoundary && communicationType == OutputCommunicationType.Simple
    if task.OutputPartitionStrategy.IsBroadcast
        communicationType = OutputCommunicationType.Broadcast;
    else
        communicationType = OutputCommunicationType.SameToSame;
    end
end

function execution = iCreateExecution(task, inputExecutions, factories)
% Create a CompositeDataProcessorBuilder that represents the execution part
% of a task fused with all of its predecessors.
import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
import matlab.bigdata.internal.executor.OutputCommunicationType;
if task.OutputCommunicationType == OutputCommunicationType.AnyToAny
    % TODO(g1530319): Knowledge of partition indices here is a wrinkle of
    % DataProcessor API. This should be removed once the API is fixed.
    requiresInputPartitionIndices = false;
    requiresOutputPartitionIndices = true;
    numOutputPartitions = feval(factories.GetNumPartitionsFunction, task.OutputPartitionStrategy);
    execution = CompositeDataProcessorBuilder(inputExecutions, task.DataProcessorFactory,...
        requiresOutputPartitionIndices, requiresInputPartitionIndices, numOutputPartitions);
else
    execution = CompositeDataProcessorBuilder(inputExecutions, task.DataProcessorFactory);
end

function [writerExecution, readerExecution] = iCreateShuffleExecution(execution, task, factories)
% Create a pair of CompositeDataProcessorBuilder that represent the writing
% and subsequent reading of a shuffle communication.
import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
import matlab.bigdata.internal.executor.OutputCommunicationType;
import matlab.bigdata.internal.io.LocalReadProcessor;
import matlab.bigdata.internal.io.LocalWriteProcessor;
[writerFactory, readerFactory] = factories.CreateShuffleStorageFunction(task);
% TODO(g1530319): Knowledge of partition indices here is a wrinkle of
% DataProcessor API. This should be removed once the API is fixed.
requiresOutputPartitionIndices = false;
requiresInputPartitionIndices = task.OutputCommunicationType == OutputCommunicationType.AnyToAny;
writerExecution = CompositeDataProcessorBuilder(execution, ...
    @(partition) LocalWriteProcessor(writerFactory(partition)), ...
    requiresOutputPartitionIndices, requiresInputPartitionIndices);
readerExecution = CompositeDataProcessorBuilder([], @(partition) LocalReadProcessor(readerFactory(partition)));

function [setterExecution, getterExecution] = iCreateBroadcastExecution(execution, task, factories)
% Create a pair of CompositeDataProcessorBuilder objects that represents
% setting and getting a broadcasted value.
import matlab.bigdata.internal.executor.BroadcastProcessor;
import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
import matlab.bigdata.internal.executor.ConstantProcessor;
[setterFunction, getterFunction] = factories.CreateBroadcastStorageFunction(task);
setterExecution = CompositeDataProcessorBuilder(execution, BroadcastProcessor.createFactory(setterFunction));
getterExecution = CompositeDataProcessorBuilder([], ConstantProcessor.createFactoryFromFunction(getterFunction));

function streamWriterExecution = iCreateStreamExecution(execution, task, factories)
% Create a CompositeDataProcessorBuilder object that represents streaming
% data to the client MATLAB context.
import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
import matlab.bigdata.internal.io.LocalReadProcessor;
import matlab.bigdata.internal.io.LocalWriteProcessor;
streamWriterFactory = factories.CreateStreamFactoryFunction(task);
streamWriterExecution = CompositeDataProcessorBuilder(execution, ...
    @(partition) LocalWriteProcessor(streamWriterFactory(partition)));

function execution = iCreateCacheExecution(execution, task, factories)
% Create a CompositeDataProcessorBuilder that represents a cached version
% of an existing piece of execution.
import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
import matlab.bigdata.internal.io.CacheProcessor;
execution = CompositeDataProcessorBuilder(execution, ...
    CacheProcessor.createFactory(task.CacheEntryKey, factories.GetCacheStoreFunction));

function values = iGetFromMap(map, keys, emptyValue)
% Helper function that obtains and vertically concatenates a collection of
% values from a map and collection of keys.
values = cell(size(keys));
for ii = 1:numel(keys)
    values{ii} = map(keys{ii});
end
values = vertcat(values{:}, emptyValue);
