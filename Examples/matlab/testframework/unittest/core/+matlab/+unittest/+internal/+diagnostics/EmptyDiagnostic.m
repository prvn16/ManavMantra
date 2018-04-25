classdef EmptyDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % EmptyDiagnostic - An empty Diagnostic implementation
    %
    %   The EmptyDiagnostic class is a diagnostic implementation which provides
    %   no diagnostic information. There is no need for users to interact with
    %   this Diagnostic directly. However, it may be the preferred diagnostic
    %   to use in certain situations for tool writers, such as in the
    %   definition of the getDiagnosticFor method on a Constraint for a passing
    %   value where no diagnostics are needed.
    %
    %   See also
    %       Diagnostic
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    methods
        function diag = EmptyDiagnostic
            diag.DiagnosticText = '';
        end
        
        function diagnose(~)
        end
    end
end