classdef StopOnFailuresPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                                matlab.unittest.internal.mixin.IncludingAssumptionFailuresMixin
    % StopOnFailuresPlugin - Plugin to debug test failures.
    %
    %   The StopOnFailuresPlugin can be added to the TestRunner to pause execution
    %   of a test run and enter debug mode upon a qualification failure or
    %   uncaught error. By default, the StopOnFailuresPlugin only reacts to
    %   uncaught errors and verification, assertion, and fatal assertion
    %   qualification failures. However, when 'IncludingAssumptionFailures'
    %   is specified as true, the plugin also reacts to assumption failures.
    %
    %   Upon encountering a qualification failure, the StopOnFailuresPlugin
    %   causes MATLAB to enter debug mode. At that point, MATLAB debugging
    %   commands such as DBUP, DBSTEP, DBCONT, and DBQUIT can be used to
    %   investigate the cause of the test failure.
    %
    %   The StopOnFailuresPlugin also causes MATLAB to enter debug mode upon
    %   encountering an uncaught error in a test. However, because the error
    %   disrupted the stack, it is not possible to use DBUP to shift context
    %   to the source of the error.
    %
    %   StopOnFailuresPlugin methods:
    %       StopOnFailuresPlugin - Class constructor
    %
    %   StopOnFailuresPlugin properties:
    %       IncludeAssumptionFailures - Boolean that specifies whether to react to assumption failures
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.StopOnFailuresPlugin;
    %
    %       % Create a TestSuite array
    %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a TestRunner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(StopOnFailuresPlugin('IncludingAssumptionFailures', true));
    %
    %       % Run the suite to enter debug mode upon failures
    %       result = runner.run(suite)
    %
    %   See also: TestRunnerPlugin, DBUP, DBSTEP, DBCONT, DBQUIT
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    properties(Constant, Access=private)
        LinePrinter = matlab.unittest.internal.plugins.LinePrinter(...
            matlab.unittest.plugins.ToStandardOutput);
    end
    
    methods
        function plugin = StopOnFailuresPlugin(varargin)
            % StopOnFailuresPlugin - Class constructor
            %
            %   PLUGIN = StopOnFailuresPlugin creates a StopOnFailuresPlugin
            %   instance and returns it in PLUGIN. This plugin can then be added to
            %   a TestRunner instance to pause execution of a test run and enter
            %   debug mode upon encountering a qualification failure or uncaught error.
            %
            %   Example:
            %       
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.plugins.StopOnFailuresPlugin;
            %
            %       % Create a TestSuite array
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Add a new plugin to the TestRunner
            %       runner.addPlugin(StopOnFailuresPlugin('IncludingAssumptionFailures', true));
            %
            %       % Run the suite to enter debug mode upon failures
            %       result = runner.run(suite)
            %
            
            plugin = plugin.parse(varargin{:});
        end
    end
    
    methods (Access=protected)
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.addQualificationFailedListeners(fixture, false);
            fixture.addlistener('ExceptionThrown', @(~, evd)plugin.handleUncaughtError(evd));
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.addQualificationFailedListeners(testCase, true);
            testCase.addlistener('ExceptionThrown', @(~, evd)plugin.handleUncaughtError(evd));
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.addQualificationFailedListeners(testCase, true);
            testCase.addlistener('ExceptionThrown', @(~, evd)plugin.handleUncaughtError(evd));
        end               
    end
    
    methods (Access=private)
        
        function addQualificationFailedListeners(plugin, content, includeVerificationFailures)
            if includeVerificationFailures
                content.addlistener('VerificationFailed', @(~,evd)plugin.handleQualificationFailure(evd));
            end
            
            content.addlistener('AssertionFailed'     , @(~,evd)plugin.handleQualificationFailure(evd));
            content.addlistener('FatalAssertionFailed', @(~,evd)plugin.handleQualificationFailure(evd));
            
            if plugin.IncludeAssumptionFailures
                content.addlistener('AssumptionFailed', @(~,evd)plugin.handleQualificationFailure(evd));
            end
        end
        
        function handleQualificationFailure(plugin, eventData)
            import matlab.unittest.internal.diagnostics.AlternativeRichString;
            import matlab.unittest.internal.diagnostics.CommandHyperlinkableString;
            
            if isempty(eventData.Stack)
                msg = message('MATLAB:unittest:StopOnFailuresPlugin:PausedAtFailureNoStack');
                plugin.printMessageAndPause(getString(msg));
                return;
            end
            
            % Walk the stack to find the location of the failure source
            % relative to the current location in the stack.
            failureSource = eventData.Stack(1);
            stack = dbstack('-completenames');
            for testContentFrame = 1:numel(stack)
                if isequal(stack(testContentFrame), failureSource)
                    break;
                end
            end
            
            hereHyperlinkTitle = getString(message('MATLAB:unittest:StopOnFailuresPlugin:HereHyperlinkText'));
            command = sprintf('dbup(%d)', testContentFrame);
            hyperlink = enrich(CommandHyperlinkableString(hereHyperlinkTitle, command, 'font-weight:bold'));
            hyperlinkMessage = message('MATLAB:unittest:StopOnFailuresPlugin:PausedAtFailureWithHyperlink', ...
                char(hyperlink.Text), failureSource.line, failureSource.file);
            plainMessage = message('MATLAB:unittest:StopOnFailuresPlugin:PausedAtFailure', failureSource.line, failureSource.file);
            plugin.printMessageAndPause(AlternativeRichString(getString(plainMessage), getString(hyperlinkMessage)));
        end
        
        function handleUncaughtError(plugin, eventData)
            stack = eventData.Exception.stack;
            if isempty(stack)
                msg = message('MATLAB:unittest:StopOnFailuresPlugin:PausedAtUncaughtErrorNoStack');
                plugin.printMessageAndPause(getString(msg));
                return;
            end
            
            plugin.printMessageAndPause(getString(message('MATLAB:unittest:StopOnFailuresPlugin:PausedAtUncaughtError', ...
                stack(1).file)));
        end
        
        function printMessageAndPause(plugin, msg)
            plugin.LinePrinter.printLine(msg);
            keyboard;
        end
    end
    
    methods (Hidden)
        function plugin = disableDebug(~)
            import matlab.unittest.internal.plugins.StopOnFailuresPluginEnabler
            plugin = StopOnFailuresPluginEnabler;
        end
    end
end

% LocalWords:  mypackage completenames evd Hyperlinkable unittest plugins
