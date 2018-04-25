classdef(Hidden) DiagnosticData
    % DiagnosticData - Data that ExtendedDiagnostic instances may react to
    %
    %   The testing framework passes in a DiagnosticData instance to the
    %   diagnoseWith method of the ExtendedDiagnostic subclass which
    %   contains data specific to the current test run environment.
    %
    %   DiagnosticData properties:
    %       ArtifactsFolder - Folder where diagnostic artifacts should be saved
    %       Verbosity - Level of detail diagnostics should provide when diagnosed
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(SetAccess = private)
        % ArtifactsFolder - Folder where diagnostic artifacts should be saved
        ArtifactsFolder (1,1) string = tempdir();
        
        % Verbosity - Level of detail diagnostics should provide when diagnosed
        Verbosity (1,1) matlab.unittest.Verbosity = matlab.unittest.Verbosity.Terse;
    end
    
    properties(Constant, Access=private)
        ArgumentParser = createArgumentParser();
    end
    
    methods(Hidden)
        function diagData = DiagnosticData(varargin)
            import matlab.unittest.diagnostics.DiagnosticData;
            import matlab.unittest.Verbosity;
            
            parser = DiagnosticData.ArgumentParser;
            parser.parse(varargin{:});
            diagData.ArtifactsFolder = string(parser.Results.ArtifactsFolder);
            diagData.Verbosity = Verbosity(parser.Results.Verbosity);
        end
    end
end

function parser = createArgumentParser()
parser = matlab.unittest.internal.strictInputParser;
parser.StructExpand = true;
parser.addParameter('ArtifactsFolder',tempdir(),...
    @(x) validateattributes(x,{'char','string'},{'scalartext'},'','ArtifactsFolder'));
parser.addParameter('Verbosity',matlab.unittest.Verbosity.Terse);
end