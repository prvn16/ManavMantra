function outTaskGraph = combineSimpleTasks(taskGraph)
%COMBINESIMPLETASKS Transforms a task graph by combining all non-caching simple tasks forward.
%
% Syntax:
%  taskGraph = combineSimpleTasks(taskGraph);
%
% This will combine all tasks that fit the following criteria into direct
% downstream tasks:
%  1. The task must have simple (non-communicating) output.
%  2. The task must not cache its output.
%  3. The output of the task must not be required for gather.
%  

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
import matlab.bigdata.internal.executor.ExecutionTask;
import matlab.bigdata.internal.executor.OutputCommunicationType;
import matlab.bigdata.internal.executor.SimpleTaskGraph;

% A map of task ID an instance of CompositeDataProcessorBuilder that
% generates the same output but that can be combined forward into
% downstream tasks. A task ID can map to empty, in which case it is not
% possible to combine
passForwardNodeMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% A map of all tasks already processed for the purpose of creating new
% ExecutionTask objects.
taskMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

tasks = taskGraph.Tasks;
outputTasks = taskGraph.OutputTasks;
newTasks = ExecutionTask.empty;
for ii = 1:numel(tasks)
    task = tasks(ii);
    
    inputNodes = cell(size(task.InputIds));
    isPassForwardTrivial = true;
    for jj = 1:numel(task.InputIds)
        inputNodes{jj} = passForwardNodeMap(task.InputIds{jj});
        isPassForwardTrivial = isPassForwardTrivial && isempty(inputNodes{jj}.DataProcessorFactory);
    end
    inputNodes = vertcat(CompositeDataProcessorBuilder.empty, inputNodes{:});
    
    isOutputSimple = ~ismember(task, outputTasks) ...
        && ~task.IsPassBoundary ...
        && task.OutputCommunicationType == OutputCommunicationType.Simple ...
        && strcmp(task.CacheLevel, 'None');
    
    if isOutputSimple
        % This task can be combined forward into downstream tasks.
        passForwardNodeMap(task.Id) = CompositeDataProcessorBuilder(inputNodes, task.DataProcessorFactory);
    else
        % This task has non-simple output, this task must be visible to the
        % execution environment.
        passForwardNodeMap(task.Id) = CompositeDataProcessorBuilder([], task.Id);
        if ~isPassForwardTrivial
            newProcessor = CompositeDataProcessorBuilder(inputNodes, task.DataProcessorFactory);
            
            newInputIds = newProcessor.AllInputIds;
            newInputTasks = cell(size(newInputIds));
            for jj = 1:numel(newInputIds)
                newInputTasks{jj} = taskMap(newInputIds{jj});
            end
            newInputTasks = vertcat(newInputTasks{:});
            
            newTask = task.copyWithReplacedInputs(newInputTasks, newProcessor);
            outputTasks(task == outputTasks) = newTask;
            
            task = newTask;
        end
        newTasks(end + 1, 1) = task; %#ok<AGROW>
    end
    
    taskMap(task.Id) = task;
end

outTaskGraph = SimpleTaskGraph(newTasks, outputTasks);
