classdef FailureDiagnosticsPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                                    matlab.unittest.internal.diagnostics.ErrorReportingMixin & ...
                                    matlab.unittest.internal.plugins.HasOutputStreamMixin
    % FailureDiagnosticsPlugin - Plugin to show diagnostics on failure.
    %
    %   The FailureDiagnosticsPlugin can be added to the TestRunner
    %   to show diagnostics upon failure.
    %
    %   FailureDiagnosticsPlugin methods:
    %       FailureDiagnosticsPlugin - Class constructor
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.FailureDiagnosticsPlugin;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a TestRunner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(FailureDiagnosticsPlugin);
    %
    %       % Run the suite to see diagnostic output on failure
    %       result = runner.run(suite)
    %
    %   See also: TestRunnerPlugin, matlab.unittest.diagnostics
    %
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    
    properties(Constant, Access=private)
        DiagnosticCatalog = matlab.internal.Catalog('MATLAB:unittest:Diagnostic');
        QualificationDelimiter = repmat('=',1,80);
    end
    
    properties(Dependent, GetAccess=private, SetAccess=immutable)
        Printer
    end
    
    properties(Access=private)
        InternalPrinter = [];
    end
    
    methods
        function printer = get.Printer(plugin)
            import matlab.unittest.internal.plugins.DiagnosticsPrinter;
            printer = plugin.InternalPrinter;
            if isempty(printer)
                printer = DiagnosticsPrinter(plugin.OutputStream);
                plugin.InternalPrinter = printer;
            end
        end

        function plugin = FailureDiagnosticsPlugin(varargin)
            %FailureDiagnosticsPlugin - Class constructor
            %   PLUGIN = FailureDiagnosticsPlugin creates a FailureDiagnosticsPlugin
            %   instance and returns it in PLUGIN. This plugin can then be added to a
            %   TestRunner instance to show diagnostics when test failure conditions
            %   are encountered.
            %
            %   PLUGIN = FailureDiagnosticsPlugin(STREAM) creates a
            %   FailureDiagnosticsPlugin and redirects all the text output produced to
            %   the OutputStream STREAM. If this is not supplied, a ToStandardOutput
            %   stream is used.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.plugins.FailureDiagnosticsPlugin;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Create an instance of FailureDiagnosticsPlugin
            %       plugin = FailureDiagnosticsPlugin;
            %
            %       % Add the plugin to the TestRunner
            %       runner.addPlugin(plugin);
            %
            %       % Run the suite and see diagnostics on failure
            %       result = runner.run(suite)
            %
            %   See also: OutputStream, ToStandardOutput
            %
            plugin = plugin@matlab.unittest.internal.plugins.HasOutputStreamMixin(varargin{:});
        end
    end
    
    methods(Hidden)
        function tf = supportsParallel(~)
            tf = true;
        end
    end
    
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.internal.plugins.DiagnosticsPrinter;
            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            % Print a summary table showing the failed and incomplete tests
            if ~isempty(getFailedAndIncompleteTests(pluginData.TestResult))
                plugin.Printer.printLine(plugin.DiagnosticCatalog.getString('FailureSummary'));
                plugin.Printer.printEmptyLine();
                plugin.Printer.printIndentedLine(...
                    plugin.getResultSummaryTable(pluginData.TestResult));
            end
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            fixtureName = pluginData.Name;
            fixture.addlistener('AssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('SharedTestFixtureAssertionFailed', fixtureName)));
            
            fixture.addlistener('FatalAssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('SharedTestFixtureFatalAssertionFailed', fixtureName)));
            
            fixture.addlistener('AssumptionFailed', @(~,evd) plugin.printAssumptionFailure(evd, ...
                plugin.DiagnosticCatalog.getString('SharedTestFixtureAssumptionFailureSummary', fixtureName), ...
                plugin.DiagnosticCatalog.getString('SharedTestFixtureAssumptionFailureDetails', fixtureName)));
            
            
            fixture.addlistener('ExceptionThrown', @(~, evd)plugin.printUncaughtException(evd, ...
                plugin.DiagnosticCatalog.getString('SharedTestFixtureUncaughtException', fixtureName)));
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            containerName = pluginData.Name;
            
            testCase.addlistener('VerificationFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestClassVerificationFailed', containerName)));
            
            testCase.addlistener('AssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestClassAssertionFailed', containerName)));
            
            testCase.addlistener('FatalAssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestClassFatalAssertionFailed', containerName)));
            
            testCase.addlistener('AssumptionFailed', @(~,evd) plugin.printAssumptionFailure(evd, ...
                plugin.DiagnosticCatalog.getString('TestClassAssumptionFailureSummary', containerName), ...
                plugin.DiagnosticCatalog.getString('TestClassAssumptionFailureDetails', containerName)));
            
            
            testCase.addlistener('ExceptionThrown', @(~, evd)plugin.printUncaughtException(evd, ...
                plugin.DiagnosticCatalog.getString('TestClassUncaughtException', containerName)));
        end
        
        function testCase = createTestRepeatLoopInstance(plugin, pluginData)
            testCase = createTestRepeatLoopInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            testName = pluginData.Name;
            
            testCase.addlistener('VerificationFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodVerificationFailed', testName)));
            
            testCase.addlistener('AssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodAssertionFailed', testName)));
            
            testCase.addlistener('FatalAssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodFatalAssertionFailed', testName)));
            
            testCase.addlistener('AssumptionFailed', @(~,evd) plugin.printAssumptionFailure(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodAssumptionFailureSummary', testName), ...
                plugin.DiagnosticCatalog.getString('TestMethodAssumptionFailureDetails', testName)));
                        
            testCase.addlistener('ExceptionThrown', @(~, evd)plugin.printUncaughtException(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodUncaughtException', testName)));
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            testName = pluginData.Name;
            
            testCase.addlistener('VerificationFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodVerificationFailed', testName)));
            
            testCase.addlistener('AssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodAssertionFailed', testName)));
            
            testCase.addlistener('FatalAssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodFatalAssertionFailed', testName)));
            
            testCase.addlistener('AssumptionFailed', @(~,evd) plugin.printAssumptionFailure(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodAssumptionFailureSummary', testName), ...
                plugin.DiagnosticCatalog.getString('TestMethodAssumptionFailureDetails', testName)));
            
            
            testCase.addlistener('ExceptionThrown', @(~, evd)plugin.printUncaughtException(evd, ...
                plugin.DiagnosticCatalog.getString('TestMethodUncaughtException', testName)));
        end
        
        function str = getResultSummaryTable(plugin, result)
            % getResultSummaryTable - Return a string with information
            %   about failed and incomplete tests.
            
            import matlab.unittest.internal.plugins.failureSummaryTable;
            
            NAME_HEADER = plugin.DiagnosticCatalog.getString('Name');
            FAILED_HEADER = plugin.DiagnosticCatalog.getString('Failed');
            INCOMPLETE_HEADER = plugin.DiagnosticCatalog.getString('Incomplete');
            REASONS_HEADER = plugin.DiagnosticCatalog.getString('Reasons');
            
            ASSUMPTION_FAILED = plugin.DiagnosticCatalog.getString('AssumptionFailed');
            VERIFICATION_FAILED = plugin.DiagnosticCatalog.getString('VerificationFailed');
            ASSERTION_FAILED = plugin.DiagnosticCatalog.getString('AssertionFailed');
            ERRORED = plugin.DiagnosticCatalog.getString('Errored');
            
            % Get the tests that need to be displayed in the table
            tests = getFailedAndIncompleteTests(result);
            
            reasons = cell(numel(tests), 1);
            for idx = 1:numel(tests)
                addReason('AssumptionFailed', ASSUMPTION_FAILED);
                addReason('VerificationFailed', VERIFICATION_FAILED);
                addReason('AssertionFailed', ASSERTION_FAILED);
                addReason('Errored', ERRORED);
            end
            
            function addReason(typeName, reasonMessage)
                if tests(idx).(typeName)
                    reasons{idx} = [reasons{idx}, {reasonMessage}];
                end
            end
            
            headers = {NAME_HEADER, FAILED_HEADER, INCOMPLETE_HEADER, REASONS_HEADER};
            data = [{tests.Name}.', {tests.Failed}.', {tests.Incomplete}.', reasons];
            
            str = failureSummaryTable(headers, data);
        end
    end
    
    methods(Access=private)
        function printFailureCondition(plugin, evd, headerMessage)
            plugin.Printer.printEmptyLine();
            formattableTestResults = evd.TestDiagnosticResultsStore.getFormattableResults();
            formattableFrameworkResults = evd.FrameworkDiagnosticResultsStore.getFormattableResults();
            formattableAdditionalResults = evd.AdditionalDiagnosticResultsStore.getFormattableResults();
            plugin.Printer.printQualificationReport(...
                formattableTestResults.toFormattableStrings(), ...
                formattableFrameworkResults.toFormattableStrings(), ...
                formattableAdditionalResults.toFormattableStrings(),...
                headerMessage, evd.Stack);
        end
        
        function printUncaughtException(plugin, evd, headerMessage)
            plugin.Printer.printEmptyLine();
            formattableAdditionalResults = evd.AdditionalDiagnosticResultsStore.getFormattableResults();
            plugin.Printer.printUncaughtException(headerMessage, evd.Exception.identifier,...
                plugin.getExceptionReport(evd.Exception),formattableAdditionalResults.toFormattableStrings());
        end
        
        function printAssumptionFailure(plugin, evd, summaryHeaderMessage, detailsHeaderMessage)
            plugin.Printer.printEmptyLine();
            formattableTestResults = evd.TestDiagnosticResultsStore.getFormattableResults();
            formattableFrameworkResults = evd.FrameworkDiagnosticResultsStore.getFormattableResults();
            formattableAdditionalResults = evd.AdditionalDiagnosticResultsStore.getFormattableResults();
            plugin.Printer.printAssumptionFailure(...
                formattableTestResults.toFormattableStrings(), ...
                formattableFrameworkResults.toFormattableStrings(), ...
                formattableAdditionalResults.toFormattableStrings(),...
                summaryHeaderMessage, detailsHeaderMessage, evd.Stack);
        end
    end
end

function tests = getFailedAndIncompleteTests(result)
tests = result([result.Failed] | [result.Incomplete]);
end

% LocalWords:  unittest mypackage evd Formattable
