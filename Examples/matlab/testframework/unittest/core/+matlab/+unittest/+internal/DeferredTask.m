classdef DeferredTask < matlab.unittest.internal.Task
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Access=private)
        TaskProvider function_handle;
    end
    
    methods
        function task = DeferredTask(fcn)
            task.TaskProvider = fcn;
        end
    end
    
    methods (Access=protected)
        function diags = getElementDefaultDiagnostics(task)
            providedTasks = task.TaskProvider();
            diags = providedTasks.getDefaultQualificationDiagnostics;
        end
        
        function diags = getElementVerificationDiagnostics(task)
            providedTasks = task.TaskProvider();
            diags = providedTasks.getVerificationDiagnostics;
        end
              
        function diags = getElementAssumptionDiagnostics(task)
            providedTasks = task.TaskProvider();
            diags = providedTasks.getAssumptionDiagnostics;
        end
    end
end

% LocalWords:  diags
