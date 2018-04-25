%OutputFunctionProgressReporter
% Class that calls an output function handle on every progress update.
%
% This function handle must have the form:
%
%  function fcn(progressValue, passIndex, numPasses)
%
% With inputs:
%  - progressValue: A value between 0 and 1 indicating progress of the
%  current pass.
%  - passIndex: The index of the currently running pass.
%  - numPasses: The total number of passes if known, otherwise NaN.
%
% This object can also print the start and end line of evaluation if
% PrintBasicInformation is set to true.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) OutputFunctionProgressReporter < matlab.bigdata.internal.executor.ProgressReporter
    properties (SetAccess = immutable)
        % A function handle that will be called on every progress update.
        OutputFunction;
        
        % The output function itself.
        PrintBasicInformation = true;
    end
    
    properties (SetAccess = private)
        % The number of tasks that require a full pass of the source data.
        NumPasses;
        
        % The index of the current pass being evaluated.
        PassIndex;
        
        % Whether the current task is a full pass through the underlying
        % data.
        IsFullPass;
        
        % The output of tic at task beginning.
        CurrentPassTic;
        
        % The output of tic at execution beginning.
        OverallTic;
        
        % Stores the previous progress time in seconds which is used to
        % determine whether to update the execution progress report.
        PreviousProgressTime;
        
        % Stores the previous progress value which is used to determine
        % whether to update the execution progress report.
        PreviousProgressValue;
    end
    
    properties (Constant)
        % The amount of time in seconds between progress updates are
        % generated.
        TimeStepInSeconds = 1;
    end
    
    methods
        % The main constructor.
        function obj = OutputFunctionProgressReporter(outputFunction, printBasicInformation)
            obj.OutputFunction = outputFunction;
            if nargin >= 2
                obj.PrintBasicInformation = printBasicInformation;
            end
        end
    end
    
    % Overrides of the ProgressReporter interface.
    methods
        % Mark the start of execution by the provided executor.
        function startOfExecution(obj, name, ~, numPasses)
            if obj.PrintBasicInformation
                fprintf('%s', getString(message('MATLAB:bigdata:executor:ProgressBegin', name)));
            end
            
            obj.NumPasses = numPasses;
            obj.PassIndex = 0;
            obj.OverallTic = tic;
        end
        
        % Mark the start of one task.
        function startOfNextTask(obj, isFullPass)
            obj.IsFullPass = isFullPass;
            obj.PassIndex = obj.PassIndex + isFullPass;
            obj.CurrentPassTic = tic;
            obj.PreviousProgressValue = -inf;
            obj.PreviousProgressTime = -inf;
            obj.progress(0);
        end
        
        % Mark an update to progress in the middle of the current task.
        function progress(obj, progressValue)
            if ~obj.IsFullPass
                return;
            end
            
            if progressValue <= obj.PreviousProgressValue
                return;
            end
            
            progressTime = toc(obj.CurrentPassTic);
            if progressValue ~= 1 && progressTime <= obj.PreviousProgressTime + obj.TimeStepInSeconds
                return;
            end
            
            feval(obj.OutputFunction, progressValue, obj.PassIndex, obj.NumPasses);
            obj.PreviousProgressValue = progressValue;
            obj.PreviousProgressTime = progressTime;
        end
        
        % Mark the end of the current task.
        function endOfTask(obj)
            obj.progress(1);
        end
        
        % Mark the end of execution.
        function endOfExecution(obj)
            if obj.PrintBasicInformation
                numSeconds = toc(obj.OverallTic);
                fprintf('%s', getString(message('MATLAB:bigdata:executor:ProgressOverallComplete', ...
                    matlab.bigdata.internal.util.generateTimeString(numSeconds))));
            end
        end
    end
end

