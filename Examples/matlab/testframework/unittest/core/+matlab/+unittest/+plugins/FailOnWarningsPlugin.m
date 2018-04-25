classdef FailOnWarningsPlugin < matlab.unittest.plugins.QualifyingPlugin & ...
                                matlab.unittest.internal.mixin.IgnoringMixin
    % FailOnWarningsPlugin - Plugin to report warnings issued by tests.
    %
    %   The FailOnWarningsPlugin can be added to the TestRunner to fail any
    %   test that issues warnings. The plugin produces a qualification failure
    %   in the test scope that issued the warning. For example, a warning
    %   issued by a shared test fixture produces a qualification failure on the
    %   fixture, failing all tests that use it.
    %
    %   FailOnWarningsPlugin does not produce failures for warnings that are
    %   accounted for by passing or failing qualification calls performed using
    %   constraints such as IssuesWarnings or IssuesNoWarnings. The plugin also
    %   does not produce failures for warnings that are disabled, for example,
    %   using SuppressedWarningsFixture.
    %
    %   By default, FailOnWarningsPlugin produces failures for all unexpected
    %   warnings issued while running a test. However, one or more warning
    %   identifiers can be specified using the 'Ignoring' name/value pair in
    %   which case the plugin does not produce failures when warnings with
    %   those identifiers are issued.
    %
    %   FailOnWarningsPlugin methods:
    %       FailOnWarningsPlugin - Class constructor
    %
    %   FailOnWarningsPlugin properties:
    %       Ignore - Cell array of warning identifiers to ignore
    %
    %   Example:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.FailOnWarningsPlugin;
    %
    %       % Create a TestSuite array
    %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a TestRunner producing text output
    %       runner = TestRunner.withTextOutput;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(FailOnWarningsPlugin('Ignoring',{'MATLAB:singularMatrix'}));
    %
    %       % Run the suite
    %       result = runner.run(suite)
    %
    %   See also:
    %       matlab.unittest.TestRunner
    %       matlab.unittest.plugins.TestRunnerPlugin
    %       matlab.unittest.constraints.IssuesWarnings
    %       matlab.unittest.constraints.IssuesNoWarnings
    %       matlab.unittest.fixtures.SuppressedWarningsFixture
    %
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access=private)
        Logger;
        LocalWarnings;
        
        % TestClassSetupWarnings - array of warnings issued in TestClassSetup
        TestClassSetupWarnings;
        
        % SharedTestFixtureWarningsStack - Stack containing the array of warnings
        %   issued by the setup method of each active shared test fixture.
        SharedTestFixtureWarningsStack;
    end
    
    methods
        function plugin = FailOnWarningsPlugin(varargin)
            % FailOnWarningsPlugin - Class constructor
            %
            %   PLUGIN = FailOnWarningsPlugin creates a FailOnWarningsPlugin
            %   instance and returns it in PLUGIN. This plugin can then be added to
            %   a TestRunner instance to fail any test that issues warnings.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.plugins.FailOnWarningsPlugin;
            %
            %       % Create a TestSuite array
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner producing text output
            %       runner = TestRunner.withTextOutput;
            %
            %       % Add a new plugin to the TestRunner
            %       runner.addPlugin(FailOnWarningsPlugin);
            %
            %       % Run the suite
            %       result = runner.run(suite)
            %
            
            plugin.parse(varargin{:});
        end
    end
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.internal.constraints.WarningLogger;
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            
            plugin.Logger = WarningLogger;
            plugin.resetSharedTestFixtureWarningsStack;
            
            expectedWarningsListener = ExpectedWarningsNotifier.createExpectedWarningsListener( ...
                @plugin.recordExpectedWarning); %#ok<NASGU>
            
            runTestSuite@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
        end
        
        function setupSharedTestFixture(plugin, pluginData)
            plugin.startLoggingWarnings;
            c = onCleanup(@()plugin.stopLoggingWarningsInSharedTestFixtureSetup);
            setupSharedTestFixture@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
        end
        
        function teardownSharedTestFixture(plugin, pluginData)
            import matlab.unittest.internal.plugins.WarningHistory;
            import matlab.unittest.internal.plugins.IsWarningFree;
            
            % Pop the setup warnings off the stack before tearing down the
            % fixture to ensure the stack is in the correct state should the
            % fixture fatally assert in teardown.
            setupWarnings = plugin.peekSharedTestFixtureWarningsStack;
            plugin.popSharedTestFixtureWarningsStack;
            
            plugin.startLoggingWarnings;
            teardownSharedTestFixture@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
            teardownWarnings = plugin.stopLoggingWarnings;
            
            history = WarningHistory(pluginData.Name, [setupWarnings, teardownWarnings]);
            plugin.assertUsing(pluginData.QualificationContext, history, IsWarningFree);
        end
        
        function setupTestClass(plugin, pluginData)
            plugin.startLoggingWarnings;
            c = onCleanup(@()plugin.stopLoggingWarningsInTestClassSetup);
            setupTestClass@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
        end
        
        function teardownTestClass(plugin, pluginData)
            import matlab.unittest.internal.plugins.WarningHistory;
            import matlab.unittest.internal.plugins.IsWarningFree;
            
            plugin.startLoggingWarnings;
            teardownTestClass@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
            teardownWarnings = plugin.stopLoggingWarnings;
            
            history = WarningHistory(pluginData.Name, [plugin.TestClassSetupWarnings, teardownWarnings]);
            plugin.verifyUsing(pluginData.QualificationContext, history, IsWarningFree);
        end
        
        function setupTestMethod(plugin, pluginData)
            plugin.startLoggingWarnings;
            setupTestMethod@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
        end
        
        function teardownTestMethod(plugin, pluginData)
            import matlab.unittest.internal.plugins.WarningHistory;
            import matlab.unittest.internal.plugins.IsWarningFree;
            
            teardownTestMethod@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
            history = WarningHistory(pluginData.Name, plugin.stopLoggingWarnings);
            plugin.verifyUsing(pluginData.QualificationContext, history, IsWarningFree);
        end
    end
    
    methods (Hidden, Access=protected)
        function plugin = ignoringPostSet(plugin)
            cellfun(@validateWarningID, plugin.Ignore);
        end
    end
    
    methods (Access=private)
        function startLoggingWarnings(plugin)
            import matlab.internal.diagnostic.Warning;
            
            plugin.LocalWarnings = Warning.empty;
            plugin.Logger.clear;
            plugin.Logger.start;
        end
        
        function warnings = stopLoggingWarnings(plugin)
            plugin.Logger.stop;
            plugin.makeWarningsLocal;
            plugin.removeIgnoredWarningsFromLocalWarnings;
            warnings = plugin.LocalWarnings;
        end
        
        function stopLoggingWarningsInSharedTestFixtureSetup(plugin)
            warnings = plugin.stopLoggingWarnings;
            plugin.pushOnSharedTestFixtureWarningsStack(warnings);
        end
        
        function stopLoggingWarningsInTestClassSetup(plugin)
            plugin.TestClassSetupWarnings = plugin.stopLoggingWarnings;
        end
        
        function recordExpectedWarning(plugin, expectedWarnings)
            plugin.makeWarningsLocal;
            plugin.removeExpectedWarningsFromLocalWarnings(expectedWarnings);
        end
        
        function makeWarningsLocal(plugin)
            % makeWarningsLocal - Transfer warnings from the logger to the plugin.
            plugin.LocalWarnings = [plugin.LocalWarnings, plugin.Logger.Warnings];
            plugin.Logger.clear;
        end
        
        function removeExpectedWarningsFromLocalWarnings(plugin, expectedWarnings)
            plugin.LocalWarnings(ismember(plugin.LocalWarnings, expectedWarnings)) = [];
        end
        
        function removeIgnoredWarningsFromLocalWarnings(plugin)
            plugin.LocalWarnings(ismember({plugin.LocalWarnings.identifier}, plugin.Ignore)) = [];
        end
        
        % Shared test fixture warnings stack manipulation methods
        function resetSharedTestFixtureWarningsStack(plugin)
            plugin.SharedTestFixtureWarningsStack = {};
        end
        function pushOnSharedTestFixtureWarningsStack(plugin, warnings)
            plugin.SharedTestFixtureWarningsStack = [{warnings}, plugin.SharedTestFixtureWarningsStack];
        end
        function warnings = peekSharedTestFixtureWarningsStack(plugin)
            warnings = plugin.SharedTestFixtureWarningsStack{1};
        end
        function popSharedTestFixtureWarningsStack(plugin)
            plugin.SharedTestFixtureWarningsStack(1) = [];
        end
    end
    
    methods (Hidden)
        function tf = supportsParallel(~)
            tf = true;
        end
        
        function plugin = disableStrict(~)
            import matlab.unittest.internal.plugins.FailOnWarningsPluginEnabler
            plugin = FailOnWarningsPluginEnabler;
        end
    end
end


function validateWarningID(id)
import matlab.unittest.internal.MessageIdentifierValidator;

if ~MessageIdentifierValidator.isValid(id)
    error(message('MATLAB:unittest:FailOnWarningsPlugin:InvalidIdentifier', id));
end
end

% LocalWords:  mypackage
