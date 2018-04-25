classdef FailureTask < matlab.unittest.internal.Task
    % FAILURETASK is the extension of TASK class. It is the default
    % task accepting the diagnostics to diagnose upon default fail events
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access=private)
        Diagnostics;
    end
    
    methods
        function task = FailureTask(diagnostics)
            task.Diagnostics = diagnostics;
        end
        
        function task = set.Diagnostics(task,diagnostics)
            import matlab.unittest.diagnostics.Diagnostic
            task.Diagnostics = [Diagnostic.empty(1,0),diagnostics];
        end
    end
    
    methods (Access=protected)
        function diags = getElementDefaultDiagnostics(task)
            diags = task.Diagnostics;
        end
        
        function diags = getElementVerificationDiagnostics(~)
            diags = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
        end
        
        function diags = getElementAssumptionDiagnostics(~)
            diags = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
        end
    end
end

% LocalWords:  diags
