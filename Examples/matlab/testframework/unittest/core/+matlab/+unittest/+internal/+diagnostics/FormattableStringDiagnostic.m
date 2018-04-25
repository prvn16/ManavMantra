classdef FormattableStringDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    methods
        function diag = FormattableStringDiagnostic(formattableString)
            diag.DiagnosticText = formattableString;
        end
        
        function diagnose(~)
        end
    end
end

% LocalWords:  formattable