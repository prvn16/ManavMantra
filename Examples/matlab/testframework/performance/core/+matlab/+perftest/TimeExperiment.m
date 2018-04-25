classdef TimeExperiment < handle
    % TimeExperiment - Experiment to measure execution time of code under test
    %
    %   The matlab.perftest.TimeExperiment is the principal API used to
    %   measure execution time of code under test defined as a test suite.
    %   It runs the suite exercising the code to be measured and returns
    %   matlab.unittest.measurement.MeasurementResult array whose size matches
    %   the size of the test suite. TimeExperiment can be configured to collect
    %   multiple measurements for each suite element. Each element of
    %   MeasurementResult contains details about the measurements collected
    %   during the experiment.
    %
    %   To create a TimeExperiment for use in measuring tests, use the
    %   static creation methods provided by the TimeExperiment class.
    %
    %   TimeExperiment methods:
    %       withFixedSampleSize - Create a TimeExperiment to collect a fixed number of measurements
    %       limitingSamplingError - Create a TimeExperiment to collect a variable number of measurements
    %       run - Run the measurement experiment on a TestSuite array
    %
    %   Examples:
    %
    %       import matlab.perftest.TimeExperiment
    %
    %       % Create a TestSuite array
    %       suite = testsuite;
    %
    %       % Create a TimeExperiment to collect a fixed number of samples
    %       experiment = TimeExperiment.withFixedSampleSize(8);
    %       results = run(experiment, suite);
    %
    %       % Create a TimeExperiment to collect a variable number of samples
    %       experiment = TimeExperiment.limitingSamplingError;
    %       results = run(experiment, suite);
    %
    %   See also: runperf, matlab.perftest.FixedTimeExperiment,
    %             matlab.perftest.FrequentistTimeExperiment,
    %             matlab.unittest.measurement.MeasurementResult.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable, GetAccess = private)
        TestRunner;
        Operator;
    end
    
    properties (Hidden, SetAccess = immutable, GetAccess = protected)
        MeasurementPlugin;
    end
    
    properties (Abstract, SetAccess = immutable)
        NumWarmups;
    end
    
    methods (Static)
        function experiment = withFixedSampleSize(varargin)
            % withFixedSampleSize - Create a TimeExperiment to collect a fixed number of measurements
            %
            %   EXPERIMENT = matlab.perftest.TimeExperiment.withFixedSampleSize(NUMSAMPLES)
            %   creates a FixedTimeExperiment that is configured to run an experiment collecting
            %   a fixed number of measurement samples, NUMSAMPLES, for each suite element.
            %
            %   EXPERIMENT = matlab.perftest.TimeExperiment.withFixedSampleSize(NUMSAMPLES, 'NumWarmups', NUMWARMUPS)
            %   creates a FixedTimeExperiment that is configured to run an experiment collecting
            %   a fixed number of measurements, NUMSAMPLES, after warming up the code being
            %   tested NUMWARMUPS times. Such an experiment is generally used for analyzing
            %   the typical execution time. NUMWARMUPS is 0, by default.
            %
            %   Example:
            %
            %       import matlab.perftest.TimeExperiment
            %
            %       % Create a TestSuite array
            %       suite = testsuite('mypackage.MyTestClass');
            %
            %       % Create a TimeExperiment to collect a fixed number of samples
            %       experiment = TimeExperiment.withFixedSampleSize(8);
            %       result = run(experiment, suite);
            %
            %       % Create a TimeExperiment to collect a fixed number of samples
            %       % after warming up the code
            %       experiment = TimeExperiment.withFixedSampleSize(8, 'NumWarmups', 2);
            %       result = run(experiment, suite);
            %
            % See also LIMITINGSAMPLINGERROR, matlab.perftest.FixedTimeExperiment.
            
            
            experiment = matlab.perftest.FixedTimeExperiment(varargin{:});
        end
        
        function experiment = limitingSamplingError(varargin)
            %LIMITINGSAMPLINGERROR - Create a TimeExperiment targeting a specific margin of error at a specified confidence level.
            %
            %   EXPERIMENT = matlab.perftest.TimeExperiment.limitingSamplingError
            %   creates a FrequentistTimeExperiment that is configured to run an
            %   experiment collecting a variable number of measurement samples
            %   for each suite element.
            %
            %   EXPERIMENT = matlab.perftest.TimeExperiment.limitingSamplingError(NAME, VALUE, ...)
            %   allows additional (Name, Value) pair arguments. Specify any
            %   of the following:
            %
            %       * NumWarmups            - Number of warmup runs (default 4)
            %       * MinSamples            - Minimum number of samples to collect (default 4)
            %       * MaxSamples            - Maximum number of samples to collect (default 32)
            %       * RelativeMarginOfError - Target Margin of Error for the sample (default 0.05)
            %       * ConfidenceLevel       - Confidence Level for the samples to be
            %                                 within the Margin of Error (default 0.95)
            %
            %   For each suite, the experiment will collect the minimum
            %   number of samples and then check if the estimated Margin of
            %   Error is within the target Margin of Error at the specified
            %   Confidence Level. If it is, the run is complete. Otherwise,
            %   another sample is run and tested again. This process is
            %   limited by the MaxSamples value.
            %
            %   If any test failure occurs in a suite, no subsequent runs
            %   are scheduled. If the suite's measurement never met the
            %   target RelativeMarginOfError, a warning is issued, and the
            %   next suite begins processing.
            %
            %   Example:
            %
            %       import matlab.perftest.TimeExperiment
            %
            %       % Create a TestSuite array
            %       suite = testsuite;
            %
            %       % Create a TimeExperiment to collect a variable number of samples
            %       experiment = TimeExperiment.limitingSamplingError;
            %       result = run(experiment, suite);
            %
            %       % Use custom values
            %       experiment = TimeExperiment.limitingSamplingError(...
            %          'NumWarmups', 2, 'MinSamples', 4, 'MaxSamples', 10, ...
            %          'RelativeMarginOfError', 0.20, 'ConfidenceLevel', 0.90);
            %       result = run(experiment, suite);
            %
            % See also WITHFIXEDSAMPLESIZE, matlab.perftest.FrequentistTimeExperiment.
            
            experiment = matlab.perftest.FrequentistTimeExperiment(varargin{:});
        end
    end
    
    methods(Sealed)
        function result = run(experiment, suite, varargin)
            %RUN - Run the experiment on a TestSuite array
            %
            % RESULT = RUN(EXPERIMENT, SUITE) runs the TestSuite defined by
            % SUITE using the TimeExperiment provided in EXPERIMENT, and
            % returns the result in RESULT. RESULT is a
            % matlab.unittest.measurement.MeasurementResult which is the
            % same size as SUITE, and each element is the result of the
            % corresponding element in SUITE.
            %
            % RESULT presents information describing the measurements
            % collected. This information is represented as a table of
            % Measurements for each element of the SUITE array. The number
            % of rows in the table corresponds to the total number of
            % measurements collected for each suite element.
            %
            % See also matlab.unittest.measurement.MeasurementResult.
            
            import matlab.unittest.internal.generateParserWithNewRunIdentifier;
            import matlab.unittest.measurement.MeasurementResult;
            
            parser = generateParserWithNewRunIdentifier();
            parser.parse(varargin{:});
            runIdentifier = parser.Results.RunIdentifier;
            
            % generate single UUID for the run
            uuid = categorical(runIdentifier);
            
            operator = experiment.Operator;
            operator.Result = MeasurementResult({suite.Name}, 'MeasuredTime', uuid);
            
            experiment.doRun(operator, experiment.TestRunner, suite, runIdentifier);
            
            operator.Result = applyWarmups(...
                experiment.Operator.Result, ...
                experiment.NumWarmups);
            
            result = operator.Result;
        end
    end
    
    methods(Abstract, Hidden, Access = protected)
        doRun(experiment, operator, runner, suite, runIdentifier);
    end
    
    methods (Hidden, Access = protected)
        function experiment = TimeExperiment(varargin)
            import matlab.perftest.TicTocMeter;
            import matlab.unittest.measurement.MeasurementPlugin;
            import matlab.unittest.measurement.internal.ExperimentOperator;
            
            p = matlab.unittest.internal.strictInputParser;
            p.StructExpand = true;
            
            p.addParameter('TestRunner', ...
                getDefaultTestRunner(), ...
                @validateTestRunner);
            
            p.addParameter('ExperimentOperator', ...
                ExperimentOperator(TicTocMeter), ...
                @validateOperator);
            
            p.addParameter('MeasurementPlugin', ...
                MeasurementPlugin, ...
                @validateMeasurementPlugin);
            
            p.parse(varargin{:});
            
            runner = p.Results.TestRunner;
            operator = p.Results.ExperimentOperator;
            plugin = p.Results.MeasurementPlugin;
            
            plugin.Operator = operator;
            runner.addPlugin(plugin);
            
            experiment.TestRunner =  runner;
            experiment.Operator = operator;
            experiment.MeasurementPlugin = plugin;
        end
    end
end

function result = applyWarmups(result, numWarmups)
for idx = 1:numel(result)
    testActivity = result(idx).InternalTestActivity;
    numWarmupsExecuted = min(nnz(testActivity.Iteration <= numWarmups), height(testActivity));
    testActivity.Objective(1:numWarmupsExecuted) = categorical({'warmup'});
    result(idx).InternalTestActivity = testActivity;
end
end

function runner = getDefaultTestRunner()
runner = matlab.unittest.TestRunner.withNoPlugins;
arrayfun(@(p)runner.addPlugin(p), matlab.unittest.internal.getFactoryDefaultPlugins);
end

function validateTestRunner(runner)
validateattributes(runner, {'matlab.unittest.TestRunner'}, {'scalar'});
end


function validateMeasurementPlugin(plugin)
validateattributes(plugin, {'matlab.unittest.measurement.MeasurementPlugin'}, {'scalar'});
end


function validateOperator(operator)
validateattributes(operator, {'matlab.unittest.measurement.internal.ExperimentOperator'}, {'scalar'});
end