%ProgressReporter
% Interface that receives information about the progress of an execution.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Abstract) ProgressReporter < handle
    methods (Abstract)
        % Mark the start of execution by the provided executor.
        %
        % This expects both the number of tasks and number of passes
        % through the input data. This expects that each pass is contained
        % in exactly one task.
        startOfExecution(obj, executorName, numTasks, numPasses)
        
        % Mark the start of one task.
        %
        % This expects a scalar logical specifying whether the next task
        % does a full pass through the underlying data. A task that does
        % not pass through the input data is assumed to have less cost.
        startOfNextTask(obj, isFullPass)
        
        % Mark an update to progress in the middle of the current task.
        %
        % This expects a value between 0 and 1 specifying how much of the
        % current task is complete.
        progress(obj, progressValue)
        
        % Mark the end of the current task.
        endOfTask(obj)
        
        % Mark the end of execution.
        endOfExecution(obj)
    end
    
    methods (Static)
        % The ProgressReporter used by default by the Execution Environments.
        function out = getCurrent()
            import matlab.bigdata.internal.executor.CommandWindowProgressReporter
            import matlab.bigdata.internal.executor.ProgressReporter

            persistent defaultProgressReporter;
            if isempty(defaultProgressReporter)
                defaultProgressReporter = CommandWindowProgressReporter();
            end
            
            out = ProgressReporter.override();
            
            if isempty(out)
                out = defaultProgressReporter;
            end
        end
        
        % Override the default ProgressReporter used by the Execution Environments.
        function out = override(in)
            persistent overrideInstance;
            
            if nargout
                out = overrideInstance;
            end
            
            if nargin
                assert (isempty(in) || isa(in, 'matlab.bigdata.internal.executor.ProgressReporter'))
                overrideInstance = in;
            end
        end
    end
end
