classdef(Hidden, Abstract) ExtendedDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % This class is undocumented and may change in a future release.
    
    % ExtendedDiagnostic - Interface class for diagnostics which react to diagnostic data
    %
    %   The ExtendedDiagnostic interface class allows subclasses to be more
    %   flexibile with their diagnostic action than the Diagnostic interface.
    %   For example, unless a Diagnostic subclass inherits from
    %   ExtendedDiagnostic, the subclass does not have permissions to set the
    %   Artifacts property.
    %
    %   Each ExtendedDiagnostic subclass must implement a diagnoseWith method
    %   whose input argument is a DiagnosticData instace with properties that
    %   represent diagnostic evaluation options.  When an ExtendedDiagnostic is
    %   used inside of a test, the testing framework will call diagnoseWith
    %   with diagnostic data specific to the test run environment.
    %
    %   Subclasses of ExtendedDiagnostic are provided a sealed implementation
    %   of diagnose that calls diagnoseWith with a default DiagnosticData
    %   instance.
    %
    %   ExtendedDiagnostic methods:
    %       diagnoseWith - Execute diagnostic action for the instance with diagnostic data
    %
    %   See also:
    %       matlab.unittest.diagnostics.Diagnostic
    %       matlab.unittest.diagnostics.DiagnosticData
    %       matlab.unittest.diagnostics.FileArtifact
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(Constant, Access=private)
        DefaultDiagnosticData = matlab.unittest.diagnostics.DiagnosticData();
    end
    
    methods(Sealed)
        function diagnose(diag)
            diag.diagnoseWith(diag.DefaultDiagnosticData);
        end
    end
    
    methods(Hidden, Abstract)
        % diagnoseWith - Execute diagnostic action for the instance with diagnostic data
        %
        %   diagnoseWith(DIAG,DIAGDATA) diagnoses the Diagnostic using the
        %   DiagnosticData instance, DIAGDATA, provided. When a Diagnostic is used
        %   inside of a test, during the execution of a test run the test framework
        %   calls the diagnoseWith method instead of the diagnose method with
        %   diagnostic data specific to the test run environment.
        %
        %   See also:
        %       matlab.unittest.diagnostics.DiagnosticData
        diagnoseWith(diag,diagData)
    end
    
    methods(Hidden)
        function bool = producesSameResultFor(~,diagData1,diagData2)
            % producesSameResultFor - Determines whether the same result is produced for different diagnostic data
            %
            %   bool = producesSameResultFor(DIAG,DIAGDATA1,DIAGDATA2) returns true if
            %   the diagnoseWith method associated with the Diagnostic instance, DIAG,
            %   produces the same diagnostic result for the two different
            %   DiagnosticData instances, DIAGDATA1 and DIAGDATA2. Otherwise false is
            %   returned.
            %
            %   A default implementation is provided, which returns the result of
            %   isequal(DIAGDATA1,DIAGDATA2), but it is recommended that each subclass
            %   of ExtendedDiagnostic override this implementation to help reduce the
            %   number of times diagoseWith is called by the testing framework.
            %
            %   For example, if the subclass's diagnoseWith creates an artifact in the
            %   provided artifacts location regardless of the provided verbosity, then
            %   the producesSameResultFor method could be implemented as:
            %       function bool = producesSameResultFor(~,diagData1,diagData2)
            %           bool = diagData1.ArtifactsFolder == diagData2.ArtifactsFolder;
            %       end
            %   But if the artifact created also depended on the provided verbosity
            %   level, then the implemention could instead be:
            %       function bool = producesSameResultFor(~,diagData1,diagData2)
            %           bool = diagData1.ArtifactsFolder == diagData2.ArtifactsFolder ...
            %               && diagData1.Verbosity == diagData2.Verbosity;
            %       end
            %
            %   See also:
            %       diagnoseWith
            
            bool = isequal(diagData1,diagData2);
        end
    end
end