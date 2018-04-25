classdef Task < matlab.mixin.Heterogeneous
    % TASK superclass for storing the onFailure Diagnostics.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Abstract, Access=protected)
        diags = getElementDefaultDiagnostics(task);
        diags = getElementVerificationDiagnostics(task)
        diags = getElementAssumptionDiagnostics(task)
    end
    
    methods (Sealed)
        function diags = getDefaultQualificationDiagnostics(tasks)
            diags = tasks.getDiagnosticsUsing(@getElementDefaultDiagnostics);
        end
        
        function diags = getVerificationDiagnostics(tasks)
            diags = tasks.getDiagnosticsUsing(@getElementVerificationDiagnostics);
        end
        
        function diags = getAssumptionDiagnostics(tasks)
            diags = tasks.getDiagnosticsUsing(@getElementAssumptionDiagnostics);
        end
    end
    
    methods (Sealed, Access=private)
        function diags = getDiagnosticsUsing(tasks, fcn)
            import matlab.unittest.diagnostics.Diagnostic;
            diags = arrayfun(fcn, tasks, 'UniformOutput',false);
            diags = [Diagnostic.empty(1,0), diags{:}];
        end
    end
end

% LocalWords:  diags
