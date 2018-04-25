classdef DiagnosticsValidationPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                                       matlab.unittest.internal.plugins.HasOutputStreamMixin
    % DiagnosticsValidationPlugin - Plugin to help validate diagnostic code.
    % 
    %   The DiagnosticsValidationPlugin can be added to the TestRunner to
    %   confirm that user supplied diagnostics execute correctly. This is
    %   useful because most of the time tests should not encounter failure
    %   conditions. This means that much of the diagnostic code which are
    %   provided in the user diagnostics does not get exercised. Because
    %   of this, if there is a programming error in the diagnostic code
    %   itself it will never get exercised and found until the test fails.
    %   However, at this point the diagnostics for that failure condition
    %   are lost due to the error in the diagnostic code.
    %
    %   This plugin helps a test author confirm that all of their diagnostic
    %   code is free from programming errors. It does so by unconditionally
    %   evaluating the diagnostics when running tests regardless of whether the
    %   test passes or fails.
    %
    %   Since the diagnostic analysis can reduce the test performance, one
    %   should be aware of such performance impacts before using this plugin
    %   for routine testing.
    %
    %   DiagnosticsValidationPlugin methods:
    %       DiagnosticsValidationPlugin - Class constructor
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.DiagnosticsValidationPlugin;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a TestRunner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(DiagnosticsValidationPlugin);
    %
    %       % Run the suite to see all user supplied diagnostic output
    %       result = runner.run(suite)
    %
    %   See also: TestRunnerPlugin, matlab.unittest.diagnostics
    %
    
    % Copyright 2012-2016 The MathWorks, Inc.
    
    properties(Constant, Access=private)
        MessageCatalog = matlab.internal.Catalog('MATLAB:unittest:DiagnosticsValidationPlugin');
    end
    
    properties(Dependent, Hidden, GetAccess=protected, SetAccess=immutable)
        Printer
    end
    
    properties(Access=private)
        InternalPrinter = [];
    end
    
    methods
        function printer = get.Printer(plugin)
            import matlab.unittest.internal.plugins.LinePrinter;
            printer = plugin.InternalPrinter;
            if isempty(printer)
                printer = LinePrinter(plugin.OutputStream);
                plugin.InternalPrinter = printer;
            end
        end
    end
    
    methods
        function plugin = DiagnosticsValidationPlugin(varargin)
            %DiagnosticsValidationPlugin - Class constructor
            %   PLUGIN = DiagnosticsValidationPlugin creates a
            %   DiagnosticsValidationPlugin instance and returns it in PLUGIN. This
            %   plugin can then be added to a TestRunner instance to show all user
            %   diagnostics encountered in a test regardless of whether the test passes
            %   or fails, which helps to find programming errors in the diagnostic
            %   code.
            %
            %   PLUGIN = DiagnosticsValidationPlugin(STREAM) creates a
            %   DiagnosticsValidationPlugin and redirects all the text output produced
            %   to the OutputStream STREAM. If this is not supplied, a ToStandardOutput
            %   stream is used.
            %
            %   Example:
            %       
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.plugins.DiagnosticsValidationPlugin;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Create an instance of DiagnosticsValidationPlugin
            %       plugin = DiagnosticsValidationPlugin;
            %
            %       % Add the plugin to the TestRunner
            %       runner.addPlugin(plugin);
            %
            %       % Run the suite to see all user supplied diagnostic output
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
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.addDiagnosticListeners(fixture, false);
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.addDiagnosticListeners(testCase, true);
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.addDiagnosticListeners(testCase, true);
        end
    end
    
    
    methods (Access=private)
        function printDiagnosticResults(plugin, eventData)
            import matlab.unittest.internal.diagnostics.wrapHeader;
            formattableResults = eventData.TestDiagnosticResultsStore.getFormattableResults();
            formattableStrings = formattableResults.toFormattableStrings();
            for idx = 1:numel(formattableStrings)
                formattableString = formattableStrings(idx);
                if ~isempty(formattableString.Text)
                    plugin.Printer.printEmptyLine;
                    plugin.Printer.printLine(wrapHeader( ...
                        plugin.MessageCatalog.getString('DiagnosticsValidationHeader')));
                    plugin.Printer.printLine(formattableString);
                end
            end
        end
        
        function addDiagnosticListeners(plugin, content, includeVerifications)
            if includeVerifications
                content.addlistener('VerificationFailed', @(~,evd) plugin.printDiagnosticResults(evd));
                content.addlistener('VerificationPassed', @(~,evd) plugin.printDiagnosticResults(evd));
            end
            
            content.addlistener('AssertionFailed', @(~,evd) plugin.printDiagnosticResults(evd));
            content.addlistener('AssertionPassed', @(~,evd) plugin.printDiagnosticResults(evd));
            content.addlistener('FatalAssertionFailed', @(~,evd) plugin.printDiagnosticResults(evd));
            content.addlistener('FatalAssertionPassed', @(~,evd) plugin.printDiagnosticResults(evd));
            content.addlistener('AssumptionFailed', @(~,evd) plugin.printDiagnosticResults(evd));
            content.addlistener('AssumptionPassed', @(~,evd) plugin.printDiagnosticResults(evd));
        end

    end
    
end

% LocalWords:  unittest mypackage evd Formattable
