classdef(Hidden) CompositeDiagnostic < matlab.unittest.diagnostics.ExtendedDiagnostic
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    properties (Hidden, Access=protected)
        ComposedDiagnostics (1,:) matlab.unittest.diagnostics.Diagnostic = ...
            matlab.unittest.diagnostics.Diagnostic.empty(1,0);
    end
    
    methods(Hidden, Abstract, Access=protected)
        diagText = createDiagnosticText(diag)
    end
    
    methods(Hidden, Sealed)
        function diagnoseWith(diag,diagData)
            import matlab.unittest.diagnostics.FileArtifact;
            
            arrayfun(@(composedDiag) composedDiag.diagnoseWith(diagData),...
                diag.ComposedDiagnostics);
            diag.DiagnosticText = diag.createDiagnosticText();
            diag.Artifacts = [FileArtifact.empty(1,0), diag.ComposedDiagnostics.Artifacts];
        end
        
        function bool = producesSameResultFor(diag,diagData1,diagData2)
            bool = true;
            for composedDiag = diag.ComposedDiagnostics
                if ~composedDiag.producesSameResultFor(diagData1,diagData2)
                    bool = false;
                    return;
                end
            end
        end
    end
end