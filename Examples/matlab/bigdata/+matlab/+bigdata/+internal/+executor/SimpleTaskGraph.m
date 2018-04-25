%SimpleTaskGraph
% A graph of ExecutionTask instances that represent one complete execution.
% This has no awareness of how the task graph was generated.

%   Copyright 2016 The MathWorks, Inc.

classdef SimpleTaskGraph < matlab.bigdata.internal.executor.TaskGraph
    properties (SetAccess = private)
        % An array of all tasks in the graph sorted in topological order
        % such that tasks only depend on tasks that came before them in the
        % array.
        Tasks
        
        % An ordered list of tasks for which the output is required to be
        % gathered to the client.
        OutputTasks
    end
    
    methods
        % The main constructor.
        function obj = SimpleTaskGraph(tasks, outputTasks)
            obj.Tasks = tasks;
            obj.OutputTasks = outputTasks;
        end
    end
end
