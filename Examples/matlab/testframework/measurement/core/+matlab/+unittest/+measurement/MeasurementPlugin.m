classdef (Hidden) MeasurementPlugin < matlab.unittest.plugins.QualifyingPlugin
    % This class is undocumented and subject to change in a future release
    
    % MeasurementPlugin - A plugin for recording measurements.
    
    % Copyright 2015-2017 The MathWorks, Inc.

    properties (Hidden, Access = protected)
        RunTestSuitePluginData;
    end
    
    properties(SetAccess=?matlab.perftest.TimeExperiment, GetAccess=private)
        Operator;
    end
    
    properties(SetAccess=private, Hidden)
        MeasuresAtClassBoundary        
        MeasuresInFreshFixture
    end
    
    properties(Access=private)
        TestCaseInstance
        FreshFixtureListeners = event.listener.empty;
    end
    
    properties(Dependent)
        Result
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        CurrentIndex
        RepeatIndex
    end
    
    methods (Hidden)
        function plugin = MeasurementPlugin(operator)
            if nargin > 0
                plugin.Operator = operator;
            end
        end
    end
    
    methods
        
        function val = get.Result(plugin)
            val = plugin.Operator.Result;
        end
        
        function val = get.CurrentIndex(plugin)
            val = plugin.RunTestSuitePluginData.CurrentIndex;
        end
        
        function val = get.RepeatIndex(plugin)
            val = plugin.RunTestSuitePluginData.RepeatIndex;
        end
        
    end
    
    methods (Access = protected)
        
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.measurement.MeasurementResult;
            
            % Store the plugin data
            plugin.RunTestSuitePluginData = pluginData;
            
            resultNames = {plugin.Operator.Result.Name};
            suiteNames = {pluginData.TestSuite.Name};
            if ~isequal(resultNames, suiteNames)
                plugin.Operator.Result = MeasurementResult(suiteNames);                
            end
            
            plugin.Operator.calibrate(pluginData.TestSuite);
            
            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            
            plugin.MeasuresAtClassBoundary = false;
            
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(...
                plugin, pluginData);
            
            testCase.addlistener('MeasurementStarted', @plugin.usesClassMeasurement);
            testCase.addlistener('MeasurementStopped', @plugin.usesClassMeasurement);
            testCase.addlistener('MeasurementLogged',  @plugin.usesClassMeasurement);
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            
            plugin.MeasuresInFreshFixture = false;
            
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(...
                plugin, pluginData);
            plugin.TestCaseInstance = testCase;
            
            plugin.FreshFixtureListeners(1) = ...
                testCase.addlistener('MeasurementStarted', @plugin.usesFreshFixtureMeasurement);
            plugin.FreshFixtureListeners(2) = ...
                testCase.addlistener('MeasurementStopped', @plugin.usesFreshFixtureMeasurement);
            plugin.FreshFixtureListeners(3) = ...
                testCase.addlistener('MeasurementLogged',  @plugin.usesFreshFixtureMeasurement);
            
            idx = plugin.CurrentIndex;
            iter = plugin.RepeatIndex;
            plugin.Operator.Result(idx) = plugin.Operator.Result(idx).newTestRun(iter);

        end
        
        function runTestMethod(plugin, pluginData)
            
            cl = plugin.disableFreshFixtureListeners;  %#ok<NASGU> onCleanup usage
            
            meter = plugin.Operator.Meter;
            
            meter.connect(plugin.TestCaseInstance);
            runTestMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            meter.disconnect();
        end
        
        function teardownTestMethod(plugin, pluginData)
            import matlab.unittest.measurement.internal.DidNotDetectFreshFixtureMeasurement;
            import matlab.unittest.measurement.internal.HasValidInteractions;
            
            teardownTestMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            context = pluginData.QualificationContext;
            
            plugin.verifyUsing(context, plugin, DidNotDetectFreshFixtureMeasurement(pluginData.Name));
            
            idx = plugin.CurrentIndex;
            testResult = plugin.RunTestSuitePluginData.TestResult(idx);
            flattened = testResult.flatten;
            if flattened(end).Incomplete
                % If the result is already incomplete, subsequent
                % verifications of the measurement are unnecessary
                return;
            end
            
            plugin.assertUsing(context, plugin.Operator.Meter, HasValidInteractions(pluginData.Name));
            
            % record measurement
            plugin.Operator.completeTestRun(plugin.CurrentIndex);
        end
        
        function teardownTestRepeatLoop(plugin, pluginData)
            import matlab.unittest.measurement.internal.HasAllValuesSufficientlyOutsideCalibrationOffset;
            
            teardownTestRepeatLoop@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            context = pluginData.QualificationContext;
            idx = plugin.CurrentIndex;
            measurementResult = plugin.Result(idx);
            plugin.assumeUsing(context, measurementResult, HasAllValuesSufficientlyOutsideCalibrationOffset, ...
                getString(message('MATLAB:unittest:measurement:MeasurementPlugin:MeasuredCodeShouldBeSufficientlyLong', ...
                measurementResult.MeasuredVariableName)));
        end
        
        function teardownTestClass(plugin, pluginData)
            import matlab.unittest.measurement.internal.DidNotDetectClassBoundaryMeasurement;
            
            teardownTestClass@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.verifyUsing(pluginData.QualificationContext, plugin, DidNotDetectClassBoundaryMeasurement(pluginData.Name));
        end
        
        function reportFinalizedResult(plugin, pluginData)
            reportFinalizedResult@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.Operator.storeFinalizedTestResult(pluginData.Index, pluginData.TestResult);
        end
        
    end
    
    methods(Access=private)
        function usesClassMeasurement(plugin, varargin)
            plugin.MeasuresAtClassBoundary = true;
        end
        function usesFreshFixtureMeasurement(plugin, varargin)
            plugin.MeasuresInFreshFixture = true;
        end
        function cleaner = disableFreshFixtureListeners(plugin)
            startingValue = [plugin.FreshFixtureListeners.Enabled];
            cleaner = onCleanup(@() plugin.applyFreshFixtureListenerEnabledState(startingValue));
            plugin.applyFreshFixtureListenerEnabledState(false(size(startingValue)));
        end
        
        function applyFreshFixtureListenerEnabledState(plugin, state)
            for idx = 1:numel(state)
                plugin.FreshFixtureListeners(idx).Enabled = state(idx);
            end
        end
    end
    
end

% LocalWords:  perftest
