%CommandWindowProgressReporter
% Class that prints progress update messages to the command window.
%
% This will print and update in place a progress status line per pass. This
% will also print an overall progress percentage. This will appear as:
%
% Evaluating tall expression using the Local MATLAB Session:
%  - Pass 1 of 3: Completed in 1.2 mins
%  - Pass 2 of 3: 80% complete
% Evaluation 54% complete
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) CommandWindowProgressReporter < matlab.bigdata.internal.executor.ProgressReporter
    properties (SetAccess = private)
        % The number of characters that we need to remove in order to
        % overwrite an existing progress message in the command window.
        NumInPlaceCharacters = 0;
        
        % The number of tasks of the current execution.
        NumTasks
        
        % The number of tasks that require a full pass of the source data.
        NumPasses;
        
        % The number of completed tasks.
        NumCompletedTasks;
        
        % The number of completed passes.
        NumCompletedPasses;
        
        % Whether the current task is a full pass through the underlying
        % data.
        IsFullPass;
        
        % The output of tic at task beginning.
        CurrentPassTic;
        
        % The output of tic at execution beginning.
        OverallTic;
        
        % Stores the previous progress value which is used to determine
        % whether to update the execution progress report.
        PreviousProgressValue;
    end
    
    properties (Constant)
        % This class considers tasks that do a full pass of the underlying
        % data to be more costly than tasks that do not. This constant
        % is for the purposes of the overall percentage, it specifies how
        % many ordinary tasks that a a full pass task is equivalent to.
        PassProgressWeight = 10;
    end
    
    methods
        function startOfExecution(obj, name, numTasks, numPasses)
            obj.NumTasks = numTasks;
            obj.NumPasses = numPasses;
            obj.NumCompletedTasks = 0;
            obj.NumCompletedPasses = 0;
            obj.IsFullPass = false;
            obj.OverallTic = tic;
            
            fprintf('%s', getString(message('MATLAB:bigdata:executor:ProgressBegin', name)));
            % This puts the trailing new line character to be replaced on
            % the next progress event.
            obj.NumInPlaceCharacters = 1;
            obj.addFooter();
        end
        
        function startOfNextTask(obj, isFullPass)
            obj.IsFullPass = isFullPass;
            obj.CurrentPassTic = tic;
            obj.PreviousProgressValue = -inf;
            obj.progress(0);
        end
        
        function progress(obj, progressValue)
            if progressValue <= obj.PreviousProgressValue
                return;
            end
            
            newText = '';
            if obj.IsFullPass
                newText = obj.generatePassProgressString(progressValue);
            end
            newText = [newText, obj.generateOverallProgressString(progressValue)];
            
            obj.updateInplaceText(newText);
            obj.PreviousProgressValue = progressValue;
        end
        
        function endOfTask(obj)
            if obj.IsFullPass
                % We want to leave each pass progress line once
                % completed.
                obj.updateInplaceTextAndFix(obj.generatePassCompleteString());
                
                obj.NumCompletedPasses = obj.NumCompletedPasses + 1;
            end
            obj.NumCompletedTasks = obj.NumCompletedTasks + 1;
            obj.addFooter();
        end
        
        function endOfExecution(obj)
            obj.updateInplaceTextAndFix(obj.generateOverallCompleteString());
        end
    end
    
    methods (Access = private)
        % Add the footer to the progress update in-between tasks. This is
        % not necessary during tasks because task update includes this
        % string already.
        function addFooter(obj)
            obj.updateInplaceText(obj.generateOverallProgressString(0));
        end
        
        % Update the in-place text to the new text. All future updates will
        % overwrite the text from this call.
        function updateInplaceText(obj, newText)
            if isdeployed
                % Write the new text on a new line when deployed so that
                % control characters do not appear in the output.
                fprintf('\n%s', newText);
            else
                % We do the entire update with a single fprintf as this
                % prevents flickering.
                fprintf([repmat('\b', 1, obj.NumInPlaceCharacters), '\n%s'], newText);
                obj.NumInPlaceCharacters = numel(newText) + 1;
            end
        end
        
        % Update the in-place text to the new text and then convert the
        % in-place text to be permanent. All future updates will appear
        % below the text from this call.
        function updateInplaceTextAndFix(obj, newText)
            obj.updateInplaceText(newText);
            obj.NumInPlaceCharacters = 1;
        end
        
        % Generate a progress line for a pass in progress.
        function text = generatePassProgressString(obj, progressValue)
            if isnan(obj.NumPasses)
                text = getString(message('MATLAB:bigdata:executor:ProgressPassUpdate', ...
                    obj.NumCompletedPasses + 1, sprintf('%.0f', progressValue * 100)));
            else
                text = getString(message('MATLAB:bigdata:executor:ProgressPassWithNumPassesUpdate', ...
                    obj.NumCompletedPasses + 1, obj.NumPasses, sprintf('%.0f', progressValue * 100)));
            end
        end
        
        % Generate a progress line for a pass in progress.
        function text = generatePassCompleteString(obj)
            numSeconds = toc(obj.CurrentPassTic);
            if isnan(obj.NumPasses)
                text = getString(message('MATLAB:bigdata:executor:ProgressPassComplete', ...
                    obj.NumCompletedPasses + 1, matlab.bigdata.internal.util.generateTimeString(numSeconds)));
            else
                text = getString(message('MATLAB:bigdata:executor:ProgressPassWithNumPassesComplete', ...
                    obj.NumCompletedPasses + 1, obj.NumPasses, matlab.bigdata.internal.util.generateTimeString(numSeconds)));
            end
        end
        
        % Generate the overall completion line while execution in is progress.
        function text = generateOverallProgressString(obj, progressValue)
            if isnan(obj.NumPasses) || isnan(obj.NumTasks)
                text = '';
                return;
            end
            
            currentTaskProgressWeight = 1;
            if obj.IsFullPass
                currentTaskProgressWeight = obj.PassProgressWeight;
            end
            
            weightedProgress = obj.NumCompletedTasks + obj.NumCompletedPasses * (obj.PassProgressWeight - 1) + progressValue * currentTaskProgressWeight;
            weightedTotal = obj.NumTasks + (obj.PassProgressWeight - 1) * obj.NumPasses;
            overallProgress = weightedProgress / weightedTotal;
            if isnan(overallProgress)
                overallProgress = 0;
            end
            
            text = getString(message('MATLAB:bigdata:executor:ProgressOverallUpdate', ...
                sprintf('%.0f', overallProgress * 100)));
        end
        
        % Generate the overall completion line when execution is finished
        function text = generateOverallCompleteString(obj)
            numSeconds = toc(obj.OverallTic);
            text = getString(message('MATLAB:bigdata:executor:ProgressOverallComplete', ...
                matlab.bigdata.internal.util.generateTimeString(numSeconds)));
        end
    end
end
