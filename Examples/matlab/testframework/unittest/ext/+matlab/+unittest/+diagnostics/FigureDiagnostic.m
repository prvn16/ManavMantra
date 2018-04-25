classdef FigureDiagnostic < matlab.unittest.internal.mixin.PrefixMixin & ...
        matlab.unittest.diagnostics.ExtendedDiagnostic
    % FigureDiagnostic - A diagnostic which saves a provided figure to specified formats
    %
    %   The FigureDiagnostic class provides a diagnostic which saves a provided
    %   figure to specified formats. If no formats are specified, then by
    %   default the diagnostic saves the provided figure to a FIG file and PNG
    %   file. The provided figure is saved immediately when the
    %   FigureDiagnostic instance is diagnosed. The DiagnosticText property of
    %   the FigureDiagnostic instance will contain information regarding the
    %   names and location of the saved files. The Artifacts property will
    %   contain FileArtifact instances associated with the saved files.
    %
    %   Each saved file will be given a name which contains a unique identifier
    %   in order to avoid naming conflicts with other files. The location of
    %   saved files will be partially determined by the ArtifactsRootFolder
    %   property on the TestRunner used to run any tests containing
    %   FigureDiagnostic instances. Otherwise, if FigureDiagnostic instances
    %   are used outside of a test run or diagnosed manually via the diagnose
    %   method, the location will be equal to tempdir().
    %
    %   FigureDiagnostic methods:
    %       FigureDiagnostic - Class constructor
    %
    %   FigureDiagnostic properties:
    %       Figure  - Figure to save
    %       Formats - File formats in which to save the provided figure
    %       Prefix  - Character vector prepended to the names of the saved files
    %
    %   Examples:
    %
    %       % Create a test file that uses the FigureDiagnostic
    %       classdef testFeature < matlab.unittest.TestCase
    %           properties
    %               Figure;
    %           end
    %           
    %           methods(TestClassSetup)
    %               function setupExampleFigure(testCase)
    %                   testCase.Figure = figure;
    %                   testCase.addTeardown(@close,testCase.Figure);
    %                   ax = axes(testCase.Figure);
    %                   surf(ax,peaks);
    %               end
    %           end
    %
    %           methods(Test)
    %               function testFailureExample1(testCase)
    %                   import matlab.unittest.diagnostics.FigureDiagnostic;
    %                   % Provide a FigureDiagnostic as a Test Diagnostic
    %                   testCase.verifyTrue(false, ... % fail for demonstration purposes
    %                       FigureDiagnostic(testCase.Figure));
    %               end
    %
    %               function testFailureExample2(testCase)
    %                   import matlab.unittest.diagnostics.FigureDiagnostic;
    %                   % Save to PNG image file only
    %                   testCase.assertFail(... % fail for demonstration purposes
    %                       FigureDiagnostic(testCase.Figure,'Formats',{'png'}));
    %               end
    %
    %               function testLogExample(testCase)
    %                   import matlab.unittest.diagnostics.FigureDiagnostic;
    %                   import matlab.unittest.Verbosity;
    %                   % Provide a FigureDiagnostic with a custom prefix as a Logged Diagnostic
    %                   testCase.log(Verbosity.Terse, ... % log for demonstration purposes
    %                       FigureDiagnostic(testCase.Figure,'Prefix','LoggedFigure_'));
    %               end
    %           end
    %       end
    %
    %       % Create a runner with a specified artifacts root folder
    %       runner = matlab.unittest.TestRunner.withTextOutput;
    %       exampleArtifactsRootFolder = fullfile(pwd,'MyTestArtifacts');
    %       mkdir(exampleArtifactsRootFolder);
    %       runner.ArtifactsRootFolder = exampleArtifactsRootFolder;
    %
    %       % Run the test file with the runner
    %       suite = testsuite('testFeature.m');
    %       runner.run(suite);
    %
    %   See also:
    %       tempdir
    %       matlab.unittest.TestRunner/ArtifactsRootFolder
    %       matlab.unittest.diagnostics.Diagnostic
    %       matlab.unittest.diagnostics.FileArtifact
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        % Figure - Figure to save
        %
        %   The Figure property contains the figure which the diagnostic
        %   will save during its diagnostic evalutation.
        Figure
    end
    
    properties(SetAccess=private)
        % Formats - File formats in which to save the provided figure
        %
        %   The Formats property contains a string array representing the file
        %   formats to be used when the diagnostic saves the provided figure during
        %   its diagnostic evaluation. For each file format listed, a file
        %   associated with that format will be saved.
        Formats = ["fig","png"];
    end
    
    properties(Constant, Access=private)
        FormatsParser = createFormatsParser();
    end
    
    methods
        function diag = FigureDiagnostic(fig, varargin)
            % FigureDiagnostic - Class constructor
            %
            %   FigureDiagnostic(fig) creates a new FigureDiagnostic instance
            %   associated with the provided figure, fig. When diagnosed, the instance
            %   saves the figure to a FIG file and a PNG file. Each file is given a
            %   unique name, [prefix uniqueIdentifier extension], where prefix is
            %   'Figure_' by default, uniqueIdentifier is an automatically generated
            %   unique identifier, and extension is '.fig' or '.png' respectively. The
            %   locations of the saved files can be viewed within the character vector
            %   set on the DiagnosticText property or can be programmatically accessed
            %   by the FileArtifact instances set on the Artifacts property.
            %
            %   FigureDiagnostic(...,'Formats',formats) creates a new FigureDiagnostic
            %   instance which saves the figure to files associated with the formats
            %   provided. formats can be given as a unique string array or a unique
            %   cell array of character vectors containing at least one of the
            %   following supported formats:
            %       "fig" - produces a MATLAB figure file with extension '.fig'
            %       "png" - produces an image file with extension '.png'
            %   If not provided, the default value for 'Formats' is ["fig","png"].
            %
            %   FigureDiagnostic(...,'Prefix',prefix) creates a new FigureDiagnostic
            %   instance which saves the figure to files whoses name begins with the
            %   prefix provided. prefix can be given as a string scalar or a character
            %   vector. If not provided, the default value for 'Prefix' is 'Figure_'.
            %
            %   See also:
            %       matlab.unittest.diagnostics.Diagnostic/Artifacts
            %       matlab.unittest.diagnostics.Diagnostic/DiagnosticText
            %       matlab.unittest.diagnostics.FileArtifact
            
            validateattributes(fig,{'matlab.ui.Figure'},{'scalar'},'','Figure');
            defaultPrefix = 'Figure_';
            if ~isvalid(fig)
                error(message('MATLAB:unittest:FigureDiagnostic:InvalidFigure'));
            end
            diag = diag@matlab.unittest.internal.mixin.PrefixMixin(defaultPrefix);
            diag = diag.addNameValue('Formats',@setFormats,@formatsPreSet);
            diag.parse(varargin{:});
            diag.Figure = fig;
            
            validatePrefixInAGeneratedPathname(diag.Prefix,char(diag.Formats(1)));
        end
    end
    
    methods(Hidden)
        function diagnoseWith(diag,diagData)
            import matlab.unittest.internal.generateUUID;
            import matlab.unittest.diagnostics.FileArtifact;
            import matlab.unittest.internal.diagnostics.CommandHyperlinkableString;
            
            fileNameWithoutExt = fullfile(char(diagData.ArtifactsFolder), ...
                char(diag.Prefix + generateUUID()));
            
            artifactsCell = arrayfun(@(format) figureToArtifact(...
                diag.Figure, fileNameWithoutExt, format),...
                diag.Formats, 'UniformOutput', false);
            artifacts = [artifactsCell{:}];
            
            fileLinksCell = arrayfun(@(artifact) indentWithArrow(CommandHyperlinkableString(...
                artifact.FullPath, createCommandThatOpensFile(artifact))), ...
                artifacts, 'UniformOutput',false);
            fileLinks = [fileLinksCell{:}];
            
            diag.Artifacts = artifacts;
            diag.DiagnosticText = join([...
                getString(message('MATLAB:unittest:FigureDiagnostic:FigureSaved')),...
                fileLinks],newline());
        end
        
        function bool = producesSameResultFor(~,diagData1,diagData2)
            bool = diagData1.ArtifactsFolder == diagData2.ArtifactsFolder;
        end
    end
    
    methods(Access=private)
        function diag = setFormats(diag,value)
            diag.Formats = value;
        end
        
        function [diag,value] = formatsPreSet(diag,value)
            parser = diag.FormatsParser;
            parser.parse('Formats',value);
            value = reshape(string(parser.Results.Formats),1,[]);
            if numel(unique(value)) ~= numel(value)
                error(message('MATLAB:unittest:FigureDiagnostic:FormatsMustBeUnique'));
            end
        end
    end
end


function parser = createFormatsParser()
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('Formats',["fig","png"],...
    @(x) ~isempty(x) && all(ismember(x,["fig","png"])));
end


function artifact = figureToArtifact(fig,fileNameWithoutExt,format)
import matlab.unittest.diagnostics.FileArtifact;
file = [fileNameWithoutExt '.'  char(format)];
try
    saveas(fig,file,char(format));
catch cause
    exception = MException(message('MATLAB:unittest:FigureDiagnostic:CouldNotSaveFigure'));
    exception = exception.addCause(cause);
    throw(exception);
end
artifact = FileArtifact(file);
end


function cmdText = createCommandThatOpensFile(artifact)
charSafeFile = strrep(char(artifact.FullPath),'''','''''');
if strcmp(artifact.Extension,'.png')
    cmdText = sprintf('web(''%s'',''-new'');',charSafeFile);
else %.fig
    cmdText = sprintf('[~]=openfig(''%s'',''visible'');',charSafeFile);
end
end


function validatePrefixInAGeneratedPathname(prefix,format)
import matlab.unittest.internal.generateUUID;
import matlab.unittest.internal.validateGeneratedPathname;
validateGeneratedPathname(prefix + generateUUID() + "." + format,'Prefix');
end