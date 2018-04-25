classdef(Abstract) TaskDecorator < matlab.unittest.internal.Task
    % TASKDECORATOR extends matlab.unittest.internal.Task and is an abstract
    % class for AddVerifyEventDecorator and AddAssumptionEventDecorator
    % classes.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access=private)
        DecoratedTask = matlab.unittest.internal.Task.empty;
    end
    
    methods
        function taskArray = TaskDecorator(tasks)
            
            if nargin<1
                return
            end
            validateattributes(tasks,{'matlab.unittest.internal.Task'},{})
            taskArray = repmat(taskArray,size(tasks));
            
            tasksCell = num2cell(tasks);
            [taskArray.DecoratedTask] = tasksCell{:};
        end
    end
    
    methods (Access=protected)
        function diags = getElementDefaultDiagnostics(task)
            diags = task.DecoratedTask.getDefaultQualificationDiagnostics;
        end
        
        function diags = getElementVerificationDiagnostics(task)
            diags = task.DecoratedTask.getVerificationDiagnostics;
        end
              
        function diags = getElementAssumptionDiagnostics(task)
            diags = task.DecoratedTask.getAssumptionDiagnostics;
        end
    end
end

% LocalWords:  diags
