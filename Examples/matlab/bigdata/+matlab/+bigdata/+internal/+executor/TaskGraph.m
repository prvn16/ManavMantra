%TaskGraph
% A graph of ExecutionTask instances that represent one complete execution.
%

%   Copyright 2015 The MathWorks, Inc.

classdef (Abstract) TaskGraph < handle
    properties (Abstract, SetAccess = private)
        % An array of all tasks in the graph sorted in topological order
        % such that tasks only depend on tasks that came before them in the
        % array.
        Tasks
        
        % An ordered list of tasks for which the output is required to be
        % gathered to the client.
        OutputTasks
    end
end
