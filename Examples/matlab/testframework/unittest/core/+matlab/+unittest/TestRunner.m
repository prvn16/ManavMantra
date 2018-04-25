classdef(Sealed) TestRunner < ...
        matlab.unittest.internal.TestContentOperator & ...
        matlab.unittest.internal.TestRunnerExtension & ...
        matlab.unittest.internal.ObsoletePluginListHolder
    % TestRunner - Class used to run tests in matlab.unittest
    %
    %   The matlab.unittest.TestRunner class is the fundamental API used to run
    %   a suite of tests in matlab.unittest. It runs and operates on TestSuite
    %   arrays and is responsible for constructing the TestCase class instances
    %   containing test code, setting up and tearing down fixtures, and
    %   executing the test methods. It ensures that all of the test and fixture
    %   methods are run at the appropriate times and in the appropriate manner,
    %   and records information about the run into TestResults. It is the only
    %   supported class with the ability to run Test content to ensure that
    %   tests are run in the manner guaranteed by the TestCase interface.
    %
    %   To create a TestRunner for use in running tests, one can use one of the
    %   static methods provided by the TestRunner class.
    %
    %   TestRunner methods:
    %       withNoPlugins  - Create the simplest runner possible
    %       withTextOutput - Create a runner for command window output
    %
    %       run           - Run all the tests in a TestSuite array
    %       runInParallel - Run tests on a parallel pool (requires Parallel Computing Toolbox)
    %       addPlugin     - Add a TestRunnerPlugin to a TestRunner
    %
    %   TestRunner properties:
    %       ArtifactsRootFolder - Root folder where test run artifacts are stored
    %       PrebuiltFixtures    - Fixtures that are set up outside the test runner
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %
    %       % Create a "standard" TestRunner and run the suite
    %       runner = TestRunner.withTextOutput;
    %       runner.run(suite)
    %
    %   See also: TestSuite, TestResult, plugins.TestRunnerPlugin
    %
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    properties
        % ArtifactsRootFolder - Root folder where test run artifacts are stored
        %
        %   The ArtifactsRootFolder property is the root folder where artifact
        %   subfolders associated with test runs may be created. By default, the
        %   value of ArtifactsRootFolder is string(tempdir) but can be set to any
        %   writable folder, given as a string scalar or a character vector.
        %
        %   Any artifacts produced during an individual call to run or
        %   runInParallel are stored in a subfolder underneath ArtifactsRootFolder
        %   whose name is a unique identifier associated with that individual run.
        %   For example, if the ArtifactsRootFolder is set to "C:\Temp" and
        %   "1231df38-7515-4dbe-a869-c3d9f885f379" is the automatically generated
        %   run identifier, then if an artifact is produced during the run with the
        %   name "artifact.txt", it will be stored as
        %   "C:\Temp\1231df38-7515-4dbe-a869-c3d9f885f379\artifact.txt". If no
        %   artifacts are produced during a test run, then no artifact subfolder
        %   will be created.
        %
        ArtifactsRootFolder = string(matlab.unittest.internal.folderResolver(tempdir()));
        
        % PrebuiltFixtures - Fixtures that are set up outside the test runner
        %
        %   The PrebuiltFixtures property can be set to a vector of one or more
        %   matlab.unittest.fixtures.Fixture instances which are considered to have
        %   already been set up. The runner never attempts to set up or tear down
        %   any fixture instances specified via the PrebuiltFixtures property.
        %   Furthermore, when running a suite, the test runner does not perform set
        %   up or tear down actions for a shared test fixture required by the suite
        %   if that fixture is specified as a prebuilt fixture. This provides a
        %   means to specify that the environmental configuration which would
        %   otherwise be performed by a fixture has already been performed manually.
        %
        %   Example:
        %       import matlab.unittest.TestRunner;
        %       import matlab.unittest.TestSuite;
        %
        %       % Create a TestSuite array
        %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
        %
        %       % Create the test runner and add a fixture that need not be set up
        %       runner = TestRunner.withTextOutput;
        %       runner.PrebuiltFixtures = MyFixture;
        %       runner.run(suite)
        %
        %   See also: matlab.unittest.fixtures.Fixture
        %
        PrebuiltFixtures (1,:) matlab.unittest.fixtures.Fixture;
    end
    
    properties(Dependent, SetAccess=private, Hidden)
        Plugins
    end
    
    properties(Access=private)
        OperatorList;
        TestRunData;
        ActiveFixtures (1,:) matlab.unittest.internal.FixtureRole;
        SharedTestFixtureToSetup;
        
        ClassLevelStruct = struct(...
            'TestCase', [], ...
            'TestClassSetupMethods', [], ...
            'TestMethodSetupMethods', [], ...
            'TestMethods', [], ...
            'TestMethodTeardownMethods', [], ...
            'TestClassTeardownMethods', []);
        
        RepeatLoopTestCase;
        
        CurrentMethodLevelTestCase;
        
        PluginData = struct;
        
        PluginsInvokedRunnerContent = false;
        VerificationFailureRecorded = false;
        
        LastQualificationFailedExceptionMarker = matlab.unittest.internal.qualifications.QualificationFailedExceptionMarker;
        
        FinalizedResultReportedIndex; % Results have been finalized up to this index
    end
    
    properties (Dependent, Access=private)
        DiagnosticData %Depends on TestRunData (which is set during a call to run)
    end
    
    properties (Constant, Access=private)
        WithTextOutputParser = createWithTextOutputParser;
    end
    
    methods(Static)
        function runner = withNoPlugins
            % withNoPlugins  - Create the simplest runner possible
            %
            %   RUNNER = matlab.unittest.TestRunner.withNoPlugins creates a TestRunner
            %   that is guaranteed to have no plugins installed and returns it in
            %   RUNNER. It is the method one can use to create the simplest runner
            %   possible without violating the guarantees a test writer has when
            %   writing TestCase classes. This runner is a silent runner, meaning that
            %   regardless of passing or failing tests, this runner produces no output
            %   whatsoever, although the results returned after running a test suite
            %   are accurate.
            %
            %   This method can also be used when it is desirable to have complete
            %   control over which plugins are installed and in what order. It is the
            %   only method guaranteed to produce the minimal TestRunner with no
            %   plugins, so one can create it and add additional plugins as desired.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a silent TestRunner guaranteed to have no plugins
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Run the suite silently
            %       result = runner.run(suite)
            %
            %       % Control over which plugins are installed is maintained
            %       runner.addPlugin(MyCustomRunnerPlugin);
            %       runner.addPlugin(AnotherCustomPlugin);
            %
            %       % Run the suite with the custom plugins
            %       result = runner.run(suite)
            %
            %   See also: plugins.TestRunnerPlugin
            %
            import matlab.unittest.TestRunner;
            runner = TestRunner;
        end
        
        function runner = withTextOutput(varargin)
            % withTextOutput - Create a runner for command window output
            %
            %   RUNNER = matlab.unittest.TestRunner.withTextOutput creates a TestRunner
            %   that is configured for running tests from the Command Window and
            %   returns it in RUNNER. The output produced includes test progress as
            %   well as diagnostics in the event of test failures.
            %
            %   RUNNER = matlab.unittest.TestRunner.withTextOutput('Verbosity',VERBOSITY)
            %   creates a TestRunner that is configured for reporting test run progress
            %   and logged diagnostics at the specified verbosity level VERBOSITY.
            %   VERBOSITY can be specified as either a numeric value (1, 2, 3, or 4) or
            %   a value from the matlab.unittest.Verbosity enumeration.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner that produced output to the Command Window
            %       runner = TestRunner.withTextOutput;
            %
            %       % Run the suite
            %       result = runner.run(suite)
            %
            %   See also: TestSuite/run
            %
            
            import matlab.unittest.TestRunner;
            import matlab.unittest.Verbosity;
            import matlab.unittest.plugins.LoggingPlugin;
            import matlab.unittest.plugins.TestRunProgressPlugin;
            import matlab.unittest.plugins.FailureDiagnosticsPlugin;
            
            parser = TestRunner.WithTextOutputParser;
            parser.parse(varargin{:});
            
            runner = TestRunner;
            
            if any(strcmp(parser.UsingDefaults,'Verbosity'))
                runner.addPlugin(LoggingPlugin.withVerbosity(Verbosity.Terse));
                runner.addPlugin(TestRunProgressPlugin.withVerbosity(Verbosity.Concise));
            else
                runner.addPlugin(LoggingPlugin.withVerbosity(parser.Results.Verbosity));
                runner.addPlugin(TestRunProgressPlugin.withVerbosity(parser.Results.Verbosity));
            end
            
            runner.addPlugin(FailureDiagnosticsPlugin);
        end
    end
    
    methods (Hidden, Static)
        function runner = withDefaultPlugins
            % This method is undocumented and may change in a future release.
            
            import matlab.unittest.TestRunner;
            
            runner = TestRunner;
            
            s = settings;
            pluginsFunction = str2func(s.matlab.unittest.DefaultPluginsFcn.ActiveValue);
            plugins = pluginsFunction();
            
            for idx = 1:numel(plugins)
                runner.addPlugin(plugins(idx));
            end
        end
    end
    
    methods
        function result = run(runner, suite, varargin)
            % RUN - Run all the tests in a TestSuite array
            %
            %   RESULT = RUN(RUNNER, SUITE) runs the TestSuite defined by SUITE using
            %   the TestRunner provided in RUNNER, and returns the result in RESULT.
            %   RESULT is a matlab.unittest.TestResult which is the same size as SUITE,
            %   and each element is the result of the corresponding element in SUITE.
            %   This method ensures that tests written using the TestCase interface are
            %   correctly run. This includes running all of the appropriate methods of
            %   the TestCase class to set up fixtures and run test content. It ensures
            %   that errors and qualification failures are handled appropriately and
            %   their impacts are recorded into RESULTS.
            %
            %   Example:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.TestRunner;
            %
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %       runner = TestRunner.withTextOutput;
            %
            %       result = runner.run(suite)
            %
            %   See also: runInParallel, TestSuite, TestResult, TestCase, plugins.TestRunnerPlugin
            %
            
            import matlab.unittest.internal.generateParserWithNewRunIdentifier;
            import matlab.unittest.internal.WarningStackPrinter;
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            printer = WarningStackPrinter;
            printer.enable; % disabled at scope-exit
            
            parser = generateParserWithNewRunIdentifier();
            parser.parse(varargin{:});
            
            c = onCleanup(@()runner.deletePluginData);
            
            runner.TestRunData = matlab.unittest.internal.RunOnceTestRunData.fromSuite(suite, ...
                parser.Results.RunIdentifier,runner);
            runner.PluginData.runTestSuite = TestSuiteRunPluginData('', runner.TestRunData, numel(suite));
            runner.evaluateMethodOnPlugins(@runTestSuite, runner.PluginData.runTestSuite);
            result = runner.TestRunData.TestResult;
        end
        
        function addPlugin(runner, plugin)
            % addPlugin - Add a TestRunnerPlugin to a TestRunner
            %
            %   addPlugin(RUNNER, PLUGIN) adds the TestRunnerPlugin PLUGIN to the
            %   TestRunner RUNNER. Plugins are the mechanism provided to customize the
            %   manner in which a TestSuite is run.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins installed
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Add a custom plugin
            %       runner.addPlugin(MyCustomPlugin);
            %       result = runner.run(suite)
            %
            %   See also: plugins.TestRunnerPlugin
            %
            
            runner.OperatorList.addPlugin(plugin);
        end
    end
    
    methods (Hidden)
        function result = runRepeatedly(runner, suite, numRepetitions, varargin)
            % RUNREPEATEDLY - Run all the tests in a TestSuite array repeatedly
            %
            %   RESULT = RUNREPEATEDLY(RUNNER, SUITE, NUMREPETITIONS) runs
            %   the TestSuite defined by SUITE repeatedly NUMREPETITIONS times using
            %   the TestRunner provided in RUNNER, and returns the result in RESULT. RESULT is a
            %   matlab.unittest.CompositeTestResult which is the same size as SUITE,
            %   and each element is the result of the corresponding element in SUITE.
            %   Furthermore, each element in the CompositeTestResult is composed of an array of
            %   child test results, each element of which corresponds to a repetition of a suite element.
            %
            %   RESULT = RUNREPEATEDLY(...,'EarlyTerminationFcn',EARLYTERMINATEFCN)
            %   runs the TestSuite defined by SUITE repeatedly NUMREPETITIONS times or
            %   until the EARLYTERMINATEFCN returns true. EARLYTERMINATEFCN is
            %   specified as a function handle that defines the criteria to break out
            %   of the suite repetition early. When EARLYTERMINATEFCN evaluates to true
            %   the repetition stops. It is invoked once for each iteration.
            %
            %   Example:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.TestRunner;
            %
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %       runner = TestRunner.withTextOutput;
            %
            %       result = runner.runRepeatedly(suite, 3)
            %
            %   See also: runInParallel, TestSuite, TestResult, TestCase, plugins.TestRunnerPlugin
            %
            
            import matlab.unittest.internal.generateParserWithNewRunIdentifier;
            import matlab.unittest.internal.WarningStackPrinter;
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            c = onCleanup(@()runner.deletePluginData);
            
            validateattributes(numRepetitions, {'numeric'}, {'positive', 'scalar', 'integer'});
            
            printer = WarningStackPrinter;
            printer.enable; % disabled at scope-exit
            
            parser = generateParserWithNewRunIdentifier();
            parser.addParameter('EarlyTerminationFcn',@(varargin)false,...
                @(x) validateattributes(x,{'function_handle'},{},'','EarlyTerminationFcn'));
            parser.parse(varargin{:});
            
            runner.TestRunData = matlab.unittest.internal.RunRepeatedlyTestRunData.fromSuite(suite, ...
                parser.Results.RunIdentifier, numRepetitions, parser.Results.EarlyTerminationFcn,runner);
            
            runner.PluginData.runTestSuite = TestSuiteRunPluginData('', runner.TestRunData, numel(suite));
            runner.evaluateMethodOnPlugins(@runTestSuite, runner.PluginData.runTestSuite);
            result = runner.TestRunData.TestResult;
        end
    end
    
    methods %  Getters & Setters
        function diagData = get.DiagnosticData(runner)
            import matlab.unittest.diagnostics.DiagnosticData;
            diagData = DiagnosticData('ArtifactsFolder',...
                runner.ArtifactsRootFolder + filesep + runner.TestRunData.RunIdentifier); %#ok<CPROP>
        end
        
        function set.ArtifactsRootFolder(runner,folder)
            folder = matlab.unittest.internal.folderResolver(folder);
            validateArtifactsRootFolderHasWritePermissions(folder);
            runner.ArtifactsRootFolder = string(folder);
        end
        
        function plugins = get.Plugins(runner)
            plugins = runner.OperatorList.Plugins;
        end
    end
    
    methods(Access=private)
        function runner = TestRunner
            import matlab.unittest.internal.TestContentOperatorList
            runner.OperatorList = TestContentOperatorList(runner);
        end
        
        function runSharedTestCase(runner, pluginData)
            cleanup = matlab.unittest.internal.CancelableCleanup(@runner.teardownClassLevelTestCase);
            
            % Get the subsuite from plugin data
            suite = pluginData.TestSuite;
            
            % prepare test class by creating a test class instance and
            % setting it up.
            runner.prepareTestClass(suite);
            
            if runner.TestRunData.CurrentResult.Incomplete
                % If TestClassSetup is incomplete, update the current index
                % and proceed with the TestClassTeardown.
                runner.TestRunData.CurrentIndex = runner.TestRunData.CurrentIndex + numel(suite) - 1;
            else
                % If test class setup is successful, then proceed with running
                % the individual tests
                usePlugins = runner.OperatorList.hasPluginThatImplements('runTest');
                for idx = 1:numel(suite)
                    pluginData.CurrentIndex = idx;
                    runner.repeatTest(usePlugins);
                end
            end
            
            cleanup.cancelAndInvoke;
        end
        
        function repeatTest(runner, usePlugins)
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            import matlab.unittest.plugins.plugindata.ImplicitFixturePluginData;
            import matlab.unittest.plugins.plugindata.TestContentCreationPluginData;
            
            % Create repeat loop level testcase
            if runner.TestRunData.ShouldEnterRepeatLoopScope
                if runner.OperatorList.hasPluginThatImplements('createTestRepeatLoopInstance')
                    runner.PluginData.createTestRepeatLoopInstance = TestContentCreationPluginData( ...
                        runner.TestRunData.CurrentResult.Name, runner.TestRunData.CurrentIndex);
                    runner.RepeatLoopTestCase = runner.evaluateMethodOnPlugins(@createTestRepeatLoopInstance, runner.PluginData.createTestRepeatLoopInstance);
                    delete(runner.PluginData.createTestRepeatLoopInstance);
                else
                    runner.RepeatLoopTestCase = runner.createTestRepeatLoopInstance;
                end
                
                runner.PluginData.setupTestRepeatLoop = ImplicitFixturePluginData(runner.TestRunData.CurrentResult.Name, runner.RepeatLoopTestCase);
                cleanupRepeatLoopTestCase = matlab.unittest.internal.CancelableCleanup(@runner.deleteCurrentRepeatLoopTestCase);
            else
                runner.RepeatLoopTestCase = runner.ClassLevelStruct.TestCase;
            end
            
            cleanup = matlab.unittest.internal.CancelableCleanup(@runner.finalizeResultsAtMethodLevelIfNeeded);
            
            runner.TestRunData.resetRepeatLoop;
                        
            keepGoing = true;
            while keepGoing
                runner.TestRunData.beginRepeatLoopIteration;
                
                % Evaluate runTest
                if usePlugins
                    runner.PluginData.runTest = TestSuiteRunPluginData( ...
                        runner.TestRunData.CurrentResult.Name, runner.TestRunData, runner.TestRunData.CurrentIndex);
                    runner.evaluateMethodOnPlugins(@runTest, runner.PluginData.runTest);
                    delete(runner.PluginData.runTest);
                else
                    runner.runTest;
                end
                
                keepGoing = runner.TestRunData.shouldContinueRepeatLoop;
            end
            
            if runner.TestRunData.ShouldEnterRepeatLoopScope
                runner.PluginData.teardownTestRepeatLoop = runner.PluginData.setupTestRepeatLoop;
                runner.evaluateMethodOnPlugins(@teardownTestRepeatLoop, runner.PluginData.teardownTestRepeatLoop);
                delete(runner.PluginData.teardownTestRepeatLoop);
                cleanupRepeatLoopTestCase.cancelAndInvoke;
            end
            
            runner.TestRunData.endRepeatLoop;
            
            cleanup.cancelAndInvoke;
        end
        
        function prepareSharedTestFixtures(runner)
            % Create and set up fixtures that are required but are not yet set up
            
            test = runner.TestRunData.CurrentSuite;
            rolesToSetUp = runner.ActiveFixtures.determineSharedFixturesToSetUp(runner.PrebuiltFixtures, ...
                test.InternalSharedTestFixtures, test.SharedTestFixtures);
            
            for role = rolesToSetUp
                if runner.TestRunData.CurrentResult.Incomplete
                    break;
                end
                
                affectedIndices = runner.TestRunData.CurrentIndex:runner.determineFixtureEndIndex(role.Instance);
                runner.ActiveFixtures(end+1) = role.constructFixture(@runner.constructUserFixture, affectedIndices);
                runner.ActiveFixtures(end).setupFixture(@runner.setupUserFixture);
            end
        end
        
        function fixture = constructUserFixture(runner, role)
            import matlab.unittest.plugins.plugindata.TestContentCreationPluginData;
            
            runner.SharedTestFixtureToSetup = role;
            runner.PluginData.createSharedTestFixture = TestContentCreationPluginData(class(role.Instance), role.AffectedIndices);
            fixture = runner.evaluateMethodOnPlugins(@createSharedTestFixture, runner.PluginData.createSharedTestFixture);
            delete(runner.PluginData.createSharedTestFixture);
        end
        
        function endIndex = determineFixtureEndIndex(runner, fixture)
            suite = runner.TestRunData.TestSuite;
            maximumEndIndex = runner.getNextSharedFixtureTeardownIndex;
            endIndex = runner.TestRunData.CurrentIndex;
            while endIndex < maximumEndIndex
                endIndex = endIndex + 1;
                if ~containsEquivalentFixture(getAllSharedFixturesForSuite(suite(endIndex)), fixture)
                    endIndex = endIndex - 1;
                    break;
                end
            end
        end
        
        function endIndex = getNextSharedFixtureTeardownIndex(runner)
            if runner.ActiveFixtures.hasFixtureSetUpByRunner
                endIndex = runner.ActiveFixtures(end).AffectedIndices(end);
            else
                endIndex = numel(runner.TestRunData.TestSuite);
            end
        end
        
        function setupUserFixture(runner, role)
            import matlab.unittest.plugins.plugindata.SharedTestFixturePluginData;
            
            fixture = role.Instance;
            runner.PluginData.setupSharedTestFixture = ...
                SharedTestFixturePluginData(class(fixture), fixture.SetupDescription, fixture);
            c = onCleanup(@()fixture.disableQualifications_);
            runner.evaluateMethodOnPlugins(@setupSharedTestFixture, runner.PluginData.setupSharedTestFixture);
            delete(runner.PluginData.setupSharedTestFixture);
        end
        
        function endIndex = determineClassEndIndex(runner)
            suite = runner.TestRunData.TestSuite;
            
            maximumEndIndex = runner.getNextSharedFixtureTeardownIndex;
            endIndex = runner.TestRunData.CurrentIndex;
            while endIndex < maximumEndIndex
                % Break if the next suite element belongs to a different class
                if suite(endIndex).ClassBoundaryMarker ~= suite(endIndex+1).ClassBoundaryMarker
                    break;
                end
                
                % Break if there are any shared test fixtures to setup for the next suite element
                if runner.ActiveFixtures.hasFixtureToSetUp(getNextSharedFixtures(suite, endIndex))
                    break;
                end
                
                endIndex = endIndex + 1;
            end
        end
        
        function prepareTestClass(runner, suite)
            import matlab.unittest.internal.getAllTestCaseClassesInHierarchy;
            import matlab.unittest.plugins.plugindata.TestContentCreationPluginData;
            import matlab.unittest.plugins.plugindata.ImplicitFixturePluginData;
            
            if runner.OperatorList.hasPluginThatImplements('createTestClassInstance')
                % It is OK to use only the first suite element here since
                % they all belong to the same test class.
                runner.PluginData.createTestClassInstance = TestContentCreationPluginData( ...
                    suite(1).SharedTestClassName, runner.TestRunData.CurrentIndex:runner.TestRunData.CurrentIndex+numel(suite)-1);
                classLevelTestCase = runner.evaluateMethodOnPlugins(@createTestClassInstance, runner.PluginData.createTestClassInstance);
                delete(runner.PluginData.createTestClassInstance);
            else
                classLevelTestCase = runner.createTestClassInstance;
            end
            
            % Determine the TestClassSetup, TestClassTeardown, TestMethodSetup, and
            % TestMethodTeardown methods for this class. Base class methods first
            % for setup; derived class methods first for teardown.
            allTestClasses = flip(getAllTestCaseClassesInHierarchy(metaclass(classLevelTestCase)));
            testClassMethods = arrayfun(@(cls)cls.MethodList.findobj('DefiningClass', cls), ...
                allTestClasses, 'UniformOutput',false);
            testClassMethods = vertcat(testClassMethods{:});
            
            [~, idx] = unique({testClassMethods.Name}, 'stable');
            testClassMethods = testClassMethods(idx);
            
            testClassSetupMethods = findobj(testClassMethods, 'TestClassSetup', true);
            testMethodSetupMethods = findobj(testClassMethods, 'TestMethodSetup', true);
            testClassTeardownMethods = flip(findobj(testClassMethods, 'TestClassTeardown', true));
            testMethodTeardownMethods = flip(findobj(testClassMethods, 'TestMethodTeardown', true));
            
            % Create a map from test method name to test method meta.method
            % for near constant-time lookup of each test method.
            testMethods = findobj(testClassMethods, 'Test', true);
            testMethodMap = containers.Map({testMethods.Name}, num2cell(testMethods));
            
            runner.ClassLevelStruct = struct(...
                'TestCase', classLevelTestCase, ...
                'TestClassSetupMethods', testClassSetupMethods, ...
                'TestMethodSetupMethods', testMethodSetupMethods, ...
                'TestMethods', testMethodMap, ...
                'TestMethodTeardownMethods', testMethodTeardownMethods, ...
                'TestClassTeardownMethods', testClassTeardownMethods);
            
            runner.PluginData.setupTestClass = ImplicitFixturePluginData(suite(1).SharedTestClassName, classLevelTestCase);
            runner.evaluateMethodOnPlugins(@setupTestClass, runner.PluginData.setupTestClass);
        end
        
        function teardownAllSharedFixturesExcluding(runner, fixturesToKeep)
            % Tear down the fixtures that are no longer required.
            
            fixtureIndices = runner.ActiveFixtures.getIndicesOfFixturesToTearDown(fixturesToKeep);
            for idx = fixtureIndices
                role = runner.ActiveFixtures(idx);
                
                % Register teardown to remove the fixture from the active
                % fixtures in case the fixture teardown fatally asserts.
                cleanup = matlab.unittest.internal.CancelableCleanup(@()runner.removeFixture(role, idx));
                role.teardownFixture(@runner.teardownUserFixture);
                cleanup.cancelAndInvoke;
            end
            
            % Report finalized results if there are no longer any active shared test fixtures.
            if runner.OperatorList.hasPluginThatImplements('reportFinalizedResult') && ...
                    ~runner.ActiveFixtures.hasUserFixtureSetUpByRunner
                runner.reportFinalizedResultThroughCurrentIndex;
            end
        end
        
        function removeFixture(runner, role, idx)
            role.deleteFixture;
            runner.ActiveFixtures(idx) = [];
        end
        
        function teardownUserFixture(runner, role)
            import matlab.unittest.plugins.plugindata.SharedTestFixturePluginData;
            
            fixture = role.Instance;
            fixtureClass = metaclass(fixture);
            runner.PluginData.teardownSharedTestFixture = ...
                SharedTestFixturePluginData(fixtureClass.Name, fixture.TeardownDescription, fixture);
            fixture.enableQualifications_;
            runner.evaluateMethodOnPlugins(@teardownSharedTestFixture, runner.PluginData.teardownSharedTestFixture);
            delete(runner.PluginData.teardownSharedTestFixture);
        end
        
        function teardownClassLevelTestCase(runner)
            % We may have reached here due to an error while creating a
            % class level testcase instance. In that case, we don't need to
            % go through the teardown process at all.
            if ~isempty(runner.ClassLevelStruct.TestCase)
                runner.PluginData.teardownTestClass = runner.PluginData.setupTestClass;
                runner.evaluateMethodOnPlugins(@teardownTestClass, runner.PluginData.teardownTestClass);
                delete(runner.ClassLevelStruct.TestCase);
                runner.ClassLevelStruct.TestCase = [];
                delete(runner.PluginData.teardownTestClass);
            end
            
            % Results can be finalized at the class level if there are no active shared test fixtures.
            if runner.OperatorList.hasPluginThatImplements('reportFinalizedResult') && ...
                    ~runner.ActiveFixtures.hasUserFixtureSetUpByRunner
                runner.reportFinalizedResultThroughCurrentIndex;
            end
        end
        
        function deleteCurrentMethodLevelTestCase(runner)
            delete(runner.CurrentMethodLevelTestCase);
        end
        
        function deleteCurrentRepeatLoopTestCase(runner)
            delete(runner.RepeatLoopTestCase);
        end
        
        function finalizeResultsAtMethodLevelIfNeeded(runner)
            % Results can be finalized at the method level if there are no
            % TestClassSetup and TestClassTeardown methods in the TestClass, there are
            % no QualifyingPlugins, and there are no active shared test fixtures.
            if runner.OperatorList.hasPluginThatImplements('reportFinalizedResult') && ...
                    ~runner.OperatorList.HasQualifyingPlugin && ...
                    ~runner.ActiveFixtures.hasUserFixtureSetUpByRunner && ...
                    isempty(runner.ClassLevelStruct.TestClassSetupMethods) && ...
                    isempty(runner.ClassLevelStruct.TestClassTeardownMethods) && ...
                    runner.TestRunData.HasCompletedTestRepetitions
                runner.reportFinalizedResultThroughCurrentIndex;
            end
        end
        
        function reportFinalizedResultThroughCurrentIndex(runner)
            import matlab.unittest.plugins.plugindata.FinalizedResultPluginData;
            
            while runner.FinalizedResultReportedIndex < runner.TestRunData.CurrentIndex
                runner.FinalizedResultReportedIndex = runner.FinalizedResultReportedIndex + 1;
                suite = runner.TestRunData.TestSuite(runner.FinalizedResultReportedIndex);
                finalizedResult = runner.TestRunData.TestResult(runner.FinalizedResultReportedIndex);
                runner.PluginData.reportFinalizedResult = FinalizedResultPluginData( ...
                    finalizedResult.Name, runner.FinalizedResultReportedIndex, suite, finalizedResult);
                runner.evaluateMethodOnPlugins(@reportFinalizedResult, runner.PluginData.reportFinalizedResult);
                delete(runner.PluginData.reportFinalizedResult);
            end
        end
        
        function recordSharedTestFixtureFailure(runner, property, affectedIndices, marker)
            runner.LastQualificationFailedExceptionMarker = marker;
            [runner.TestRunData.TestResult(affectedIndices).(property)] = deal(true);
        end
        
        function recordVerificationFailureForPluginVerificationValidation(runner)
            runner.VerificationFailureRecorded = true;
        end
        
        function recordSharedTestCaseFailure(runner, property, marker)
            % Apply the failure results from setting up or tearing down a shared test case.
            runner.LastQualificationFailedExceptionMarker = marker;
            [runner.PluginData.runSharedTestCase.TestResult.(property)] = deal(true);
        end
        
        function recordTestRepeatLoopFailure(runner, property, marker)
            % Apply the failure results from setting up or tearing down a test repeat loop.
            runner.LastQualificationFailedExceptionMarker = marker;
            idx = runner.PluginData.runSharedTestCase.CurrentIndex;
            runner.PluginData.runSharedTestCase.TestResult(idx).(property) = true;
        end
        
        function recordTestMethodFailure(runner, property, marker)
            % Apply the failure results from a single test method (includes
            % test method setup, the test method itself, and test method teardown).
            runner.LastQualificationFailedExceptionMarker = marker;
            runner.TestRunData.CurrentResult.(property) = true;
        end
        
        function varargout = evaluateMethodOnPlugins(runner, method, pluginData)
            
            runner.PluginsInvokedRunnerContent = false;
            runner.VerificationFailureRecorded = false;
            
            iter = runner.OperatorList.getIteratorFor(func2str(method));
            [varargout{1:nargout}] = iter.CurrentOperator.invokeTestContentOperatorMethod_(method, pluginData, iter);
            
            if ~runner.PluginsInvokedRunnerContent
                error(message('MATLAB:unittest:TestRunner:MustCallSuperclassMethod'));
            end
            
            runner.validateNoVerificationsInPlugins(method);
        end
        
        function validateNoVerificationsInPlugins(runner, method)
            % Prohibit verification failures in non-QualifyingPlugins. Ideally we would
            % always prohibit such qualifications, but for simplicity and performance,
            % we only enforce this condition when no QualifyingPlugins are installed.
            if runner.VerificationFailureRecorded
                error(message('MATLAB:unittest:TestRunner:VerificationFailureInPlugin', func2str(method)));
            end
        end
        
        function evaluateMethodsOnTestContent(runner, methods, content)
            % Run methods on test content and handle any exceptions.
            
            import matlab.unittest.plugins.plugindata.MethodEvaluationPluginData;
            
            usePlugins = runner.OperatorList.hasPluginThatImplements('evaluateMethod');
            
            for idx = numel(methods):-1:1
                method = methods(idx);
                arguments = runner.TestRunData.CurrentSuite.Parameterization.getInputsFor(method);
                
                if usePlugins
                    % Determine the name for evaluateMethod
                    if isa(content, 'matlab.unittest.FunctionTestCase') && method.Test
                        name = runner.TestRunData.CurrentSuite.ProcedureName;
                    else
                        name = method.Name;
                    end
                    
                    runner.PluginData.evaluateMethod = MethodEvaluationPluginData(name, false, method, content, arguments);
                    runner.evaluateMethodOnPlugins(@evaluateMethod, runner.PluginData.evaluateMethod);
                    delete(runner.PluginData.evaluateMethod);
                else
                    runner.evaluateMethodCore(method, content, arguments);
                end
            end
        end
        
        function executeTeardownThroughPluginsFor(runner, content)
            content.runAllTeardownThroughProcedure_( ...
                @(varargin)runner.evaluateTeardownMethodOnPlugins(content, varargin{:}));
        end
        
        function evaluateTeardownMethodOnPlugins(runner, content, fcn, varargin)
            import matlab.unittest.plugins.plugindata.MethodEvaluationPluginData;
            
            method = identifyMetaMethod(metaclass(content), func2str(fcn));
            name = method.Name;
            
            if runner.OperatorList.hasPluginThatImplements('evaluateMethod')
                % Determine the name for evaluateMethod plugin data
                addedTeardown = strcmp(name, 'runTeardown');
                if addedTeardown
                    name = func2str(varargin{1});
                end
                
                runner.PluginData.evaluateMethod = MethodEvaluationPluginData(name, addedTeardown, method, content, varargin);
                runner.evaluateMethodOnPlugins(@evaluateMethod, runner.PluginData.evaluateMethod);
                delete(runner.PluginData.evaluateMethod);
            else
                runner.evaluateMethodCore(method, content, varargin);
            end
        end
        
        function deletePluginData(runner)
            structfun(@delete, runner.PluginData)
        end
        
        function evaluateMethodCore(runner, method, content, arguments)
            % Run a method and record its duration.
            
            import matlab.unittest.internal.LabelEventData;
            
            % fire start/stop events if this is a test method
            if isa(method,'matlab.unittest.meta.method') && method.Test
                notifyStart = @()content.notify('MeasurementStarted',LabelEventData('_implicit'));
                notifyStop = @()content.notify('MeasurementStopped',LabelEventData('_implicit'));
            else
                notifyStart = @()[];
                notifyStop = @()[];
            end
            
            func = str2func(method.Name);
            try
                % get the tic/toc as close as possible to the content
                if isempty(arguments)
                    notifyStart();
                    t0 = tic;
                    func(content);
                    duration = toc(t0);
                    notifyStop();
                else
                    notifyStart();
                    t0 = tic;
                    func(content, arguments{:});
                    duration = toc(t0);
                    notifyStop();
                end
                runner.TestRunData.addDurationToCurrentResult(duration);
            catch exception
                duration = toc(t0);
                notifyStop();
                runner.TestRunData.addDurationToCurrentResult(duration);
                
                if metaclass(exception) <= ?matlab.unittest.qualifications.FatalAssertionFailedException
                    rethrow(exception);
                elseif ~runner.isQualificationFailedExceptionFromCorrectQualifiable(exception)
                    content.notifyExceptionThrownEvent_(exception,runner.DiagnosticData);
                end
            end
            
        end
        
        function bool = isQualificationFailedExceptionFromCorrectQualifiable(runner, exception)
            bool = (metaclass(exception) <= ?matlab.unittest.internal.qualifications.QualificationFailedException) && ...
                runner.wasQualificationFailedExceptionThrownByCorrectQualifiable_(exception);
        end
    end
    
    methods (Hidden, Access=?matlab.unittest.plugins.TestRunnerPlugin)
        function bool = wasQualificationFailedExceptionThrownByCorrectQualifiable_(runner, exception)
            bool = exception.QualificationFailedExceptionMarker == runner.LastQualificationFailedExceptionMarker;
        end
    end
    
    methods(Hidden, Access=protected) % conform to TestContentOperator API
        function varargout = invokeTestContentOperatorMethod_(runner, method, pluginData, ~)
            
            % Validate that the plugin data made its way back to TestRunner
            % after going through all the plugins.
            if runner.PluginData.(func2str(method)) ~= pluginData
                error(message('MATLAB:unittest:TestRunner:PluginDataMismatch', func2str(method)));
            end
            
            runner.validateNoVerificationsInPlugins(method);
            
            [varargout{1:nargout}] = method(runner, pluginData);
            
            runner.PluginsInvokedRunnerContent = true;
            runner.VerificationFailureRecorded = false;
        end
        
        function runTestSuite(runner, pluginData)
            import matlab.unittest.internal.createConditionallyKeptFolderEnvironment;
            import matlab.unittest.fixtures.EmptyFixture;
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            env = createConditionallyKeptFolderEnvironment(runner.DiagnosticData.ArtifactsFolder); %#ok<NASGU>
            
            % No results have been reported yet.
            runner.FinalizedResultReportedIndex = 0;
            
            % For exception safety, tear down any fixtures active at the
            % time of a fatal assertion failure.
            teardownFixtures = matlab.unittest.internal.Teardownable;
            teardownFixtures.addTeardown(@teardownAllSharedFixturesExcluding, ...
                runner, matlab.unittest.fixtures.Fixture.empty);
            
            % Get the initial test suite from plugin data
            suite = pluginData.TestSuite;
            
            runner.TestRunData.CurrentIndex = 0;
            while runner.TestRunData.CurrentIndex < numel(suite)
                runner.TestRunData.CurrentIndex = runner.TestRunData.CurrentIndex + 1;
                
                % Set up any required fixtures that aren't already set up.
                runner.prepareSharedTestFixtures();
                
                % If shared test fixture is incomplete, we don't run the tests
                % that are under that shared test fixture umbrella. We do,
                % however, tear down any unneeded shared test fixtures.
                if runner.TestRunData.CurrentResult.Incomplete
                    fixtureFailureRange = find([runner.TestRunData.TestResult(runner.TestRunData.CurrentIndex:end).Incomplete], 1, 'last');
                    runner.TestRunData.CurrentIndex = runner.TestRunData.CurrentIndex + fixtureFailureRange - 1;
                else
                    suiteEndIdx = runner.determineClassEndIndex;
                    runner.PluginData.runTestClass = TestSuiteRunPluginData( ...
                        runner.TestRunData.CurrentSuite.TestParentName, runner.TestRunData, suiteEndIdx);
                    runner.evaluateMethodOnPlugins(@runTestClass, runner.PluginData.runTestClass);
                    delete(runner.PluginData.runTestClass);
                end
                
                % Tear down fixture no longer needed.
                runner.teardownAllSharedFixturesExcluding(getNextSharedFixtures(suite, runner.TestRunData.CurrentIndex));
            end
        end
        
        function fixture = createSharedTestFixture(runner, pluginData)
            import matlab.unittest.internal.qualifications.QualificationFailedExceptionMarker;
            import matlab.unittest.internal.DeferredTask;
            
            fixture = copy(runner.SharedTestFixtureToSetup.Instance);
            fixture.Qualifiable.DiagnosticData = runner.DiagnosticData;
            
            affectedIndices = pluginData.AffectedIndices;
            fixture.addlistener('AssumptionFailed', @(~,evd) ...
                runner.recordSharedTestFixtureFailure('AssumptionFailed', affectedIndices, evd.QualificationFailedExceptionMarker));
            fixture.addlistener('AssertionFailed', @(~,evd) ...
                runner.recordSharedTestFixtureFailure('AssertionFailed', affectedIndices, evd.QualificationFailedExceptionMarker));
            fixture.addlistener('ExceptionThrown', @(~,~) ...
                runner.recordSharedTestFixtureFailure('Errored', affectedIndices, QualificationFailedExceptionMarker));
            fixture.addlistener('FatalAssertionFailed', @(~,evd) ...
                runner.recordSharedTestFixtureFailure('FatalAssertionFailed', affectedIndices, evd.QualificationFailedExceptionMarker));
            
            fixture.onFailure(DeferredTask(@()runner.ActiveFixtures.getAdditionalFixtureOnFailureTasks(fixture)));
        end
        
        function setupSharedTestFixture(runner, pluginData)
            if ~runner.TestRunData.CurrentResult.Incomplete
                fixture = pluginData.Fixture;
                fixtureClass = metaclass(fixture);
                
                setupMethod = identifyMetaMethod(fixtureClass, 'setup');
                runner.evaluateMethodsOnTestContent(setupMethod, fixture);
                
                % Update the description which the fixture may have set during setup
                runner.PluginData.setupSharedTestFixture.Description = fixture.SetupDescription;
                
                teardownMethod = identifyMetaMethod(fixtureClass, 'teardown');
                registerTeardownMethods(fixture, teardownMethod);
            end
        end
        
        function runTestClass(runner, pluginData)
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            % Get the subsuite from plugin data
            suite = pluginData.TestSuite;
            
            startIdx = runner.TestRunData.CurrentIndex;
            pluginData.CurrentIndex = 0;
            while pluginData.CurrentIndex < numel(suite)
                pluginData.CurrentIndex = pluginData.CurrentIndex + 1;
                
                % Calculate the subsuite within the shared test case boundary -
                % this includes all tests that belong to the same test class
                % and have same class setup parameterization.
                suiteEndIdx = calculateSubsuiteWithinSharedTestCaseBoundary(suite, pluginData.CurrentIndex);
                
                runner.PluginData.runSharedTestCase = TestSuiteRunPluginData( ...
                    '', runner.TestRunData, startIdx+suiteEndIdx-1);
                runner.runSharedTestCase(runner.PluginData.runSharedTestCase);
                delete(runner.PluginData.runSharedTestCase);
            end
        end
        
        function testCase = createTestClassInstance(runner, ~)
            import matlab.unittest.internal.qualifications.QualificationFailedExceptionMarker;
            import matlab.unittest.internal.AddVerificationEventDecorator;
            import matlab.unittest.internal.DeferredTask;
            
            % Create a class-level TestCase instance
            testCase = runner.TestRunData.CurrentSuite.provideClassTestCase;
            testCase.DiagnosticData = runner.DiagnosticData;
            
            if ~runner.OperatorList.HasQualifyingPlugin
                testCase.addlistener('VerificationFailed', @(~,~)runner.recordVerificationFailureForPluginVerificationValidation);
            end
            
            testCase.addlistener('VerificationFailed', @(~,evd) ...
                runner.recordSharedTestCaseFailure('VerificationFailed',evd.QualificationFailedExceptionMarker));
            testCase.addlistener('AssumptionFailed', @(~,evd) ...
                runner.recordSharedTestCaseFailure('AssumptionFailed',evd.QualificationFailedExceptionMarker));
            testCase.addlistener('AssertionFailed', @(~,evd) ...
                runner.recordSharedTestCaseFailure('AssertionFailed',evd.QualificationFailedExceptionMarker));
            testCase.addlistener('ExceptionThrown', @(~,~) ...
                runner.recordSharedTestCaseFailure('Errored',QualificationFailedExceptionMarker));
            testCase.addlistener('FatalAssertionFailed', @(~,evd) ...
                runner.recordSharedTestCaseFailure('FatalAssertionFailed',evd.QualificationFailedExceptionMarker));
            
            testCase.onFailure(AddVerificationEventDecorator(DeferredTask(@()runner.ActiveFixtures.getAdditionalOnFailureTasks)));
            testCase.SharedTestFixtures_ = runner.ActiveFixtures.getUserVisibleFixtures;
        end
        
        function setupTestClass(runner, ~)
            if ~runner.TestRunData.CurrentResult.Incomplete
                testCase = runner.ClassLevelStruct.TestCase;
                runner.evaluateMethodsOnTestContent(runner.ClassLevelStruct.TestClassSetupMethods, testCase);
                registerTeardownMethods(testCase, runner.ClassLevelStruct.TestClassTeardownMethods);
            end
        end
        
        function testCase = createTestRepeatLoopInstance(runner, ~)
            import matlab.unittest.internal.qualifications.QualificationFailedExceptionMarker;
            
            testCase = runner.TestRunData.CurrentSuite.createTestCaseFromClassPrototype(runner.ClassLevelStruct.TestCase);
            
            if ~runner.OperatorList.HasQualifyingPlugin
                testCase.addlistener('VerificationFailed', @(~,~)runner.recordVerificationFailureForPluginVerificationValidation);
            end
            
            testCase.addlistener('VerificationFailed', @(~,evd) ...
                runner.recordTestRepeatLoopFailure('VerificationFailed',evd.QualificationFailedExceptionMarker));
            testCase.addlistener('AssumptionFailed', @(~,evd) ...
                runner.recordTestRepeatLoopFailure('AssumptionFailed',evd.QualificationFailedExceptionMarker));
            testCase.addlistener('AssertionFailed', @(~,evd) ...
                runner.recordTestRepeatLoopFailure('AssertionFailed', evd.QualificationFailedExceptionMarker));
            testCase.addlistener('ExceptionThrown', @(~,~) ...
                runner.recordTestRepeatLoopFailure('Errored', QualificationFailedExceptionMarker));
            testCase.addlistener('FatalAssertionFailed', @(~,evd) ...
                runner.recordTestRepeatLoopFailure('FatalAssertionFailed',evd.QualificationFailedExceptionMarker));
        end
        
        function runTest(runner, ~)
            import matlab.unittest.plugins.plugindata.TestContentCreationPluginData;
            import matlab.unittest.plugins.plugindata.ImplicitFixturePluginData;
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            % Create method level testcase
            if runner.OperatorList.hasPluginThatImplements('createTestMethodInstance')
                runner.PluginData.createTestMethodInstance = TestContentCreationPluginData( ...
                    runner.TestRunData.CurrentResult.Name, runner.TestRunData.CurrentIndex);
                runner.CurrentMethodLevelTestCase = runner.evaluateMethodOnPlugins(@createTestMethodInstance, runner.PluginData.createTestMethodInstance);
                delete(runner.PluginData.createTestMethodInstance);
            else
                runner.CurrentMethodLevelTestCase = runner.createTestMethodInstance;
            end
            
            % Teardown current method level testcase
            cleanup = matlab.unittest.internal.CancelableCleanup(@runner.deleteCurrentMethodLevelTestCase);
            
            % Evaluate setup test method
            runner.PluginData.setupTestMethod = ImplicitFixturePluginData(runner.TestRunData.CurrentResult.Name, runner.CurrentMethodLevelTestCase);
            runner.evaluateMethodOnPlugins(@setupTestMethod, runner.PluginData.setupTestMethod);
            
            % Only run if we have completed our fixture setup
            if ~runner.TestRunData.CurrentResult.Incomplete
                if runner.OperatorList.hasPluginThatImplements('runTestMethod')
                    % Run the Test method.
                    runner.PluginData.runTestMethod = TestSuiteRunPluginData( ...
                        runner.TestRunData.CurrentResult.Name, runner.TestRunData, runner.TestRunData.CurrentIndex);
                    runner.evaluateMethodOnPlugins(@runTestMethod, runner.PluginData.runTestMethod);
                    delete(runner.PluginData.runTestMethod);
                else
                    runner.runTestMethod;
                end
            end
            
            % Tear down the fresh fixture.
            runner.PluginData.teardownTestMethod = runner.PluginData.setupTestMethod;
            runner.evaluateMethodOnPlugins(@teardownTestMethod, runner.PluginData.teardownTestMethod);
            delete(runner.PluginData.teardownTestMethod);
            
            cleanup.cancelAndInvoke;
        end
        
        function testCase = createTestMethodInstance(runner, ~)
            import matlab.unittest.internal.qualifications.QualificationFailedExceptionMarker;
            
            % Create the testCase instance from the class level prototype
            testCase = runner.TestRunData.CurrentSuite.createTestCaseFromClassPrototype(runner.RepeatLoopTestCase);
            
            if ~runner.OperatorList.HasQualifyingPlugin
                testCase.addlistener('VerificationFailed', @(~,~)runner.recordVerificationFailureForPluginVerificationValidation);
            end
            
            testCase.addlistener('VerificationFailed', @(~,evd) ...
                runner.recordTestMethodFailure('VerificationFailed',evd.QualificationFailedExceptionMarker));
            testCase.addlistener('AssumptionFailed', @(~,evd) ...
                runner.recordTestMethodFailure('AssumptionFailed',evd.QualificationFailedExceptionMarker));
            testCase.addlistener('AssertionFailed', @(~,evd) ...
                runner.recordTestMethodFailure('AssertionFailed', evd.QualificationFailedExceptionMarker));
            testCase.addlistener('ExceptionThrown', @(~,~) ...
                runner.recordTestMethodFailure('Errored', QualificationFailedExceptionMarker));
            testCase.addlistener('FatalAssertionFailed', @(~,evd) ...
                runner.recordTestMethodFailure('FatalAssertionFailed',evd.QualificationFailedExceptionMarker));
        end
        
        function setupTestMethod(runner, ~)
            if ~runner.TestRunData.CurrentResult.Incomplete
                testCase = runner.CurrentMethodLevelTestCase;
                runner.evaluateMethodsOnTestContent(runner.ClassLevelStruct.TestMethodSetupMethods, testCase);
                registerTeardownMethods(testCase, runner.ClassLevelStruct.TestMethodTeardownMethods);
            end
        end
        
        function runTestMethod(runner, ~)
            runner.TestRunData.CurrentResult.Started  = true;
            testCase = runner.CurrentMethodLevelTestCase;
            testMethodName = runner.TestRunData.CurrentSuite.TestMethodName;
            if ~isKey(runner.ClassLevelStruct.TestMethods,testMethodName)
                error(message('MATLAB:unittest:TestRunner:UnableToFindTestMethod', testMethodName, class(testCase)));
            end
            method = runner.ClassLevelStruct.TestMethods(testMethodName);
            runner.evaluateMethodsOnTestContent(method, testCase);
        end
        
        function evaluateMethod(runner, pluginData)
            runner.evaluateMethodCore(pluginData.Method, pluginData.Content, pluginData.Arguments);
        end
        
        function teardownTestMethod(runner, ~)
            runner.executeTeardownThroughPluginsFor(runner.CurrentMethodLevelTestCase);
        end
                
        function teardownTestRepeatLoop(runner, ~)
            runner.executeTeardownThroughPluginsFor(runner.RepeatLoopTestCase);
        end
        
        function teardownTestClass(runner, ~)
            runner.executeTeardownThroughPluginsFor(runner.ClassLevelStruct.TestCase);
        end
        
        function teardownSharedTestFixture(runner, pluginData)
            fixture = pluginData.Fixture;
            runner.executeTeardownThroughPluginsFor(fixture);
            
            % Update the description which the fixture may have set during teardown
            runner.PluginData.teardownSharedTestFixture.Description = fixture.TeardownDescription;
        end
        
        function reportFinalizedResult(~, ~)
            % Runner does nothing
        end
    end
    
    methods (Hidden)
        function serialized = saveobj(runner)
            serialized.PrebuiltFixtures = runner.PrebuiltFixtures;
            serialized.ArtifactsRootFolder = runner.ArtifactsRootFolder;
            serialized.Plugins = runner.Plugins;
            serialized.Version = 'R2017b';
        end
    end
    
    methods (Hidden, Static)
        function runner = loadobj(savedRunner)
            import matlab.unittest.TestRunner;
            
            % Create a new runner and copy over the necessary state.
            runner = TestRunner.withNoPlugins;
            
            runner.PrebuiltFixtures = savedRunner.PrebuiltFixtures;
            
            % Only TestRunners saved in R2017a and later have ArtifactsRootFolder
            if any(strcmp(fieldnames(savedRunner),'ArtifactsRootFolder'))
                runner.ArtifactsRootFolder = savedRunner.ArtifactsRootFolder;
            end
            
            % R2017a an earlier had a PluginList property
            % R2017b and later have Plugins
            if any(strcmp(fieldnames(savedRunner),'PluginList'))
                plugins = flip(savedRunner.PluginList(2:end));
            else
                plugins = savedRunner.Plugins;
            end
            
            for idx = 1:numel(plugins)
                runner.addPlugin(plugins(idx));
            end
        end
    end
end

function fixtures = getAllSharedFixturesForSuite(suite)
fixtures = [suite.SharedTestFixtures, suite.InternalSharedTestFixtures];
end

function fixtures = getNextSharedFixtures(suite, index)
% Return the shared fixtures needed for suite(index+1)

import matlab.unittest.fixtures.EmptyFixture;

if index < numel(suite)
    fixtures = getAllSharedFixturesForSuite(suite(index+1));
else
    % No fixtures required beyond last suite element
    fixtures = EmptyFixture.empty;
end
end

function endIndex = calculateSubsuiteWithinSharedTestCaseBoundary(suite, startIdx)
% Calculate the subsuite of tests have the same class setup parameterization.

endIndex = startIdx;
while endIndex < numel(suite) && hasSameClassSetupParameters(suite, endIndex, endIndex+1)
    endIndex = endIndex + 1;
end
end

function bool = hasSameClassSetupParameters(suite, idx1, idx2)
bool = isequal(classSetupParameterNames(suite(idx1)), classSetupParameterNames(suite(idx2)));
end

function names = classSetupParameterNames(test)
params = test.Parameterization.filterByClass('matlab.unittest.parameters.ClassSetupParameter');
names = {params.Name};
end


function metaMethod = identifyMetaMethod(metaClass, name)
metaMethod = findobj(metaClass.MethodList, 'Name', name);
end


function registerTeardownMethods(content, methods)
import matlab.unittest.internal.TeardownElement;

for idx = 1:numel(methods)
    content.addTeardown(TeardownElement(str2func(methods(idx).Name), {}));
end
end

function parser = createWithTextOutputParser()
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('Verbosity', []);
end


function validateArtifactsRootFolderHasWritePermissions(folder)
import matlab.unittest.internal.generateUUID;
tmpFolder = fullfile(folder,char(generateUUID()));
try
    mkdir(tmpFolder);
    rmdir(tmpFolder);
catch cause
    exception = MException(message('MATLAB:unittest:TestRunner:MustBeAWritableFolder','ArtifactsRootFolder'));
    throwAsCaller(exception.addCause(cause));
end
end

% LocalWords:  mypackage func Teardownable tmp Prebuilt prebuilt cls evd CPROP
% LocalWords:  mypackage func Teardownable plugindata subsuite teardownable
% LocalWords:  teardownable's RUNREPEATEDLY NUMREPETITIONS EARLYTERMINATEFCN
% LocalWords:  ADifferent subfolders subfolder df dbe env AWritable Cancelable
