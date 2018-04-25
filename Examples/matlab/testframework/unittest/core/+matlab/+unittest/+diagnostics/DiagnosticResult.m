classdef DiagnosticResult
    % DiagnosticResult - The result of a diagnostic evaluation of a Diagnostic object
    %
    %   The DiagnosticResult is a data structure which captures the result of a
    %   diagnosed Diagnostic. It allows for a safe alternative to working with
    %   the diagnosed Diagnostic instances directly.
    %
    %   A DiagnosticResult should not be instantiated directly. Instead it
    %   will be provided as property values on the QualificationEventData,
    %   LoggedDiagnosticEventData, QualificationDiagnosticRecord, and
    %   LoggedDiagnosticRecord classes.
    %
    %   DiagnosticResult properties:
    %       Artifacts      - Artifacts produced during a Diagnostic's diagnostic evaluation
    %       DiagnosticText - Text result of a Diagnostic's diagnostic evaluation
    %
    %   See also:
    %       matlab.unittest.diagnostics.Diagnostic
    %       matlab.unittest.qualifications.QualificationEventData
    %       matlab.unittest.diagnostics.LoggedDiagnosticEventData
    %       matlab.unittest.plugins.diagnosticrecord.QualificationDiagnosticRecord
    %       matlab.unittest.plugins.diagnosticrecord.LoggedDiagnosticRecord
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(SetAccess=private)
        % Artifacts - Artifacts produced during a Diagnostic's diagnostic evaluation
        %
        %   The Artifacts property of a DiagnosticResult instance is a copy of
        %   the Artifacts property of the associated Diagnostic instance after
        %   it has been diagnosed.
        %
        %   See also:
        %       matlab.unittest.diagnostics.Diagnostic
        %       matlab.unittest.diagnostics.FileArtifact
        Artifacts (1,:) matlab.unittest.diagnostics.Artifact
        
        % DiagnosticText - Text result of a Diagnostic's diagnostic evaluation
        %
        %   The DiagnosticText property of a DiagnosticResult instance is a copy of
        %   the DiagnosticText property of the associated Diagnostic instance after
        %   it has been diagnosed.
        %
        %   See also:
        %       matlab.unittest.diagnostics.Diagnostic
        DiagnosticText char
    end
    
    methods(Hidden)
        function result = DiagnosticResult(artifacts,diagnosticText)
            if ~isequal(diagnosticText,'')
                validateattributes(diagnosticText,{'char'},{'row'},'','DiagnosticText');
            end
            result.Artifacts = artifacts;
            result.DiagnosticText = diagnosticText;
        end
    end
end