classdef DiagnosticsRecordingPlugin < matlab.unittest.plugins.TestRunnerPlugin
    % DiagnosticsRecordingPlugin - Plugin to record diagnostics on test results.
    %
    %   The DiagnosticsRecordingPlugin can be added to the TestRunner
    %   to record diagnostics on test results. These diagnostics are
    %   recorded as DiagnosticRecord arrays. Each of the DiagnosticRecords
    %   corresponds to events in individual tests. The DiagnosticsRecordingPlugin
    %   adds records for qualification failures and logged events by
    %   default.
    %
    %   DiagnosticsRecordingPlugin methods:
    %       DiagnosticsRecordingPlugin - Class constructor
    %
    %   DiagnosticsRecordingPlugin properties:
    %       IncludePassingDiagnostics - Boolean that specifies whether diagnostics from passing events are recorded
    %       Verbosity - Levels supported by this plugin instance
    %       ExcludeLoggedDiagnostics - Boolean that specifies whether logged diagnostics are recorded
    %
    %   Name/Value Options:
    %       Name                          Value
    %       ----                          -----
    %       IncludingPassingDiagnostics   False or true (logical 0 or 1) that specifies
    %                                     whether diagnostics from passing
    %                                     events are included on the test results. 
    %                                     Default is false.
    %       Verbosity                     Member of the
    %                                     matlab.unittest.Verbosity
    %                                     enumeration that specifies at what
    %                                     level the logged messages will be
    %                                     recorded. Default is
    %                                     matlab.unittest.Verbosity.Terse.
    %       ExcludingLoggedDiagnostics    False or true (logical 0 or 1)
    %                                     that specifies whether
    %                                     diagnostics from logged events
    %                                     are excluded from the test results. 
    %                                     Default is false.
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.DiagnosticsRecordingPlugin;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a TestRunner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(DiagnosticsRecordingPlugin);
    %
    %       % Run the suite to see diagnostics recorded on test results
    %       result = runner.run(suite)
    %
    %       % Inspect recorded diagnostics
    %       for resultIdx = 1:numel(result)
    %           fprintf('Displaying diagnostics for result: %d\n', resultIdx);
    %           diagnosticRecord = result(resultIdx).Details.DiagnosticRecord;
    %           for recordIdx = 1:numel(diagnosticRecord)
    %               fprintf('Result: %d, Record: %d\n', resultIdx, recordIdx);
    %               fprintf('%s in %s\n',diagnosticRecord(recordIdx).Event,...
    %                   diagnosticRecord(recordIdx).Scope);
    %           fprintf('%s\n', diagnosticRecord(recordIdx).Report);
    %           end
    %       end
    %
    %       % Select records for failed events within the first test
    %       diagnosticRecords = result(1).Details.DiagnosticRecord;
    %       failedRecords     = selectFailed(diagnosticRecords);
    %
    %       % Select records for incomplete events within the first test
    %       diagnosticRecords = result(1).Details.DiagnosticRecord;
    %       incompleteRecords = selectIncomplete(diagnosticRecords);
    %
    %       % Select records for filtered events within the first test
    %       diagnosticRecords = result(1).Details.DiagnosticRecord;
    %       incompleteRecords = selectIncomplete(diagnosticRecords);
    %       failedRecords     = selectFailed(diagnosticRecords);
    %       filteredRecords   = setdiff(incompleteRecords, failedRecords);
    %
    %   See also: matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord
    %
    
    % Copyright 2015-2016 The MathWorks, Inc.
    properties(SetAccess=immutable)
        % IncludePassingDiagnostics - Boolean that specifies whether diagnostics from passing events are recorded
        %   The IncludePassingDiagnostics property is a boolean (true or false)
        %   that specifies whether diagnostics from passing events are recorded
        %   on test results. This property is read only and can be set only
        %   through the constructor.
        IncludePassingDiagnostics;
                
        % ExcludeLoggedDiagnostics - Boolean that specifies whether logged diagnostics are recorded
        %   The ExcludeLoggedDiagnostics property is a boolean (true or false)
        %   that specifies whether logged diagnostics are recorded on 
        %   test results. This property is read only and can be set only
        %   through the constructor.
        ExcludeLoggedDiagnostics;
    end
    
    properties(Access=protected)
        TestResultDiagnosticRecordProducer
    end
    
    properties(Constant, Access=private)
        DiagnosticCatalog = matlab.internal.Catalog('MATLAB:unittest:Diagnostic');
    end
    
    properties (SetAccess = private)
        % Verbosity - Levels supported by this plugin instance
        %   The Verbosity property is an array of matlab.unittest.Verbosity
        %   instances. The plugin only reacts to diagnostics that are logged at a
        %   level listed in this array.
        Verbosity;
    end
    
    methods
        function plugin = DiagnosticsRecordingPlugin(varargin)
            % DiagnosticsRecordingPlugin - Class constructor
            %   PLUGIN = DiagnosticsRecordingPlugin creates a DiagnosticsRecordingPlugin
            %   instance and returns it in PLUGIN. This plugin can then be added to a
            %   TestRunner instance to record diagnostics on test results when failure
            %   conditions and logged events are encountered.
            %
            %   PLUGIN = DiagnosticsRecordingPlugin('IncludingPassingDiagnostics', true) creates a
            %   DiagnosticsRecordingPlugin that records diagnostics from
            %   passing tests on test results.
            %
            %   PLUGIN = DiagnosticsRecordingPlugin('Verbosity', VERBOSITY)
            %   creates a plugin that records messages logged at level VERBOSITY
            %   or lower on test results.
            %
            %   PLUGIN = DiagnosticsRecordingPlugin('ExcludingLoggedDiagnostics', true) creates a
            %   DiagnosticsRecordingPlugin that excludes logged diagnostics from
            %   test results.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.plugins.DiagnosticsRecordingPlugin;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Create an instance of DiagnosticsRecordingPlugin
            %       plugin = DiagnosticsRecordingPlugin;
            %
            %       % Add the plugin to the TestRunner
            %       runner.addPlugin(plugin);
            %
            %       % Run the suite to see diagnostics recorded on test results
            %       result = runner.run(suite)
            %
            %       Inspect recorded diagnostics
            %       diagnosticRecord = result(1).Details.DiagnosticRecord;
            %
            %   See also: FailureDiagnosticsPlugin, LoggingPlugin
            %
            parser = createParser();
            parser.parse(varargin{:});
            
            plugin.IncludePassingDiagnostics = parser.Results.IncludingPassingDiagnostics;
            plugin.Verbosity = matlab.unittest.Verbosity(1:double(parser.Results.Verbosity));
            plugin.ExcludeLoggedDiagnostics = parser.Results.ExcludingLoggedDiagnostics;
        end
    end
    
    methods(Hidden)
        function tf = supportsParallel(~)
            tf = true;
        end
        
        function plugin = applyVerbosity(plugin,verbosity)
            plugin.Verbosity = matlab.unittest.Verbosity(1:double(verbosity));
        end
    end
    
    methods(Access=protected)
        function runTestSuite(plugin, pluginData)
            plugin.TestResultDiagnosticRecordProducer = ...
                plugin.createTestResultDiagnosticRecordProducer(pluginData);
            plugin.runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            plugin.TestResultDiagnosticRecordProducer.addListenersToSharedTestFixture(fixture, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = plugin.createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            eventLocation = pluginData.Name;
            plugin.TestResultDiagnosticRecordProducer.addListenersToTestClassInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestRepeatLoopInstance(plugin, pluginData)
            testCase = plugin.createTestRepeatLoopInstance@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            eventLocation = pluginData.Name;
            plugin.TestResultDiagnosticRecordProducer.addListenersToTestRepeatLoopInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = plugin.createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            eventLocation = pluginData.Name;
            plugin.TestResultDiagnosticRecordProducer.addListenersToTestMethodInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
    end
    
    methods(Access=private)
        function recordProducer = createTestResultDiagnosticRecordProducer(plugin,pluginData)
            import matlab.unittest.internal.plugins.TestResultDiagnosticRecordProducer;
            recordProducer = TestResultDiagnosticRecordProducer(pluginData); %#ok<CPROPLC>
            recordProducer.VerbosityLevels = plugin.Verbosity;
            if ~plugin.IncludePassingDiagnostics
                passingEvents = ["VerificationPassed","AssertionPassed",...
                    "FatalAssertionPassed","AssumptionPassed"];
                recordProducer.FixtureEvents = setdiff(recordProducer.FixtureEvents, passingEvents);
                recordProducer.TestCaseEvents = setdiff(recordProducer.TestCaseEvents, passingEvents);
            end
            if plugin.ExcludeLoggedDiagnostics
                recordProducer.FixtureEvents = setdiff(recordProducer.FixtureEvents, "DiagnosticLogged");
                recordProducer.TestCaseEvents = setdiff(recordProducer.TestCaseEvents, "DiagnosticLogged");
            end
        end
    end
end

function parser = createParser()
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('IncludingPassingDiagnostics', false, @(bool)validateattributes(bool, ...
                                                            {'logical'}, {'scalar'}, ''));
parser.addParameter('ExcludingLoggedDiagnostics', false, @(bool)validateattributes(bool, ...
                                                            {'logical'}, {'scalar'}, ''));                                                        
parser.addParameter('Verbosity', matlab.unittest.Verbosity.Terse, @validateVerbosity);
end

function validateVerbosity(verbosity)
validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'verbosity');
% Validate that a numeric value is valid
matlab.unittest.Verbosity(verbosity);
end

% LocalWords:  mypackage diagnosticrecord evd