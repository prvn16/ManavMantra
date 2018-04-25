classdef TAPPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                     matlab.unittest.internal.plugins.HasOutputStreamMixin
    %TAPPlugin - Plugin that produces a TAP Stream
    %   The TAPPlugin allows one to configure a TestRunner to produce output
    %   conforming to the Test Anything Protocol (TAP). When the test output is
    %   produced using this format, MATLAB Unit Test results can be integrated
    %   into other third party systems that recognize the TAP protocol. For
    %   example, using this plugin MATLAB tests can be integrated into
    %   continuous integration systems like <a href="http://jenkins-ci.org/">Jenkins</a>TM or <a href="http://www.jetbrains.com/teamcity">TeamCity</a>(R).
    %
    %   TAPPlugin Methods:
    %       producingOriginalFormat - Construct a plugin that produces the original TAP format.
    %       producingVersion13      - Construct a plugin that produces the Version 13 TAP format.
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.TAPPlugin;
    %       import matlab.unittest.plugins.ToFile;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a test runner
    %       runner = TestRunner.withTextOutput;
    %
    %       % Add a TAPPlugin to the TestRunner
    %       tapFile = 'MyTAPOutput.tap';
    %       plugin = TAPPlugin.producingOriginalFormat(ToFile(tapFile));
    %       runner.addPlugin(plugin);
    %
    %       result = runner.run(suite);
    %
    %       disp(fileread(tapFile));
    %
    %   See also: TestRunnerPlugin, ToFile
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=private, GetAccess=protected)
        BailOutMessage = '';
    end
    
    properties(Hidden, Access=protected)
        Printer %set inside of runTestSuite method of each subclass
    end
    
    methods(Static)
        function plugin = producingOriginalFormat(varargin)
            % producingOriginalFormat - Construct a plugin that produces the original TAP format.
            %
            %   PLUGIN = TAPPlugin.producingOriginalFormat() returns a plugin that
            %   produces text output in the form of the original Test Anything Protocol
            %   format (version 12). This output is printed to the MATLAB Command
            %   Window. Any other output also produced to the Command Window can
            %   invalidate the TAP stream. This can be avoided by sending the TAP
            %   output to another OutputStream as shown below.
            %
            %   PLUGIN = TAPPlugin.producingOriginalFormat(STREAM) creates a plugin
            %   and redirects all the text output produced to the OutputStream STREAM.
            %   If this is not supplied, a ToStandardOutput stream is used.
            %
            %   PLUGIN = TAPPlugin.producingOriginalFormat(..., NAME, VALUE) constructs a
            %   TAPPlugin with one or more Name/Value pairs. Specify any of the
            %   following Name/Value pairs:
            %
            %     * IncludingPassingDiagnostics   False or true (logical 0 or 1) that specifies
            %                                     whether diagnostics from passing
            %                                     events are included in the TAP stream.
            %                                     Default is false.
            %
            %     * Verbosity                     Member of the
            %                                     matlab.unittest.Verbosity
            %                                     enumeration that specifies at what
            %                                     level the logged messages will be
            %                                     included in the TAP stream. Default is
            %                                     matlab.unittest.Verbosity.Terse.
            %
            %     * ExcludingLoggedDiagnostics    False or true (logical 0 or 1)
            %                                     that specifies whether
            %                                     diagnostics from logged events
            %                                     are excluded in the TAP stream.
            %                                     Default is false.
            %
            %   Examples:
            %       import matlab.unittest.plugins.TAPPlugin;
            %       import matlab.unittest.plugins.ToFile;
            %
            %       % Create a TAP plugin that sends TAP Version 12 Output
            %       % to the MATLAB Command Window
            %       plugin = TAPPlugin.producingOriginalFormat;
            %
            %       % Create a TAP plugin that sends TAP Version 12 Output to a file
            %       plugin = TAPPlugin.producingOriginalFormat(ToFile('MyTAPStream.tap'));
            %
            %       % Create a TAP plugin that includes passing diagnostics
            %       % in TAP Version 12 Output
            %       plugin = TAPPlugin.producingOriginalFormat('IncludingPassingDiagnostics', true);
            %
            %       % Create a TAP plugin that includes diagnostics logged
            %       % at and below Concise level in TAP Version 12 Output
            %       import matlab.unittest.Verbosity;
            %       plugin = TAPPlugin.producingOriginalFormat('Verbosity', Verbosity.Concise);
            %
            %       % Create a TAP plugin that excludes logged diagnostics
            %       % from TAP Version 12 Output
            %       plugin = TAPPlugin.producingOriginalFormat('ExcludingLoggedDiagnostics', true);
            %
            %
            %   See also: OutputStream, ToFile, TAPPlugin.producingVersion13
            
            parser = createParser();
            parser.parse(varargin{:});
            plugin = matlab.unittest.plugins.tap.TAPOriginalFormatPlugin(parser.Results.OutputStream, parser.Results.IncludingPassingDiagnostics, ...
                parser.Results.Verbosity, parser.Results.ExcludingLoggedDiagnostics);
        end
    end
    methods(Static)
        function plugin = producingVersion13(varargin)
            % producingVersion13 - Construct a plugin that produces the Version 13 TAP format.
            %
            %   PLUGIN = TAPPlugin.producingVersion13() returns a plugin that
            %   produces text output in the form of the Test Anything Protocol
            %   format (version 13) and includes diagnostics in a YAML block.
            %   This output is displayed in the MATLAB Command Window. Other
            %   output sent to the Command Window can invalidate the TAP stream.
            %   To avoid this, redirect the TAP output to another OutputStream.
            %
            %   PLUGIN = TAPPlugin.producingVersion13(STREAM) creates a plugin
            %   and redirects all the text output produced to the OutputStream STREAM.
            %   If STREAM is not supplied, a ToStandardOutput stream is used.
            %
            %   PLUGIN = TAPPlugin.producingVersion13(..., NAME, VALUE) constructs a
            %   TAPPlugin with one or more Name/Value pairs. Specify any of the
            %   following Name/Value pairs:
            %
            %     * IncludingPassingDiagnostics   False or true (logical 0 or 1) that specifies
            %                                     whether diagnostics from passing
            %                                     events are included in the TAP stream.
            %                                     Default is false.
            %
            %     * Verbosity                     Member of the
            %                                     matlab.unittest.Verbosity
            %                                     enumeration that specifies at what
            %                                     level the logged messages will be
            %                                     included in the TAP stream. Default is
            %                                     matlab.unittest.Verbosity.Terse.
            %
            %     * ExcludingLoggedDiagnostics    False or true (logical 0 or 1)
            %                                     that specifies whether
            %                                     diagnostics from logged events
            %                                     are excluded in the TAP stream.
            %                                     Default is false.
            %
            %   Examples:
            %       import matlab.unittest.plugins.TAPPlugin;
            %       import matlab.unittest.plugins.ToFile;
            %
            %       % Create a TAP plugin that sends TAP Version 13 Output
            %       % to the MATLAB Command Window
            %       plugin = TAPPlugin.producingVersion13;
            %
            %       % Create a TAP plugin that sends TAP Version 13 Output to a file
            %       plugin = TAPPlugin.producingVersion13(ToFile('MyTAPStream.tap'));
            %
            %       % Create a TAP plugin that includes passing diagnostics
            %       % in TAP Version 13 Output
            %       plugin = TAPPlugin.producingVersion13('IncludingPassingDiagnostics', true);
            %
            %       % Create a TAP plugin that includes diagnostics logged
            %       % at and below Concise level in TAP Version 13 Output
            %       import matlab.unittest.Verbosity;
            %       plugin = TAPPlugin.producingVersion13('Verbosity', Verbosity.Concise);
            %
            %       % Create a TAP plugin that excludes logged diagnostics
            %       % from TAP Version 13 output
            %       plugin = TAPPlugin.producingVersion13('ExcludingLoggedDiagnostics', true);
            %
            %   See also: OutputStream, ToFile, TAPPlugin.producingOriginalFormat
            
            parser = createParser();
            parser.addParameter('GroupedByFile', false, @(v) validateattributes(v, {'logical'}, {'scalar'}));
            parser.addParameter('StallFile', '', @ischar);
            parser.parse(varargin{:});
            
            if ~parser.Results.GroupedByFile
                plugin = matlab.unittest.plugins.tap.TAPVersion13Plugin(parser.Results.OutputStream, parser.Results.IncludingPassingDiagnostics, ...
                    parser.Results.Verbosity, parser.Results.ExcludingLoggedDiagnostics);
            else
                plugin = matlab.unittest.internal.plugins.tap.TAPTestFilePlugin(parser.Results.StallFile,parser.Results.OutputStream);
            end
        end
    end
    
    methods(Hidden)
        function tf = supportsParallel(~)
            tf = true;
        end
    end
    
    methods(Access=protected)
        function plugin = TAPPlugin(outputStream)
            plugin = plugin@matlab.unittest.internal.plugins.HasOutputStreamMixin(outputStream);
        end
    end
    
    
    methods (Access=protected)
        
        function runTestSuite(plugin, pluginData)
            plugin.BailOutMessage = '';
            printBailOut = onCleanup(@()plugin.Printer.printLine(plugin.BailOutMessage));
            plugin.runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            fixture.addlistener('FatalAssertionFailed', @(obj, evd) plugin.bailOut(obj, evd, eventLocation));
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            testCase.addlistener('FatalAssertionFailed', @(obj, evd) plugin.bailOut(obj, evd, eventLocation));
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            testCase.addlistener('FatalAssertionFailed', @(obj, evd) plugin.bailOut(obj, evd, eventLocation));
        end
    end
    
    methods(Hidden, Access= protected)
        
        function tapLine = printTAPResult(plugin, result, count, name)
            not = '';
            skip = '';
            if any([result.Failed])
                % Handle failures
                not = 'not ';
            elseif all([result.Incomplete])
                % Handle filtered tests
                skip = ' # SKIP ';
            end
            tapLine = sprintf('%sok %d - %s%s', ...
                not, count, name, skip);
            plugin.Printer.printLine(tapLine);
        end
        
        
    end
    
    methods(Access=private)
        
        function bailOut(plugin, ~, evd, eventLocation)
            
            if ~isempty(plugin.BailOutMessage)
                % Only report on the first fatal assertion.
                return;
            end
            
            % "Bail out!" is a part of the TAP specification and should not be translated.
            str = sprintf('Bail out! %s', eventLocation);
            
            formattableResults = evd.TestDiagnosticResultsStore.getFormattableResults();
            formattableStrings = formattableResults.toFormattableStrings();
            
            for idx = 1:numel(formattableStrings)
                formattableString = formattableStrings(idx);
                if strlength(formattableString.Text) > 0
                    formattableString = regexprep(formattableString, '\n.*', '');
                    str = sprintf('%s: %s', str, formattableString);
                    break;
                end
            end
            plugin.BailOutMessage = str;
        end
        
        
    end
end

function parser = createParser()
import matlab.unittest.plugins.ToStandardOutput;
parser = matlab.unittest.internal.strictInputParser;
parser.addOptional('OutputStream', ToStandardOutput, @(stream)validateattributes(...
    stream, {'matlab.unittest.plugins.OutputStream'}, ...
    {'scalar'}, '', 'stream'));
parser.addParameter('Verbosity', matlab.unittest.Verbosity.Terse, @validateVerbosity);
parser.addParameter('IncludingPassingDiagnostics', false, @(bool)validateattributes(...
    bool, {'logical'}, {'scalar'}, ''));
parser.addParameter('ExcludingLoggedDiagnostics', false, @(bool)validateattributes(...
    bool, {'logical'}, {'scalar'}, ''));
end

function validateVerbosity(verbosity)
validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'verbosity');
% Validate that a numeric value is valid
matlab.unittest.Verbosity(verbosity);
end

% LocalWords:  mypackage jenkins ci jetbrains teamcity evd sok YAML Formattable
% LocalWords:  strlength
