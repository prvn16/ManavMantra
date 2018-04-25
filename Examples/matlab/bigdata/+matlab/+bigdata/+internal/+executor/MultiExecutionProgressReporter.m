%MultiExecutionProgressReporter
% Class that wraps a ProgressReporter with the means to span multiple
% gather statements.
%
% This is used by matlab.bigdata.internal.startMultiExecution
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Sealed) MultiExecutionProgressReporter < matlab.bigdata.internal.executor.ProgressReporter
    properties (SetAccess = immutable)
        % The underlying progress reporter.
        InternalProgressReporter;
        
        % The total number of tasks over the full execution.
        TotalNumTasks = NaN;
        
        % The total number of passes over the full execution.
        TotalNumPasses = NaN;
    end
    
    properties (SetAccess = private)
        % A logical scalar that specifies whether this object has received
        % the first startOfExecution call.
        HasStarted = false;
    end
    
    methods
        function obj = MultiExecutionProgressReporter(progressReporter, totalNumTasks, totalNumPasses)
            obj.InternalProgressReporter = progressReporter;
            if nargin >= 2
                obj.TotalNumTasks = totalNumTasks;
            end
            if nargin >= 3
                obj.TotalNumPasses = totalNumPasses;
            end
        end
        
        function delete(obj)
            if obj.HasStarted
                obj.InternalProgressReporter.endOfExecution();
            end
        end
    end
    
    % Overrides of the ProgressReporter interface.
    methods
        % Mark the start of execution by the provided executor.
        function startOfExecution(obj, name, ~, ~)
            if ~obj.HasStarted
                obj.InternalProgressReporter.startOfExecution(name, obj.TotalNumTasks, obj.TotalNumPasses);
                
                obj.HasStarted = true;
            end
        end
        
        % Mark the start of one task.
        function startOfNextTask(obj, isFullPass)
            obj.InternalProgressReporter.startOfNextTask(isFullPass);
        end
        
        % Mark an update to progress in the middle of the current task.
        function progress(obj, progressValue)
            obj.InternalProgressReporter.progress(progressValue);
        end
        
        % Mark the end of the current task.
        function endOfTask(obj)
            obj.InternalProgressReporter.endOfTask();
        end
        
        % Mark the end of execution.
        function endOfExecution(~)
        end
    end
end
