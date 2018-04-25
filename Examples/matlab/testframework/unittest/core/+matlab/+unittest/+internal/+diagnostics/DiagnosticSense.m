classdef DiagnosticSense
    % DiagnosticSense - Enumeration for Positive/Negative diagnostics
    %       matlab.unittest.internal.diagnostics.DiagnosticSense.Positive -
    %           Identifies requiring a diagnostic for a getDiagnosticFor() method.
    %       matlab.unittest.internal.diagnostics.DiagnosticSense.Negative -
    %           Identifies requiring a diagnostic for a getNegativeDiagnosticFor() method.
    %
    %   See also
    %       matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory
    
    %   Copyright 2010-2012 The MathWorks, Inc.
    
    enumeration
        %Positive   Enumeration for a positive constraint
        %   Used for creating a diagnostic for a getDiagnosticFor() method.
        Positive ()
        
        %Negative   Enumeration for a negative constraint
        %   Used for creating a diagnostic for a getNegativeDiagnosticFor() method.
        Negative ()
    end
end